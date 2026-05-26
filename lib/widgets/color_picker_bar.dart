import 'package:flutter/material.dart';
import 'package:sketch/untils/app_colors.dart';

class ColorPickerBar extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerBar({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Color> _presetColors = [
    Colors.black,
    Color(0xFF333333),
    Color(0xFF666666),
    Color(0xFFFF006E),
    Color(0xFFFF4757),
    Color(0xFFFF8C00),
    Color(0xFFFFD93D),
    Color(0xFF00FF88),
    Color(0xFF00D2FF),
    Color(0xFF4FC3F7),
    Color(0xFFBD00FF),
    Color(0xFF9C27B0),
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._presetColors.map((color) {
              final isSelected = selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 30 : 24,
                  height: isSelected ? 30 : 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accentCyan : Colors.white24,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // TODO: Open full color picker
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: const Icon(Icons.add, color: AppColors.textMuted, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
