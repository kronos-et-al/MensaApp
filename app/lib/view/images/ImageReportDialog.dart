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
                  semanticLabel: FlutterI18n.translate(context, "semantics.imageSubmitReport"),
                    onPressed: () async {
                      var result = await context
                          .read<IImageAccess>()
                          .reportImage(widget._meal, widget._image, _reason);
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (result) {
                        final snackBar = SnackBar(
                          content: Text(
                            FlutterI18n.translate(
                                context, "snackbar.reportImageSuccess"),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        final snackBar = SnackBar(
                          content: Text(
                            FlutterI18n.translate(
                                context, "snackbar.reportImageError"),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onError),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
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
