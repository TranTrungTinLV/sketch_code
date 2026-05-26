import 'package:flutter/material.dart';
import 'package:sketch/model/art_style.dart';
import 'package:sketch/model/render_history.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';
import 'package:sketch/widgets/history_item.dart';
import 'package:sketch/widgets/resource_monitor.dart';
import 'package:sketch/widgets/slider_control.dart';

enum RightPanelMode {
  aiPromptSettings, // Design 1
  activePrompt, // Design 2
  artisticInterpretations, // Design 3
}

class RightPanel extends StatefulWidget {
  final RightPanelMode mode;
  final ValueChanged<RightPanelMode> onModeChanged;
  final String description;
  final ValueChanged<String> onDescriptionChanged;
  final int selectedStyleChipIndex;
  final ValueChanged<int> onStyleChipSelected;
  final double creativity;
  final ValueChanged<double> onCreativityChanged;
  final double sketchFidelity;
  final ValueChanged<double> onSketchFidelityChanged;
  final VoidCallback onGenerateRender;
  final String activePrompt;
  final int selectedInterpretationIndex;
  final ValueChanged<int> onInterpretationSelected;

  const RightPanel({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.description,
    required this.onDescriptionChanged,
    required this.selectedStyleChipIndex,
    required this.onStyleChipSelected,
    required this.creativity,
    required this.onCreativityChanged,
    required this.sketchFidelity,
    required this.onSketchFidelityChanged,
    required this.onGenerateRender,
    required this.activePrompt,
    required this.selectedInterpretationIndex,
    required this.onInterpretationSelected,
  });

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.mode.index,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onModeChanged(RightPanelMode.values[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(RightPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode.index != _tabController.index) {
      _tabController.animateTo(widget.mode.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Mode tabs
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppStyles.caption(color: AppColors.textPrimary),
                unselectedLabelStyle: AppStyles.caption(),
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textMuted,
                padding: const EdgeInsets.all(3),
                tabs: const [
                  Tab(text: 'Settings', height: 32),
                  Tab(text: 'Prompt', height: 32),
                  Tab(text: 'Styles', height: 32),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAIPromptSettings(),
                _buildActivePrompt(),
                _buildArtisticInterpretations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Mode 1: AI Prompt Settings ====================
  Widget _buildAIPromptSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Prompt Settings', style: AppStyles.heading3(fontSize: 16)),
          const SizedBox(height: 20),

          // Description field
          Text('Description', style: AppStyles.label()),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              maxLines: 4,
              style: AppStyles.bodyMedium(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'A human figure standing, portrait orientation.',
                hintStyle: AppStyles.bodyMedium(),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
              onChanged: widget.onDescriptionChanged,
            ),
          ),
          const SizedBox(height: 24),

          // Art Style chips
          Text('Art Style', style: AppStyles.label()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ArtStyle.artStyleChips.asMap().entries.map((entry) {
              final isSelected = widget.selectedStyleChipIndex == entry.key;
              return GestureDetector(
                onTap: () => widget.onStyleChipSelected(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentCyan : AppColors.bgInput,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.accentCyan : AppColors.border,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: AppStyles.bodySmall(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Sliders
          SliderControl(
            label: 'Creativity',
            value: widget.creativity,
            onChanged: widget.onCreativityChanged,
          ),
          const SizedBox(height: 16),
          SliderControl(
            label: 'Sketch Fidelity',
            value: widget.sketchFidelity,
            onChanged: widget.onSketchFidelityChanged,
          ),
          const SizedBox(height: 32),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: widget.onGenerateRender,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text('Generate Render', style: AppStyles.button()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Mode 2: Active Prompt ====================
  Widget _buildActivePrompt() {
    final histories = RenderHistory.mockHistory;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Prompt header
          Text(
            'ACTIVE PROMPT',
            style: AppStyles.label(color: AppColors.accentGreen),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.activePrompt.isNotEmpty
                  ? widget.activePrompt
                  : 'Transform sketch into a high-fidelity cyberpunk character, neon lighting, rainy city background, 8k resolution, photorealistic.',
              style: AppStyles.bodyMedium(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          // Seed & Steps badges
          Row(
            children: [
              _Badge(label: 'Seed: 849201'),
              const SizedBox(width: 8),
              _Badge(label: 'Steps: 50'),
              const Spacer(),
              const Icon(Icons.tune, color: AppColors.textMuted, size: 20),
            ],
          ),

          const SizedBox(height: 24),

          // History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('History', style: AppStyles.heading3(fontSize: 14)),
              GestureDetector(
                onTap: () {},
                child: Text('View All', style: AppStyles.caption(color: AppColors.accentCyan)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...histories.map((h) => HistoryItem(history: h)),

          const SizedBox(height: 24),

          // Resource Usage
          const ResourceMonitor(),
        ],
      ),
    );
  }

  // ==================== Mode 3: Artistic Interpretations ====================
  Widget _buildArtisticInterpretations() {
    final styles = ArtStyle.interpretationStyles;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ARTISTIC INTERPRETATIONS',
            style: AppStyles.label(color: AppColors.accentOrange),
          ),
          const SizedBox(height: 16),
          ...styles.asMap().entries.map((entry) {
            final i = entry.key;
            final style = entry.value;
            final isSelected = widget.selectedInterpretationIndex == i;
            return _InterpretationCard(
              style: style,
              isSelected: isSelected,
              onTap: () => widget.onInterpretationSelected(i),
            );
          }),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Explore more styles',
                  style: AppStyles.bodyMedium(color: AppColors.accentOrange),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: AppColors.accentOrange, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppStyles.caption(color: AppColors.textSecondary)),
    );
  }
}

class _InterpretationCard extends StatefulWidget {
  final ArtStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterpretationCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_InterpretationCard> createState() => _InterpretationCardState();
}

class _InterpretationCardState extends State<_InterpretationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.style.accentColor.withOpacity(0.08)
                : _isHovered
                    ? AppColors.bgInput.withOpacity(0.5)
                    : AppColors.bgInput.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? widget.style.accentColor.withOpacity(0.5)
                  : _isHovered
                      ? AppColors.border
                      : Colors.transparent,
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.style.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.style.icon,
                  color: widget.style.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.style.name,
                      style: AppStyles.bodyMedium(
                        color: widget.isSelected
                            ? widget.style.accentColor
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.style.subtitle,
                      style: AppStyles.caption(
                        color: widget.isSelected
                            ? widget.style.accentColor.withOpacity(0.7)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Icon(
                  Icons.check,
                  color: widget.style.accentColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
