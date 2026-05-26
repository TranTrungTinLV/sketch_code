import 'package:flutter/material.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';

class BottomBar extends StatelessWidget {
  final int mode; // 0 = color palette (design 2), 1 = recent variations (design 3)
  final List<String> recentVariations;
  final int selectedVariation;
  final ValueChanged<int>? onVariationSelected;

  const BottomBar({
    super.key,
    this.mode = 0,
    this.recentVariations = const [],
    this.selectedVariation = 0,
    this.onVariationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == 1) {
      return _buildRecentVariations();
    }
    return const SizedBox.shrink();
  }

  Widget _buildRecentVariations() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Variations', style: AppStyles.heading3(fontSize: 14)),
              GestureDetector(
                onTap: () {},
                child: Text('View Archive', style: AppStyles.caption(color: AppColors.accentCyan)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (recentVariations.isEmpty ? 3 : recentVariations.length) + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                // Last item = new variation button
                if (index == (recentVariations.isEmpty ? 3 : recentVariations.length)) {
                  return _NewVariationButton();
                }
                final isSelected = selectedVariation == index;
                return GestureDetector(
                  onTap: () => onVariationSelected?.call(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.accentPink : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      recentVariations.isNotEmpty
                          ? recentVariations[index]
                          : 'assets/images/van_gogh.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.bgCard,
                        child: const Icon(Icons.image, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NewVariationButton extends StatefulWidget {
  @override
  State<_NewVariationButton> createState() => _NewVariationButtonState();
}

class _NewVariationButtonState extends State<_NewVariationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.bgInput : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered ? AppColors.accentCyan : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: _isHovered ? AppColors.accentCyan : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                'New Variation',
                style: AppStyles.caption(
                  color: _isHovered ? AppColors.accentCyan : AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
