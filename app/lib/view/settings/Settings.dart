import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view/settings/SettingsDropdownEntry.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final String _version;

  const Settings({super.key, required version}) : _version = version;

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IPreferenceAccess>(
        builder: (context, storage, child) =>
            Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                child: SingleChildScrollView(
                  child: Column(children: [
                    FutureBuilder(future: Future.wait([
                      storage.getColorScheme(),
                      storage.getPriceCategory()
                    ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Column(children: [
                              SettingsDropdownEntry(onChanged: (value) {},
                                  value: "",
                                  items: const [],
                                  // todo right string?
                                  heading: "settings.colorScheme"),
                              SettingsDropdownEntry(onChanged: (value) {},
                                  value: "",
                                  items: const [],
                                  heading: "settings.priceCategory"),
                            ],);
                          }

                          if (snapshot.hasError) {
                            // todo input from above
                          }

                          return Column(children: [
                            SettingsDropdownEntry<MensaColorScheme>(onChanged: (value) {
                              if (value != null && value != snapshot.requireData[0] as MensaColorScheme) {
                                storage.setColorScheme(value);
                              }
                            },
                                value: snapshot.requireData[0] as MensaColorScheme,
                                items: _getColorSchemeEntries(),
                                // todo right string?
                                heading: "settings.colorScheme"),
                            SettingsDropdownEntry<PriceCategory>(onChanged: (value) {
                              if (value != null && value != snapshot.data?[0]) {
                                storage.setPriceCategory(value);
                              }
                            },
                                value: snapshot.requireData[1] as PriceCategory,
                                items: _getPriceCategoryEntries(),
                                heading: "settings.priceCategory"),
                          ],);
                        }),

                  ]),
                )));
  }

  List<MensaDropdownEntry<MensaColorScheme>> _getColorSchemeEntries() {
    List<MensaDropdownEntry<MensaColorScheme>> entries = [];

    for (final value in MensaColorScheme.values) {
      entries.add(
          MensaDropdownEntry(value: value, label: "mensaColorScheme.$value"));
    }

    return entries;
  }

  List<MensaDropdownEntry<PriceCategory>> _getPriceCategoryEntries() {
    List<MensaDropdownEntry<PriceCategory>> entries = [];

    for (final value in PriceCategory.values) {
      entries.add(
          MensaDropdownEntry(value: value, label: "priceCategory.$value"));
    }

    return entries;
  }
}