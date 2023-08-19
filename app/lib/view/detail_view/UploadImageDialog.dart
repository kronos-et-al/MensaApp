import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/input_components/MensaTextField.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

/// This widget is used to display a dialog to upload an image.
class UploadImageDialog extends StatelessWidget {
  final Meal _meal;
  final TextEditingController _textFieldController = TextEditingController();

  /// Creates a new UploadImageDialog.
  /// @param key The key to identify this widget.
  /// @param meal The meal to upload an image for.
  /// @returns A new UploadImageDialog.
  UploadImageDialog({Key? key, required Meal meal})
      : _meal = meal,
        super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        text: TextSpan(children: [
                          TextSpan(
                              text: FlutterI18n.translate(
                                  context, "image.linkFirstPoint")),
                          TextSpan(
                            text: FlutterI18n.translate(
                                context, "image.linkFirstLink"),
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL();
                              },
                          ),
                          TextSpan(
                              text: FlutterI18n.translate(
                                  context, "image.linkFirstPointSecondText"))
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
                  onPressed: () async {
                    final temporalMessage = await context
                        .read<IImageAccess>()
                        .linkImage(_textFieldController.text, _meal);
                    if (!context.mounted) return;

                    Navigator.pop(context);

                    if (temporalMessage.isNotEmpty) {
                      final snackBar = SnackBar(
                        content: Text(
                          FlutterI18n.translate(context, temporalMessage),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
