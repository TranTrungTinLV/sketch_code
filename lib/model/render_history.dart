class RenderHistory {
  final String title;
  final String timeAgo;
  final String resolution;
  final String thumbnailPath;

  const RenderHistory({
    required this.title,
    required this.timeAgo,
    required this.resolution,
    required this.thumbnailPath,
  });

  static List<RenderHistory> get mockHistory => [
        const RenderHistory(
          title: 'Cyberpunk V2',
          timeAgo: '2 mins ago',
          resolution: '1024×1024',
          thumbnailPath: 'assets/images/van_gogh.png',
        ),
        const RenderHistory(
          title: 'Surreal Test',
          timeAgo: '15 mins ago',
          resolution: '1024×1024',
          thumbnailPath: 'assets/images/sketch.png',
        ),
        const RenderHistory(
          title: 'Van Gogh Style',
          timeAgo: '1 hour ago',
          resolution: '512×512',
          thumbnailPath: 'assets/images/van_gogh.png',
        ),
      ];
}
