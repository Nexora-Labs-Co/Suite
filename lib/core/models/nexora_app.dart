enum AppViewMode { grid, list }

enum SortMode { nameAsc, lastUpdated, status }

class NexoraApp {
  const NexoraApp({
    required this.id,
    required this.name,
    required this.description,
    required this.repo,
    this.subtitle,
    this.executable,
    this.iconUrl,
    this.iconAsset,
    this.installed = false,
    this.installedVersion,
    this.latestVersion,
    this.lastUpdated,
    this.latestReleaseBody,
    this.latestReleaseSize,
    this.githubUrl,
    this.homepageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String? subtitle;

  /// GitHub repository in "owner/repo" form.
  final String repo;

  /// Executable name used to detect installation.
  final String? executable;

  /// Remote icon url (optional).
  final String? iconUrl;

  /// Local asset path for the app icon (optional).
  final String? iconAsset;

  final bool installed;
  final String? installedVersion;
  final String? latestVersion;
  final DateTime? lastUpdated;

  final String? latestReleaseBody;
  final int? latestReleaseSize;

  final String? githubUrl;
  final String? homepageUrl;

  String get resolvedGithubUrl => githubUrl ?? 'https://github.com/$repo';

  bool get hasUpdate {
    if (!installed) return false;
    if (installedVersion == null || latestVersion == null) return false;
    return installedVersion != latestVersion;
  }

  NexoraApp copyWith({
    bool? installed,
    String? installedVersion,
    String? latestVersion,
    DateTime? lastUpdated,
    String? latestReleaseBody,
    int? latestReleaseSize,
    String? iconUrl,
  }) {
    return NexoraApp(
      id: id,
      name: name,
      description: description,
      subtitle: subtitle,
      iconAsset: iconAsset,
      repo: repo,
      executable: executable,
      iconUrl: iconUrl ?? this.iconUrl,
      installed: installed ?? this.installed,
      installedVersion: installedVersion ?? this.installedVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      latestReleaseBody: latestReleaseBody ?? this.latestReleaseBody,
      latestReleaseSize: latestReleaseSize ?? this.latestReleaseSize,
      githubUrl: githubUrl,
      homepageUrl: homepageUrl,
    );
  }
}

/// Static catalogue of the Nexora ecosystem applications.
const List<NexoraApp> kNexoraApps = <NexoraApp>[
  NexoraApp(
    id: 'harmony',
    name: 'Harmony',
    subtitle: 'Música y audio',
    description: 'Tu música, tu ritmo',
    repo: 'Nexora-Labs-Co/Harmony',
    executable: 'harmony',
    installed: true,
    installedVersion: '26.10.27',
    iconAsset: 'assets/icons/Logo-Harmony.png',
  ),
  NexoraApp(
    id: 'nexora_launcher',
    name: 'Nexora Suite',
    subtitle: 'Suite de Nexora',
    description: 'Centro de control del ecosistema Nexora',
    repo: 'Nexora-Labs-Co/NexoraSuite',
    executable: 'nexora-suite',
    installed: true,
    iconAsset: 'assets/icons/Logo-Suite.png',
  ),
];
