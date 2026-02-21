import 'package:flutter/material.dart';

class ColorHelper {
  static String colorToName(Color color) {
    final value = color.value;
    switch (value) {
      case 0xFFFFFFFF:
        return 'White';
      case 0xFFFF0000:
        return 'Red';
      case 0xFFFFFF00:
        return 'Yellow';
      case 0xFF0000FF:
        return 'Blue';
      case 0xFF90EE90:
        return 'Green';
      case 0xFF800080:
        return 'Purple';
      case 0xFF00FFFF:
        return 'Cyan';
      case 0xFF8B0000:
        return 'Dark Red';
      default:
        return 'Unknown';
    }
  }

  static Color nameToColor(String name) {
    if (name.trim().isEmpty) {
      return Colors.grey;
    }
    switch (name.toLowerCase().trim()) {
      case 'black':
        return const Color(0xFF0D121C);
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'red':
        return const Color(0xFFFF0000);
      case 'yellow':
        return const Color(0xFFFFFF00);
      case 'blue':
        return const Color(0xFF0000FF);
      case 'green':
        return const Color(0xFF90EE90);
      case 'purple':
        return const Color(0xFF800080);
      case 'cyan':
        return const Color(0xFF00FFFF);
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'navy':
        return const Color(0xFF000080);
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'cream':
        return const Color(0xFFFFFDD0);
      case 'maroon':
        return const Color(0xFF800000);
      case 'teal':
        return const Color(0xFF008080);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'coral':
        return const Color(0xFFFF7F50);
      case 'mint':
        return const Color(0xFF98FF98);
      case 'lavender':
        return const Color(0xFFE6E6FA);
      default:
        return const Color(0xFF0D121C);
    }
  }
}
