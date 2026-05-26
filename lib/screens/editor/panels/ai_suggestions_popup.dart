import 'package:flutter/material.dart';
import 'package:sketch/model/art_style.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';
import 'package:sketch/widgets/art_style_card.dart';

class AISuggestionsPopup extends StatelessWidget {
  final List<ArtStyle> styles;
  final int selectedIndex;
  final ValueChanged<int> onStyleSelected;
  final VoidCallback onClose;
  final VoidCallback onApply;
  final VoidCallback onGenerateMore;

  const AISuggestionsPopup({
    super.key,
    required this.styles,
    required this.selectedIndex,
    required this.onStyleSelected,
    required this.onClose,
    required this.onApply,
    required this.onGenerateMore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        constraints: const BoxConstraints(maxWidth: 760),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: -10,
            ),
            BoxShadow(
              color: AppColors.accentPurple.withOpacity(0.1),
              blurRadius: 60,
              spreadRadius: -20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI Render Suggestions',
                    style: AppStyles.heading3(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(
                    'Based on your sketch',
                    style: AppStyles.caption(),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Style cards
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: styles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return ArtStyleCard(
                    style: styles[index],
                    isSelected: selectedIndex == index,
                    onTap: () => onStyleSelected(index),
                  );
                },
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Row(
                children: [
                  const Icon(Icons.keyboard, color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Press Enter to apply selected',
                    style: AppStyles.caption(),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onGenerateMore,
                    child: Row(
                      children: [
                        Text(
                          'Generate more',
                          style: AppStyles.bodyMedium(color: AppColors.accentCyan),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.refresh, color: AppColors.accentCyan, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
