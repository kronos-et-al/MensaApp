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

class Settings extends StatefulWidget {
  Settings({super.key}) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IPreferenceAccess>(
        builder: (context, storage, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Scaffold(
              appBar: MensaAppBar(
                appBarHeight: kToolbarHeight * 1.25,
                child: Text(
                  FlutterI18n.translate(context, "common.settings"),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
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
                  SettingsSection(heading: "settings.about", children: [
                    Row(
                      children: [
                        Text(
                            FlutterI18n.translate(context, "settings.version")),
                        const Spacer(),
                        FutureBuilder(
                            future: Future.wait([PackageInfo.fromPlatform()]),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.hasError) {
                                return const Text("42.3.141");
                              }
                              final PackageInfo info = snapshot.requireData[0];
                              return Text(info.version);
                            })
                      ],
                    ),
                    Text(FlutterI18n.translate(context, "settings.licence")),
                    Row(
                      children: [
                        Expanded(child: MensaLink(
                            onPressed: () => _launchUrl(Uri.parse(
                                'https://github.com/kronos-et-al/MensaApp')),
                            text: FlutterI18n.translate(
                                context, "settings.gitHubLink")),)
                      ],
                    )
                  ]),
                  SettingsSection(
                      heading: "settings.legalInformation",
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MensaLink(
                                  onPressed: () => _launchUrl(Uri.parse(
                                      'https://docs.flutter.io/flutter/services/UrlLauncher-class.html')),
                                  text: FlutterI18n.translate(
                                      context, "settings.privacyPolicy")),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: MensaLink(
                                onPressed: () => _launchUrl(Uri.parse(
                                    'https://docs.flutter.io/flutter/services/UrlLauncher-class.html')),
                                text: FlutterI18n.translate(
                                    context, "settings.contactDetails")),)
                          ],
                        )
                      ])
                ]),
              ),
            )));
  }

  // todo add padding

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  List<MensaDropdownEntry<MensaColorScheme>> _getColorSchemeEntries(BuildContext context) {
    List<MensaDropdownEntry<MensaColorScheme>> entries = [];

    for (final value in MensaColorScheme.values) {
      entries.add(
          MensaDropdownEntry(value: value, label: FlutterI18n.translate(context, "mensaColorScheme.${value.name}")));
    }

    return entries;
  }

  List<MensaDropdownEntry<PriceCategory>> _getPriceCategoryEntries(BuildContext context) {
    List<MensaDropdownEntry<PriceCategory>> entries = [];

    for (final value in PriceCategory.values) {
      entries
          .add(MensaDropdownEntry(value: value, label: FlutterI18n.translate(context, "priceCategory.${value.name}")));
    }

    return entries;
  }
}
