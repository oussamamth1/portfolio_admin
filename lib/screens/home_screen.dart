import 'package:flutter/material.dart';
import '../models/field_spec.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'resource_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <(IconData, ResourceConfig, Widget Function())>[
      (Icons.badge_outlined, profileConfig, () => const ProfileScreen()),
      (Icons.bolt_outlined, skillsConfig, () => ResourceListScreen(config: skillsConfig)),
      (Icons.school_outlined, educationConfig, () => ResourceListScreen(config: educationConfig)),
      (
        Icons.workspace_premium_outlined,
        certificationsConfig,
        () => ResourceListScreen(config: certificationsConfig),
      ),
      (
        Icons.business_center_outlined,
        internshipsConfig,
        () => ResourceListScreen(config: internshipsConfig),
      ),
      (Icons.folder_outlined, projectsConfig, () => ResourceListScreen(config: projectsConfig)),
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
          final (icon, config, builder) = sections[index];
          return ListTile(
            leading: Icon(icon),
            title: Text(config.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder())),
          );
        },
      ),
    );
  }
}
