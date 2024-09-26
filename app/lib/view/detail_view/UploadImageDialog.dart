import 'dart:io';
import 'dart:typed_data';

import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/buttons/MensaTapable.dart';
import 'package:app/view/core/dialogs/MensaDialog.dart';
import 'package:app/view/core/icons/image/CameraIcon.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
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
  const UploadImageDialog({super.key, required Meal meal})
      : _meal = meal;

  @override
  State<UploadImageDialog> createState() => _UploadImageDialogState();
}

/// This widget is used to display a dialog to upload an image.
class _UploadImageDialogState extends State<UploadImageDialog> {
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

  bool _loading = false;

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
                                source: ImageSource.gallery, imageQuality: 90);
                            Uint8List bytes = await image!.readAsBytes();
                            setState(() {
                              _image = image;
                              _imageBytes = bytes;
                            });
                          },
                          text: FlutterI18n.translate(
                              context, "image.labelSelectImage"),
                          semanticLabel: FlutterI18n.translate(
                              context, "image.labelSelectImage"))),
                  (Platform.isAndroid || Platform.isIOS)
                      ? const SizedBox(
                          width: 8,
                        )
                      : Container(),
                  (Platform.isAndroid || Platform.isIOS)
                      ? MensaTapable(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 90);
                            Uint8List bytes = await image!.readAsBytes();
                            setState(() {
                              _image = image;
                              _imageBytes = bytes;
                            });
                          },
                          semanticLabel: FlutterI18n.translate(
                              context, "image.labelTakeImage"),
                          child: const Padding(
                              padding: EdgeInsets.all(2), child: CameraIcon()))
                      : Container(),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                    style: TextStyle(
                        fontSize: 12, color: theme.colorScheme.onBackground),
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
                          text: FlutterI18n.translate(
                              context, "image.linkFirstPointSecondText"))
                    ]),
              ),
            ],
          )),
      actions: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Spacer(),
              MensaButton(
                  disabled: _loading || _image == null,
                  loading: _loading,
                  semanticLabel: FlutterI18n.translate(
                      context, "semantics.imageSubmitUpload"),
                  onPressed: () async {
                    if (_image != null && _imageBytes != null) {
                      setState(() {
                        _loading = true;
                      });
                      final result = await context
                          .read<IImageAccess>()
                          .linkImage(
                              _imageBytes!,
                              MediaType.parse(parseMimeType(_image!)),
                              widget._meal);
                      if (!context.mounted) return;

                      setState(() {
                        _loading = false;
                      });
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
    Uri url = Uri.parse('http://creativecommons.org/publicdomain/zero/1.0');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
