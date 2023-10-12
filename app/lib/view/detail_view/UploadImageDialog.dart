import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/input_components/MensaTextField.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/error_handling/ImageUploadException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

/// This widget is used to display a dialog to upload an image.
class UploadImageDialog extends StatelessWidget {
  final Meal _meal;
  final TextEditingController _textFieldController = TextEditingController();

  /// Creates a new UploadImageDialog.
  UploadImageDialog({Key? key, required Meal meal})
      : _meal = meal,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return MensaDialog(
      title: FlutterI18n.translate(context, "image.linkImageTitle"),
      content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(FlutterI18n.translate(context, "image.linkDescription")),
              Container(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: theme.colorScheme.onBackground),
                            children: [
                              TextSpan(
                                  text: FlutterI18n.translate(
                                      context, "image.linkFirstPoint")),
                              TextSpan(
                                text: FlutterI18n.translate(
                                    context, "image.linkFirstLink"),
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _launchURL();
                                  },
                              ),
                              TextSpan(
                                  text: FlutterI18n.translate(context,
                                      "image.linkFirstPointSecondText"))
                            ]),
                      ),
                      Text(FlutterI18n.translate(
                          context, "image.linkSecondPoint")),
                      Text(FlutterI18n.translate(
                          context, "image.linkThirdPoint")),
                      Text(FlutterI18n.translate(
                          context, "image.linkFourthPoint"))
                    ],
                  )),
              const SizedBox(height: 16),
              Text(FlutterI18n.translate(
                  context, "image.linkTextFieldDescription")),
              const SizedBox(height: 8),
              MensaTextField(
                controller: _textFieldController,
              ),
              const SizedBox(height: 16),
              Text(
                  FlutterI18n.translate(
                      context, "image.linkSmallTextOwnImages"),
                  style: const TextStyle(fontSize: 12)),
              Text(
                FlutterI18n.translate(context, "image.linkSmallTextDisplayed"),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )),
      actions: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Spacer(),
              MensaButton(
                  semanticLabel: FlutterI18n.translate(
                      context, "semantics.imageSubmitUpload"),
                  onPressed: () async {
                    // todo
                    final file = MultipartFile.fromString("field", "empty");

                    final result = await context
                        .read<IImageAccess>()
                        .linkImage(file, _meal);
                    if (!context.mounted) return;

                    Navigator.pop(context);

                    switch (result) {
                      case Success<bool, ImageUploadException> value:
                        if (value.value) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              FlutterI18n.translate(
                                  context, "snackbar.linkImageSuccess"),
                              style:
                                  TextStyle(color: theme.colorScheme.onPrimary),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              FlutterI18n.translate(
                                  context, "snackbar.linkImageError"),
                              style:
                                  TextStyle(color: theme.colorScheme.onError),
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ));
                        }
                        break;
                      case Failure<bool, ImageUploadException> value:
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            value.exception.message,
                            style: TextStyle(color: theme.colorScheme.onError),
                          ),
                          backgroundColor: theme.colorScheme.error,
                        ));
                        break;
                    }
                  },
                  text: FlutterI18n.translate(context, "image.linkButton"))
            ],
          )),
    );
  }

  static void _launchURL() async {
    Uri url = Uri.parse('https://flickr.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
