import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaLink.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view/settings/SettingsDropdownEntry.dart';
import 'package:app/view/settings/SettingsSection.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

/// This class is the settings page of the mensa app.
class Settings extends StatelessWidget {
  /// Creates a new settings page.
  Settings({super.key}) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IPreferenceAccess>(
        builder: (context, storage, child) => Scaffold(
              appBar: MensaAppBar(
                appBarHeight: kToolbarHeight,
                child: Center(
                    child: Text(
                  FlutterI18n.translate(context, "common.settings"),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )),
              ),
              body: SingleChildScrollView(
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(children: [
                      SettingsDropdownEntry<MensaColorScheme>(
                          onChanged: (value) {
                            if (value != null &&
                                value != storage.getColorScheme()) {
                              storage.setColorScheme(value);
                            }
                          },
                          value: storage.getColorScheme(),
                          items: _getColorSchemeEntries(context),
                          heading: "settings.colorScheme"),
                      const SizedBox(height: 16),
                      SettingsDropdownEntry<PriceCategory>(
                          onChanged: (value) {
                            if (value != null &&
                                value != storage.getPriceCategory()) {
                              storage.setPriceCategory(value);
                            }
                          },
                          value: storage.getPriceCategory(),
                          items: _getPriceCategoryEntries(context),
                          heading: "settings.priceCategory"),
                      const SizedBox(height: 16),
                      SettingsSection(heading: "settings.about", children: [
                        Row(
                          children: [
                            Text(FlutterI18n.translate(
                                context, "settings.version")),
                            const Spacer(),
                            FutureBuilder(
                                future:
                                    Future.wait([PackageInfo.fromPlatform()]),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.hasError) {
                                    return const Text("42.3.141");
                                  }
                                  final PackageInfo info =
                                      snapshot.requireData[0];
                                  return Text(info.version);
                                })
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            FlutterI18n.translate(context, "settings.licence")),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: MensaLink(
                                  onPressed: () => _launchUrl(Uri.parse(
                                      'https://github.com/kronos-et-al/MensaApp')),
                                  text: FlutterI18n.translate(
                                      context, "settings.gitHubLink")),
                            )
                          ],
                        )
                      ]),
                      const SizedBox(height: 16),
                      SettingsSection(
                          heading: "settings.legalInformation",
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MensaLink(
                                      onPressed: () => _launchUrl(Uri.parse(
                                          'https://mensa-ka.de/privacy.html')),
                                      text: FlutterI18n.translate(
                                          context, "settings.privacyPolicy")),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: MensaLink(
                                      onPressed: () => _launchUrl(Uri.parse(
                                          'mailto:contact@mensa-ka.de')),
                                      text: FlutterI18n.translate(
                                          context, "settings.contactDetails")),
                                )
                              ],
                            )
                          ])
                    ])),
              ),
            ));
  }

  /// Launches the given url.
  Future<void> _launchUrl(Uri url) async {
    // todo: throw Exception is not that good -> show banner
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  List<MensaDropdownEntry<MensaColorScheme>> _getColorSchemeEntries(
      BuildContext context) {
    List<MensaDropdownEntry<MensaColorScheme>> entries = [];

    for (final value in MensaColorScheme.values) {
      entries.add(MensaDropdownEntry(
          value: value,
          label: FlutterI18n.translate(
              context, "mensaColorScheme.${value.name}")));
    }

    return entries;
  }

  List<MensaDropdownEntry<PriceCategory>> _getPriceCategoryEntries(
      BuildContext context) {
    List<MensaDropdownEntry<PriceCategory>> entries = [];

    for (final value in PriceCategory.values) {
      entries.add(MensaDropdownEntry(
          value: value,
          label:
              FlutterI18n.translate(context, "priceCategory.${value.name}")));
    }

    return entries;
  }
}
