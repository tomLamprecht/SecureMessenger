import 'package:flutter/material.dart';

class HoverableIconButton extends StatefulWidget {
  final IconData icon;
  final Color hoverColor;
  final Color color;
  final VoidCallback onPressed;

  HoverableIconButton({
    required this.icon,
    required this.onPressed,
    this.hoverColor = Colors.green,
    this.color = Colors.black,
  });

  @override
  _HoverableIconButtonState createState() => _HoverableIconButtonState();
}

class _HoverableIconButtonState extends State<HoverableIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: IconButton(
        icon: Icon(widget.icon),
        color: _isHovering ? widget.hoverColor : widget.color,
        onPressed: widget.onPressed,
      ),
    );
  }
}