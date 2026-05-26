import 'package:flutter/material.dart';

class ArtStyle {
  final String id;
  final String name;
  final String subtitle;
  final String thumbnailPath;
  final IconData icon;
  final bool isBestMatch;
  final Color accentColor;

  const ArtStyle({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.thumbnailPath,
    required this.icon,
    this.isBestMatch = false,
    this.accentColor = const Color(0xff00D2FF),
  });

  static List<ArtStyle> get suggestionStyles => [
        const ArtStyle(
          id: 'post_impressionist',
          name: 'Post-Impressionist',
          subtitle: 'Van Gogh style, vivid colors',
          thumbnailPath: 'assets/images/van_gogh.png',
          icon: Icons.brush,
          isBestMatch: true,
          accentColor: Color(0xffFFB800),
        ),
        const ArtStyle(
          id: 'neon_cyberpunk',
          name: 'Neon Cyberpunk',
          subtitle: 'Sci-fi, glowing accents, 8k',
          thumbnailPath: 'assets/images/van_gogh.png',
          icon: Icons.electric_bolt,
          accentColor: Color(0xff00D2FF),
        ),
        const ArtStyle(
          id: 'classic_oil',
          name: 'Classic Oil',
          subtitle: 'Renaissance lighting, detailed',
          thumbnailPath: 'assets/images/van_gogh.png',
          icon: Icons.palette,
          accentColor: Color(0xffCD853F),
        ),
      ];

  static List<ArtStyle> get interpretationStyles => [
        const ArtStyle(
          id: 'watercolor',
          name: 'Watercolor Wash',
          subtitle: 'Soft edges, fluid color blending',
          thumbnailPath: 'assets/images/van_gogh.png',
          icon: Icons.water_drop,
          accentColor: Color(0xff4FC3F7),
        ),
        const ArtStyle(
          id: 'van_gogh',
          name: 'Van Gogh Impressionism',
          subtitle: 'Thick impasto, vivid swirling strokes',
          thumbnailPath: 'assets/images/van_gogh.png',
          icon: Icons.auto_awesome,
          accentColor: Color(0xffFF8C00),
        ),
        const ArtStyle(
          id: 'renaissance',
          name: 'Renaissance Sfumato',
          subtitle: 'Classic shading, subtle transitions',
          thumbnailPath: 'assets/images/van_gogh.png',
          icon: Icons.account_balance,
          accentColor: Color(0xff9E9E9E),
        ),
      ];

  static List<String> get artStyleChips => [
        'Cyberpunk',
        'Realistic',
        'Anime',
        'Oil Paint',
        '3D Render',
      ];
}
