import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A input component that is used in the Mensa app and enables the user to enter a 1-5 star rating.
class MensaRatingInput extends StatelessWidget {
  final Function(int) _onChanged;
  final double _value;
  final int _max;
  final Color? _color;
  final bool _disabled;
  final double _size;

  /// Creates a new MensaRatingInput.
  const MensaRatingInput(
      {super.key,
      required Function(int) onChanged,
      required double value,
      int max = 5,
      Color? color,
      bool disabled = false,
      double size = 24})
      : _onChanged = onChanged,
        _value = value,
        _max = max,
        _color = color,
        _disabled = disabled,
        _size = size;

  /// Builds the widget.
  /// @param context The context in which the widget is built.
  /// @returns The widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _max; i++)
          AbsorbPointer(
            absorbing: _disabled,
            child: Padding(
                padding: EdgeInsets.all(_size * .1),
                child: GestureDetector(
                  onTap: () => {if (!_disabled) _onChanged(i + 1)},
                  child: i < _value.floor()
                      ? SvgPicture.asset(
                          'assets/icons/star_filled.svg',
                          colorFilter: ColorFilter.mode(
                              _color ?? Theme.of(context).colorScheme.primary,
                              BlendMode.srcIn),
                          width: _size,
                          height: _size,
                        )
                      : i < _value && _value < i + 1
                          ? Stack(
                              //fit: StackFit.expand,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/star_outlined.svg',
                                  colorFilter: ColorFilter.mode(
                                      _color ??
                                          Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn),
                                  width: _size,
                                  height: _size,
                                ),
                                ClipRect(
                                    clipper: _Clipper(part: _value - i),
                                    child: SvgPicture.asset(
                                      'assets/icons/star_filled.svg',
                                      colorFilter: ColorFilter.mode(
                                          _color ??
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          BlendMode.srcIn),
                                      width: _size,
                                      height: _size,
                                    ))
                              ],
                            )
                          : SvgPicture.asset(
                              'assets/icons/star_outlined.svg',
                              colorFilter: ColorFilter.mode(
                                  _color ??
                                      Theme.of(context).colorScheme.primary,
                                  BlendMode.srcIn),
                              width: _size,
                              height: _size,
                            ),
                )),
          )
      ],
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  final double _part;

  _Clipper({required double part}) : _part = part;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * _part, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
