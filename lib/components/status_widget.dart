import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final Color? color;
  final Color valueColor;

  const StatusWidget({
    required this.width,
    required this.height,
    required this.icon,
    required this.color,
    required this.valueColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: color ?? theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(width / 2)),
      ),
      width: width,
      height: height,
      child: width > 20
          ? Icon(icon, color: valueColor)
          : null,
    );
  }
}
