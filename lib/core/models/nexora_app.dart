enum AppViewMode { grid, list }

enum SortMode { nameAsc, lastUpdated, status }

class NexoraApp {
  const NexoraApp({
    required this.id,
    required this.name,
    required this.description,
    required this.repo,
    this.executable,
    this.iconUrl,
    this.installed = false,
    this.installedVersion,
    this.latestVersion,
    this.lastUpdated,
    this.githubUrl,
    this.homepageUrl,
  });

  final String id;
  final String name;
  final String description;

  /// GitHub repository in "owner/repo" form.
  final String repo;

  /// Executable name used to detect installation.
  final String? executable;

  /// Remote icon url (optional).
  final String? iconUrl;

  final bool installed;
  final String? installedVersion;
  final String? latestVersion;
  final DateTime? lastUpdated;

  final String? githubUrl;
  final String? homepageUrl;

  String get resolvedGithubUrl =>
      githubUrl ?? 'https://github.com/$repo';

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
    String? iconUrl,
  }) {
    return NexoraApp(
      id: id,
      name: name,
      description: description,
      repo: repo,
      executable: executable,
      iconUrl: iconUrl ?? this.iconUrl,
      installed: installed ?? this.installed,
      installedVersion: installedVersion ?? this.installedVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
    description:
        'Nexora music & audio companion. Stream, organise and sync your library '
        'across devices.',
    repo: 'Nexora-Labs-Co/Harmony',
    executable: 'harmony',
    installed: true,
    installedVersion: '1.4.2',
  ),
  NexoraApp(
    id: 'nexora_studio',
    name: 'Nexora Studio',
    description:
        'Lightweight creative workspace for notes, sketches and quick prototypes.',
    repo: 'Nexora-Labs-Co/NexoraStudio',
    executable: 'nexora-studio',
  ),
  NexoraApp(
    id: 'nexora_sync',
    name: 'Nexora Sync',
    description:
        'Background sync agent keeping your Nexora data consistent everywhere.',
    repo: 'Nexora-Labs-Co/NexoraSync',
    executable: 'nexora-sync',
  ),
  NexoraApp(
    id: 'nexora_notes',
    name: 'Nexora Notes',
    description: 'Minimal, fast note taking with offline-first storage.',
    repo: 'Nexora-Labs-Co/NexoraNotes',
    executable: 'nexora-notes',
  ),
  NexoraApp(
    id: 'nexora_vault',
    name: 'Nexora Vault',
    description: 'Encrypted credential and secret manager for the Nexora suite.',
    repo: 'Nexora-Labs-Co/NexoraVault',
    executable: 'nexora-vault',
  ),
  NexoraApp(
    id: 'nexora_term',
    name: 'Nexora Term',
    description: 'Terminal emulator tuned for the Nexora developer workflow.',
    repo: 'Nexora-Labs-Co/NexoraTerm',
    executable: 'nexora-term',
  ),
];
