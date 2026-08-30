import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/icons/mensa_icons.dart';
import 'package:app/view/core/meal_view_format/MealGrid.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../core/NewVersionDialog.dart';
import '../core/meal_view_format/MealList.dart';
import '../filter/FilterDialog.dart';
import 'Hint.dart';
import 'MealPlanClosed.dart';
import 'MealPlanDateSelect.dart';
import 'MealPlanError.dart';
import 'MealPlanFilter.dart';
import 'MealPlanInitialisatsionError.dart';
import 'MealPlanNoData.dart';
import 'MealPlanToolbar.dart';
import 'MensaCanteenSelect.dart';

/// This class is the view for the meal plan.
class MealPlanView extends StatefulWidget {
  /// Creates a new meal plan view.
  const MealPlanView({super.key});

  @override
  State<MealPlanView> createState() => _MealPlanViewState();
}

class _MealPlanViewState extends State<MealPlanView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    if (!mounted) return;

    final prefs = Provider.of<IPreferenceAccess>(context, listen: false);
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final lastSeenVersion = prefs.getLastSeenVersion();

    if (lastSeenVersion != currentVersion && prefs.shouldShowUpdatePopup()) {
      // Small delay to ensure translations are loaded and UI is ready
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final changes = NewVersionDialog.getChanges(context, currentVersion);

      if (changes.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) =>
              NewVersionDialog(version: currentVersion, changes: changes),
        );
      }

      await prefs.setLastSeenVersion(currentVersion);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Consumer<IMealAccess>(
      builder: (context, mealAccess, child) {
        if (mealAccess.failedInitializing) {
          return Scaffold(
            appBar: _buildSimpleAppBar(context),
            body: const MealPlanInitialisationError(),
          );
        }

        if (!mealAccess.initialized) {
          return _buildInitialLoadingScreen(context);
        }

        return Consumer<IPreferenceAccess>(
          builder: (context, preferenceAccess, child) {
            final mealPlanFormat = preferenceAccess.getMealPlanFormat();

            return Scaffold(
              appBar: MensaAppBar(
                appBarHeight: kToolbarHeight,
                bottom: MealPlanToolbar(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        MensaTapable(
                          semanticLabel: FlutterI18n.translate(
                            context,
                            mealPlanFormat == MealPlanFormat.grid
                                ? 'semantics.mealPlanToggleList'
                                : 'semantics.mealPlanToggleGrid',
                          ),
                          child: mealPlanFormat == MealPlanFormat.grid
                              ? const MensaIcon(MensaIcons.listOutlined)
                              : const MensaIcon(MensaIcons.gridOutlined),
                          onTap: () {
                            preferenceAccess.setMealPlanFormat(
                              mealPlanFormat == MealPlanFormat.grid
                                  ? MealPlanFormat.list
                                  : MealPlanFormat.grid,
                            );
                          },
                        ),
                        const Spacer(),
                        MealPlanDateSelect(
                          date: mealAccess.date,
                          onDateChanged: (date) => mealAccess.changeDate(date),
                        ),
                        const Spacer(),
                        MensaTapable(
                          semanticLabel: FlutterI18n.translate(
                            context,
                            "semantics.mealPlanFilter",
                          ),
                          child: mealAccess.filterActive
                              ? const MensaIcon(MensaIcons.filterOutlined)
                              : const MensaIcon(
                                  MensaIcons.filterOutlinedDisabled,
                                ),
                          onLongPress: () => mealAccess.toggleFilter(),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const FilterDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                child: Semantics(
                  header: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: MensaCanteenSelect(
                            selectedCanteen: mealAccess.canteen,
                            availableCanteens: mealAccess.availableCanteens,
                            onCanteenSelected: (canteen) =>
                                mealAccess.changeCanteen(canteen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      String? error = await mealAccess.refreshMealplan();
                      if (!context.mounted) return;
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              FlutterI18n.translate(context, error),
                              style: TextStyle(
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
                    child: (() {
                      final mealPlansResult = mealAccess.mealPlanResult;
                      switch (mealPlansResult) {
                        case Success(value: final plans):
                          return mealPlanFormat == MealPlanFormat.grid
                              ? MealGrid(mealPlans: plans)
                              : MealList(mealPlans: plans);
                        case Failure(exception: final exception):
                          if (exception is NoConnectionException) {
                            return const MealPlanError();
                          }
                          if (exception is NoDataException) {
                            return const MealPlanNoData();
                          }
                          if (exception is ClosedCanteenException) {
                            return const MealPlanClosed();
                          }
                          if (exception is FilteredMealException) {
                            return const MealPlanFilter();
                          }
                          return const MealPlanError();
                      }
                    }()),
                  ),
                  if (mealAccess.isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary.withAlpha(120),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildSimpleAppBar(BuildContext context) {
    return MensaAppBar(
      appBarHeight: kToolbarHeight,
      child: Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            FlutterI18n.translate(context, "common.appTitle"),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialLoadingScreen(BuildContext context) {
    return Scaffold(
      appBar: _buildSimpleAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Text(
                FlutterI18n.translate(context, "common.welcomeTitle"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    FlutterI18n.translate(context, "hint.title"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Hint(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
