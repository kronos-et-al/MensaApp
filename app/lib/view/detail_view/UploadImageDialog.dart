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

class UploadImageDialog extends StatelessWidget {
  final Meal _meal;

  final TextEditingController _textFieldController = TextEditingController();

  UploadImageDialog({Key? key, required Meal meal})
      : _meal = meal,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MensaDialog(
      title: FlutterI18n.translate(context, "image.linkImageTitle"),
      content: Column(
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
                        text: 'clickable word',
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
                  Text(FlutterI18n.translate(context, "image.linkSecondPoint")),
                  Text(FlutterI18n.translate(context, "image.linkThirdPoint")),
                  Text(FlutterI18n.translate(context, "image.linkFourthPoint"))
                ],
              )),
          // todo padding
          Text(
              FlutterI18n.translate(context, "image.linkTextFieldDescription")),
          MensaTextField(
            controller: _textFieldController,
          ),
          // todo padding
          Text(FlutterI18n.translate(context, "image.linkSmallTextOwnImages"),
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: 0.5)),
          Text(
            FlutterI18n.translate(context, "image.linkSmallTextDisplayed"),
            style:
                DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.5),
          ),
        ],
      ),
      actions: Row(
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
                    content:
                        Text(FlutterI18n.translate(context, temporalMessage)),
                    backgroundColor: Theme.of(context).colorScheme.onError,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              text: FlutterI18n.translate(context, "image.linkButton"))
        ],
      ),
    );
  }

  static void _launchURL() async {
    Uri url = Uri.parse('https://flickr.com/');
    if (await launchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
