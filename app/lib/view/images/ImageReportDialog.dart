import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

// TODO statefull machen
class ImageReportDialog extends StatefulWidget {
  final ImageData _image;

  const ImageReportDialog({super.key, required ImageData image}) : _image = image;

  @override
  State<StatefulWidget> createState() => _ImageReportState();
}

class _ImageReportState extends State<ImageReportDialog> {
  ReportCategory _reason = ReportCategory.other;

  @override
  Widget build(BuildContext context) {
    return MensaDialog(
      title: FlutterI18n.translate(context, "image.reportImageTitle"),
      content: Consumer<IImageAccess>(
          builder: (context, imageAccess, child) => Column(
            children: [
              Text(FlutterI18n.translate(
                  context, "image.reportDescription")),
              Row(
                children: [
                  Expanded(
                      child: MensaDropdown(
                        onChanged: (value) {
                          if (value != null) {
                            _reason = value;
                          }
                        },
                        value: _reason,
                        items: _getReportCategoryEntries(context),
                      ))
                ],
              ),
              Row(
                children: [
                  const Spacer(),
                  MensaButton(
                      onPressed: () async {
                        final temporalMessage =
                        await imageAccess.reportImage(widget._image, _reason);
                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (temporalMessage.isNotEmpty) {
                          final snackBar = SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, temporalMessage)),
                            backgroundColor:
                            Theme.of(context).colorScheme.onError,
                          );

                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBar);
                        }
                      },
                      text: FlutterI18n.translate(
                          context, "image.reportButton")),
                ],
              )
            ],
          )),
    );
  }

  List<MensaDropdownEntry<ReportCategory>> _getReportCategoryEntries(
      BuildContext context) {
    List<MensaDropdownEntry<ReportCategory>> entries = [];

    for (final value in ReportCategory.values) {
      entries.add(MensaDropdownEntry(
          value: value,
          label: FlutterI18n.translate(context, "reportReason.${value.name}")));
    }

    return entries;
  }
}
