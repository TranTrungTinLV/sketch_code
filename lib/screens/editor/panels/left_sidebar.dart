import 'package:flutter/material.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';

class LeftSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;

  const LeftSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  bool _brushesExpanded = false;
  bool _colorsExpanded = false;
  bool _aiExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) return const SizedBox.shrink();

    return Container(
      width: 210,
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(Icons.brush, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'ArtifyAI',
                  style: AppStyles.heading2(fontSize: 18),
                ),
              ],
            ),
          ),

          // Workspace section
          _SectionLabel(label: 'WORKSPACE'),
          const SizedBox(height: 4),
          ..._workspaceItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return _NavItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              isActive: widget.selectedIndex == i,
              activeColor: item['color'] as Color,
              onTap: () => widget.onItemSelected(i),
            );
          }),

          const SizedBox(height: 20),

          // Studio Tools section
          _SectionLabel(label: 'STUDIO TOOLS'),
          const SizedBox(height: 4),
          _ExpandableItem(
            icon: Icons.brush,
            label: 'Brushes',
            isExpanded: _brushesExpanded,
            onTap: () => setState(() => _brushesExpanded = !_brushesExpanded),
          ),
          _ExpandableItem(
            icon: Icons.palette,
            label: 'Colors',
            isExpanded: _colorsExpanded,
            onTap: () => setState(() => _colorsExpanded = !_colorsExpanded),
          ),
          _ExpandableItem(
            icon: Icons.auto_awesome,
            label: 'AI Interpretations',
            isExpanded: _aiExpanded,
            onTap: () => setState(() => _aiExpanded = !_aiExpanded),
            activeColor: AppColors.accentOrange,
            showBottomAccent: true,
          ),

          const Spacer(),

          // User profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.bgCard,
                  child: const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User', style: AppStyles.bodyMedium(color: AppColors.textPrimary)),
                      Text('Pro Plan', style: AppStyles.caption()),
                    ],
                  ),
                ),
                const Icon(Icons.settings, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> _workspaceItems = [
    {'icon': Icons.edit, 'label': 'Current Canvas', 'color': AppColors.accentPink},
    {'icon': Icons.collections, 'label': 'Portfolios', 'color': AppColors.accentCyan},
    {'icon': Icons.history, 'label': 'History', 'color': AppColors.accentCyan},
  ];
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        label,
        style: AppStyles.label(color: AppColors.textMuted),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.activeColor.withOpacity(0.1)
                : _isHovered
                    ? AppColors.bgInput.withOpacity(0.3)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isActive
                ? Border.all(color: widget.activeColor.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isActive
                    ? widget.activeColor
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppStyles.navItem(
                  active: widget.isActive,
                  color: widget.isActive ? widget.activeColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color activeColor;
  final bool showBottomAccent;

  const _ExpandableItem({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
    this.activeColor = AppColors.textSecondary,
    this.showBottomAccent = false,
  });

  @override
  State<_ExpandableItem> createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<_ExpandableItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppColors.bgInput.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: widget.activeColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppStyles.navItem(),
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (widget.showBottomAccent)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 3,
                decoration: BoxDecoration(
                  color: widget.activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
