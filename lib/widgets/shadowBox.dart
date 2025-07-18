import 'package:flutter/material.dart';

class ShadowedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow>? shadows;
  final Color shadowColor; // New property
  final double? width;
  final double? height;
  final double shadowOpacity; // New property
  final double blurRadius; // New property
  final Offset shadowOffset; // New property

  const ShadowedContainer({
    Key? key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(vertical: 0),
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.shadows,
    this.shadowColor = Colors.black, // Default shadow color
    this.shadowOpacity = 0.1, // Default opacity
    this.blurRadius = 40, // Default blur radius
    this.shadowOffset = const Offset(0, 2), // Default offset
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: shadows ??
            [
              BoxShadow(
                color: shadowColor.withOpacity(shadowOpacity),
                spreadRadius: 0,
                blurRadius: blurRadius,
                offset: shadowOffset,
              ),
            ],
      ),
      child: child,
    );
  }
}