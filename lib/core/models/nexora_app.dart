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
      subtitle: subtitle,
      iconAsset: iconAsset,
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
    subtitle: 'Música y audio',
    description: 'Tu música, tu ritmo',
    repo: 'Nexora-Labs-Co/Harmony',
    executable: 'harmony',
    installed: true,
    installedVersion: '1.4.2',
    iconAsset: 'assets/icons/Logo-Harmony.svg',
  ),
  NexoraApp(
    id: 'nexora_studio',
    name: 'Nexora Studio',
    subtitle: 'Espacio creativo',
    description:
        'Espacio de trabajo creativo y ligero para notas, bocetos y prototipos rápidos.',
    repo: 'Nexora-Labs-Co/NexoraStudio',
    executable: 'nexora-studio',
  ),
  NexoraApp(
    id: 'nexora_sync',
    name: 'Nexora Sync',
    subtitle: 'Sincronización',
    description:
        'Agente de sincronización en segundo plano que mantiene tus datos de Nexora '
        'consistentes en todas partes.',
    repo: 'Nexora-Labs-Co/NexoraSync',
    executable: 'nexora-sync',
  ),
  NexoraApp(
    id: 'nexora_notes',
    name: 'Nexora Notes',
    subtitle: 'Notas rápidas',
    description: 'Toma de notas minimalista y rápida con almacenamiento offline.',
    repo: 'Nexora-Labs-Co/NexoraNotes',
    executable: 'nexora-notes',
  ),
  NexoraApp(
    id: 'nexora_vault',
    name: 'Nexora Vault',
    subtitle: 'Gestor de secretos',
    description: 'Gestor cifrado de credenciales y secretos para la suite Nexora.',
    repo: 'Nexora-Labs-Co/NexoraVault',
    executable: 'nexora-vault',
  ),
  NexoraApp(
    id: 'nexora_term',
    name: 'Nexora Term',
    subtitle: 'Terminal',
    description: 'Emulador de terminal optimizado para el flujo de trabajo de Nexora.',
    repo: 'Nexora-Labs-Co/NexoraTerm',
    executable: 'nexora-term',
  ),
];
