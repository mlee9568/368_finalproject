// tile_widget.dart
// Michelle Lee

import "package:flutter/material.dart";

class TileWidget extends StatelessWidget {
  final int value;

  TileWidget(this.value);

  Color getTileColor() {
    switch (value) {
      case 2:    return Color(0xFFEEE4DA);
      case 4:    return Color(0xFFEDE0C8);
      case 8:    return Color(0xFFF2B179);
      case 16:   return Color(0xFFF59563);
      case 32:   return Color(0xFFF67C5F);
      case 64:   return Color(0xFFF65E3B);
      case 128:  return Color(0xFFEDCF72);
      case 256:  return Color(0xFFEDCC61);
      case 512:  return Color(0xFFEDC850);
      case 1024: return Color(0xFFEDC53F);
      case 2048: return Color(0xFFEDC22E);
      default:   return Color(0xFFCDC1B4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: getTileColor(),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value == 0 ? "" : "$value",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }
}