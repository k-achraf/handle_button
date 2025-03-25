library handle_button;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:handle_button/components/status_widget.dart';

enum ButtonState { idle, loading, success, error }

class HandleButton extends StatefulWidget {
  final HandleButtonController controller;
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final double height;
  final double width;
  final double loaderSize;
  final double loaderStrokeWidth;
  final bool animateOnTap;
  final Color valueColor;
  final bool resetAfterDuration;
  final Curve curve;
  final double borderRadius;
  final Duration duration;
  final double elevation;
  final Duration resetDuration;
  final Color? errorColor;
  final Color? successColor;
  final Color? disabledColor;
  final IconData successIcon;
  final IconData failedIcon;
  final Curve completionCurve;
  final Duration completionDuration;
  final Widget? loadingWidget;

  Duration get _borderDuration => Duration(milliseconds: duration.inMilliseconds ~/ 2);

  const HandleButton({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.child,
    this.color = Colors.lightBlue,
    this.height = 50,
    this.width = 300,
    this.loaderSize = 24.0,
    this.loaderStrokeWidth = 2.0,
    this.animateOnTap = true,
    this.valueColor = Colors.white,
    this.borderRadius = 35,
    this.elevation = 2,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCirc,
    this.errorColor = Colors.red,
    this.successColor,
    this.resetDuration = const Duration(seconds: 15),
    this.resetAfterDuration = false,
    this.successIcon = Icons.check,
    this.failedIcon = Icons.close,
    this.completionCurve = Curves.elasticOut,
    this.completionDuration = const Duration(milliseconds: 1000),
    this.disabledColor,
    this.loadingWidget
  }) : super(key: key);

  @override
  HandleButtonState createState() => HandleButtonState();
}

class HandleButtonState extends State<HandleButton> with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _borderController;
  late AnimationController _checkButtonController;

  late Animation<double> _squeezeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation _borderAnimation;

  ButtonState _currentState = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    Widget _loader = SizedBox(
      height: widget.loaderSize,
      width: widget.loaderSize,
      child: widget.loadingWidget ?? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
        strokeWidth: widget.loaderStrokeWidth,
      ),
    );

    return SizedBox(
      height: widget.height,
      child: Center(
        child: _currentState == ButtonState.error ? StatusWidget(
          width: _bounceAnimation.value,
          height: _bounceAnimation.value,
          color: widget.errorColor,
          icon: widget.failedIcon,
          valueColor: widget.valueColor,
        ) :
        _currentState == ButtonState.success ? StatusWidget(
          width: _bounceAnimation.value,
          height: _bounceAnimation.value,
          color: widget.successColor,
          icon: widget.successIcon,
          valueColor: widget.valueColor,
        ) :
        _buildButton(_loader),
      ),
    );
  }

  Widget _buildButton(Widget loader) {
    return ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: _borderAnimation.value),
      disabledColor: widget.disabledColor,
      padding: const EdgeInsets.all(0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(_squeezeAnimation.value, widget.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          backgroundColor: widget.color,
          elevation: widget.elevation,
          padding: const EdgeInsets.all(0),
        ),
        onPressed: widget.onPressed == null ? null : _btnPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _currentState == ButtonState.loading ? loader : widget.child,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    widget.controller._addListeners(_start, _stop, _success, _error, _reset);
  }

  void _initializeAnimations() {
    _buttonController = AnimationController(duration: widget.duration, vsync: this);
    _checkButtonController = AnimationController(duration: widget.completionDuration, vsync: this);
    _borderController = AnimationController(duration: widget._borderDuration, vsync: this);

    _bounceAnimation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(parent: _checkButtonController, curve: widget.completionCurve),
    )..addListener(() => setState(() {}));

    _squeezeAnimation = Tween<double>(begin: widget.width, end: widget.height).animate(
      CurvedAnimation(parent: _buttonController, curve: widget.curve),
    )..addListener(() => setState(() {}));

    _borderAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(widget.borderRadius),
      end: BorderRadius.circular(widget.height),
    ).animate(_borderController)
      ..addListener(() => setState(() {}));

    _squeezeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.animateOnTap) {
        widget.onPressed?.call();
      }
    });
  }

  void _btnPressed() {
    if (widget.animateOnTap) _start();
    else widget.onPressed?.call();
  }

  void _start() {
    if (!mounted) return;
    setState(() => _currentState = ButtonState.loading);
    _borderController.forward();
    _buttonController.forward();
    if (widget.resetAfterDuration) _reset();
  }

  void _stop() {
    if (!mounted) return;
    setState(() => _currentState = ButtonState.idle);
    _buttonController.reverse();
    _borderController.reverse();
  }

  void _success() {
    if (!mounted) return;
    setState(() => _currentState = ButtonState.success);
    _checkButtonController.forward();
  }

  void _error() {
    if (!mounted) return;
    setState(() => _currentState = ButtonState.error);
    _checkButtonController.forward();
  }

  void _reset() async {
    if (widget.resetAfterDuration) await Future.delayed(widget.resetDuration);
    if (!mounted) return;
    setState(() => _currentState = ButtonState.idle);
    _buttonController.reverse();
    _borderController.reverse();
    _checkButtonController.reset();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _checkButtonController.dispose();
    _borderController.dispose();
    super.dispose();
  }
}

class HandleButtonController {
  VoidCallback? _start;
  VoidCallback? _stop;
  VoidCallback? _success;
  VoidCallback? _error;
  VoidCallback? _reset;

  void _addListeners(
      VoidCallback start,
      VoidCallback stop,
      VoidCallback success,
      VoidCallback error,
      VoidCallback reset,
      ) {
    _start = start;
    _stop = stop;
    _success = success;
    _error = error;
    _reset = reset;
  }

  void start() => _start?.call();
  void stop() => _stop?.call();
  void success() => _success?.call();
  void error() => _error?.call();
  void reset() => _reset?.call();
}