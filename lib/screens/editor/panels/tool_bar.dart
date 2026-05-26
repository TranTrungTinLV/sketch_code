import 'package:flutter/material.dart';
import 'package:sketch/untils/app_colors.dart';

class ToolBar extends StatelessWidget {
  final int selectedTool;
  final ValueChanged<int> onToolSelected;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ToolBar({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drawing tools
          ..._tools.asMap().entries.map((entry) {
            final i = entry.key;
            final tool = entry.value;
            return _ToolButton(
              icon: tool['icon'] as IconData,
              isActive: selectedTool == i,
              activeColor: tool['color'] as Color,
              tooltip: tool['label'] as String,
              onTap: () => onToolSelected(i),
            );
          }),

          const SizedBox(height: 8),
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 8),

          // Search/zoom
          _ToolButton(
            icon: Icons.search,
            isActive: false,
            activeColor: AppColors.accentCyan,
            tooltip: 'Search',
            onTap: () {},
          ),

          const Spacer(),

          // Color swatches
          _ColorSwatch(
            color: Colors.black,
            isSelected: selectedColor == Colors.black,
            onTap: () => onColorSelected(Colors.black),
          ),
          _ColorSwatch(
            color: AppColors.accentPink,
            isSelected: selectedColor == AppColors.accentPink,
            onTap: () => onColorSelected(AppColors.accentPink),
          ),
          _ColorSwatch(
            color: AppColors.accentCyan,
            isSelected: selectedColor == AppColors.accentCyan,
            onTap: () => onColorSelected(AppColors.accentCyan),
          ),
          const SizedBox(height: 8),
          // Add color button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Icon(Icons.add, color: AppColors.textMuted, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> _tools = [
    {'icon': Icons.edit, 'label': 'Pen', 'color': AppColors.accentCyan},
    {'icon': Icons.auto_fix_high, 'label': 'Eraser', 'color': AppColors.accentCyan},
    {'icon': Icons.crop_square, 'label': 'Shape', 'color': AppColors.accentCyan},
    {'icon': Icons.title, 'label': 'Text', 'color': AppColors.accentCyan},
    {'icon': Icons.mic, 'label': 'Voice', 'color': AppColors.accentCyan},
  ];
}

class _ToolButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<_ToolButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38,
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: widget.isActive ? AppColors.primaryGradient : null,
              color: widget.isActive
                  ? null
                  : _isHovered
                      ? AppColors.bgInput
                      : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.isActive
                  ? Colors.white
                  : _isHovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 30 : 26,
        height: isSelected ? 30 : 26,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
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
  }
}
