import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/field_spec.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'appearance_screen.dart';
import 'profile_screen.dart';
import 'profile_setup_screen.dart';
import 'resource_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checking = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    setState(() => _checking = true);
    try {
      await ApiClient.instance.getOne('/me/profile');
      if (mounted) setState(() => _hasProfile = true);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        if (mounted) setState(() => _hasProfile = false);
      } else {
        rethrow;
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_hasProfile) {
      return ProfileSetupScreen(onDone: _checkProfile);
    }

    final profileGroup = <_HomeItem>[
      _HomeItem(Icons.badge_outlined, profileConfig.title, () => const ProfileScreen()),
      _HomeItem(Icons.palette_outlined, 'Appearance', () => const AppearanceScreen()),
    ];

    final contentGroup = <_HomeItem>[
      _HomeItem(Icons.bolt_outlined, skillsConfig.title, () => ResourceListScreen(config: skillsConfig)),
      _HomeItem(
        Icons.translate_outlined,
        languagesConfig.title,
        () => ResourceListScreen(config: languagesConfig),
      ),
      _HomeItem(
        Icons.school_outlined,
        educationConfig.title,
        () => ResourceListScreen(config: educationConfig),
      ),
      _HomeItem(
        Icons.workspace_premium_outlined,
        certificationsConfig.title,
        () => ResourceListScreen(config: certificationsConfig),
      ),
      _HomeItem(
        Icons.business_center_outlined,
        internshipsConfig.title,
        () => ResourceListScreen(config: internshipsConfig),
      ),
      _HomeItem(
        Icons.folder_outlined,
        projectsConfig.title,
        () => ResourceListScreen(config: projectsConfig),
      ),
    ];

    final email = AuthService.instance.currentSession?.user.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => AuthService.instance.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (email != null) ...[
            Text(
              'Signed in as',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 2),
            Text(email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
          ],
          _SectionLabel('Profile'),
          const SizedBox(height: 8),
          _HomeGroup(items: profileGroup),
          const SizedBox(height: 24),
          _SectionLabel('Content'),
          const SizedBox(height: 8),
          _HomeGroup(items: contentGroup),
        ],
      ),
    );
  }
}

class _HomeItem {
  const _HomeItem(this.icon, this.title, this.builder);
  final IconData icon;
  final String title;
  final Widget Function() builder;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HomeGroup extends StatelessWidget {
  const _HomeGroup({required this.items});
  final List<_HomeItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 72),
            _HomeTile(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({required this.item});
  final _HomeItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Icon(item.icon, size: 20),
      ),
      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.builder())),
    );
  }
}
