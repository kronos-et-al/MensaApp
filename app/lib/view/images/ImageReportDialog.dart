import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the report dialog for an image.
class ImageReportDialog extends StatefulWidget {
  final ImageData _image;
  final Meal _meal;

  /// Creates a new image report dialog.
  /// @param key The key to identify this widget.
  /// @param image The image to report.
  /// @return a widget that displays the report dialog for an image
  const ImageReportDialog(
      {super.key, required ImageData image, required Meal meal})
      : _image = image,
        _meal = meal;

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
            builder: (context, imageAccess, child) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(FlutterI18n.translate(
                        context, "image.reportDescription")),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: MensaDropdown(
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _reason = value;
                              });
                            }
                          },
                          value: _reason,
                          items: _getReportCategoryEntries(context),
                        ))
                      ],
                    ),
                  ],
                ))),
        actions: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                MensaButton(
                    onPressed: () async {
                      var temporalMessage = await context
                          .read<IImageAccess>()
                          .reportImage(widget._meal, widget._image, _reason);
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (temporalMessage.isNotEmpty) {
                        final snackBar = SnackBar(
                          content: Text(
                            FlutterI18n.translate(context, temporalMessage),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    text: FlutterI18n.translate(context, "image.reportButton")),
              ],
            )));
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
