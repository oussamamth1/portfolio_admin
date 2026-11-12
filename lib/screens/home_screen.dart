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

    final sections = <(IconData, String, Widget Function())>[
      (Icons.badge_outlined, profileConfig.title, () => const ProfileScreen()),
      (Icons.palette_outlined, 'Appearance', () => const AppearanceScreen()),
      (Icons.bolt_outlined, skillsConfig.title, () => ResourceListScreen(config: skillsConfig)),
      (
        Icons.school_outlined,
        educationConfig.title,
        () => ResourceListScreen(config: educationConfig),
      ),
      (
        Icons.workspace_premium_outlined,
        certificationsConfig.title,
        () => ResourceListScreen(config: certificationsConfig),
      ),
      (
        Icons.business_center_outlined,
        internshipsConfig.title,
        () => ResourceListScreen(config: internshipsConfig),
      ),
      (
        Icons.folder_outlined,
        projectsConfig.title,
        () => ResourceListScreen(config: projectsConfig),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService.instance.signOut(),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: sections.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final (icon, title, builder) = sections[index];
          return ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder())),
          );
        },
      ),
    );
  }
}
