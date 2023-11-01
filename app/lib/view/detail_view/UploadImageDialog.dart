import 'dart:convert';
import 'dart:typed_data';

import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/icons/navigation/NavigationAddImageIcon.dart';
import 'package:app/view/core/input_components/MensaTextField.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/logic/image/ImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/error_handling/ImageUploadException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class UploadImageDialog extends StatefulWidget {
  final Meal _meal;

  /// Creates a new UploadImageDialog.
  const UploadImageDialog({Key? key, required Meal meal})
      : _meal = meal,
        super(key: key);

  @override
  State<UploadImageDialog> createState() => _UploadImageDialogState();
}

/// This widget is used to display a dialog to upload an image.
class _UploadImageDialogState extends State<UploadImageDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  String parseMimeType(XFile image) {
    if (image.mimeType == null) {
      print(image.name);
      if (image.name.endsWith(".jpg")) return "image/jpg";
      if (image.name.endsWith(".jpeg")) return "image/jpeg";
      if (image.name.endsWith(".png")) return "image/png";
      if (image.name.endsWith(".gif")) return "image/gif";
      if (image.name.endsWith(".bmp")) return "image/bmp";
      if (image.name.endsWith(".webp")) return "image/webp";
      if (image.name.endsWith(".tif")) return "image/tiff";
      if (image.name.endsWith(".tiff")) return "image/tiff";
      if (image.name.endsWith(".avif")) return "image/avif";
      if (image.name.endsWith(".apng")) return "image/apng";
      if (image.name.endsWith(".dng")) return "image/dng";
      return "";
    }
    return image.mimeType!;
  }

  XFile? _image;
  Uint8List? _imageBytes;

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
              const SizedBox(height: 8),
              _image != null ? Image.memory(_imageBytes!) : Container(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: MensaButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            Uint8List bytes = await image!.readAsBytes();
                            setState(() {
                              _image = image;
                              _imageBytes = bytes;
                            });
                          },
                          text: FlutterI18n.translate(context, "image.labelSelectImage"),
                          semanticLabel: FlutterI18n.translate(context, "image.labelSelectImage"))),
                  const SizedBox(
                    width: 8,
                  ),
                  MensaTapable(
                      child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: NavigationAddImageIcon()),
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        Uint8List bytes = await image!.readAsBytes();
                        setState(() {
                          _image = image;
                          _imageBytes = bytes;
                        });
                      },
                      semanticLabel: FlutterI18n.translate(context, "image.labelTakeImage"))
                ],
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

                    if (_image != null && _imageBytes != null) {
                      print(_image!.mimeType);
                      MediaType _mediaType = MediaType.parse(parseMimeType(_image!));
                      print(_mediaType);
                      final result = await context
                          .read<IImageAccess>()
                          .linkImage(_imageBytes!,
                              MediaType.parse(parseMimeType(_image!)), widget._meal);
                      if (!context.mounted) return;

                      Navigator.pop(context);

                      switch (result) {
                        case Success<bool, ImageUploadException> value:
                          if (value.value) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                FlutterI18n.translate(
                                    context, "snackbar.linkImageSuccess"),
                                style: TextStyle(
                                    color: theme.colorScheme.onPrimary),
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
                              style:
                                  TextStyle(color: theme.colorScheme.onError),
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ));
                          break;
                      }
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
