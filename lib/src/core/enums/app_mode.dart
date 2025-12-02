enum AppMode {
  user,
  developer;

  String get label => switch (this) {
        AppMode.user => 'Pengguna',
        AppMode.developer => 'Pengembang',
      };
}

