import 'package:flutter/material.dart';
import '../services/api_client.dart';

class _ThemeOption {
  const _ThemeOption(this.key, this.label, this.color);
  final String key;
  final String label;
  final Color color;
}

const _themeOptions = [
  _ThemeOption('amber', 'Amber', Color(0xFFF59E0B)),
  _ThemeOption('violet', 'Violet', Color(0xFFA78BFA)),
  _ThemeOption('emerald', 'Emerald', Color(0xFF10B981)),
  _ThemeOption('crimson', 'Crimson', Color(0xFFF43F5E)),
  _ThemeOption('azure', 'Azure', Color(0xFF38BDF8)),
  _ThemeOption('rose', 'Rose', Color(0xFFEC4899)),
  _ThemeOption('slate', 'Slate', Color(0xFF94A3B8)),
  _ThemeOption('ocean', 'Ocean', Color(0xFF0EA5B5)),
];

class _SectionLabel {
  const _SectionLabel(this.key, this.title, this.icon);
  final String key;
  final String title;
  final IconData icon;
}

const _sectionLabels = {
  'skills': _SectionLabel('skills', 'Skills', Icons.bolt_outlined),
  'internships': _SectionLabel('internships', 'Experience', Icons.business_center_outlined),
  'projects': _SectionLabel('projects', 'Projects', Icons.folder_outlined),
  'education': _SectionLabel('education', 'Education', Icons.school_outlined),
  'certifications': _SectionLabel(
    'certifications',
    'Certifications',
    Icons.workspace_premium_outlined,
  ),
  'languages': _SectionLabel('languages', 'Languages', Icons.translate_outlined),
  'stats': _SectionLabel('stats', 'Stats', Icons.bar_chart_outlined),
  'contact': _SectionLabel('contact', 'Contact', Icons.alternate_email_outlined),
};

class _AnimationOption {
  const _AnimationOption(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

const _animationOptions = [
  _AnimationOption('none', 'None', Icons.block_outlined),
  _AnimationOption('fade', 'Fade in', Icons.auto_awesome_outlined),
  _AnimationOption('particles', 'Particles', Icons.scatter_plot_outlined),
  _AnimationOption('matrix', 'Matrix rain', Icons.code_outlined),
  _AnimationOption('tilt', 'Tilt', Icons.threed_rotation_outlined),
];

class _SizeOption {
  const _SizeOption(this.key, this.label);
  final String key;
  final String label;
}

const _sizeOptions = [
  _SizeOption('small', 'Small'),
  _SizeOption('medium', 'Medium'),
  _SizeOption('large', 'Large'),
];

const _defaultSectionConfig = [
  {'key': 'skills', 'visible': true},
  {'key': 'internships', 'visible': true},
  {'key': 'projects', 'visible': true},
  {'key': 'education', 'visible': true},
  {'key': 'certifications', 'visible': true},
  {'key': 'languages', 'visible': true},
  {'key': 'stats', 'visible': true},
  {'key': 'contact', 'visible': true},
];

/// Lets the signed-in user pick a curated theme and control the order and
/// visibility of the five content sections on their public /u/:username page.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _theme = 'amber';
  String _animation = 'none';
  String _avatarSize = 'medium';
  String _textSize = 'medium';
  late List<Map<String, dynamic>> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _defaultSectionConfig.map((e) => Map<String, dynamic>.from(e)).toList();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ApiClient.instance.getOne('/me/profile');
      final theme = profile['theme'] as String?;
      final animation = profile['animation'] as String?;
      final avatarSize = profile['avatar_size'] as String?;
      final textSize = profile['text_size'] as String?;
      final rawSections = profile['section_config'] as List<dynamic>?;
      setState(() {
        if (theme != null) _theme = theme;
        if (animation != null) _animation = animation;
        if (avatarSize != null) _avatarSize = avatarSize;
        if (textSize != null) _textSize = textSize;
        if (rawSections != null && rawSections.isNotEmpty) {
          final stored = rawSections
              .cast<Map<String, dynamic>>()
              .where((s) => _sectionLabels.containsKey(s['key']))
              .map((s) => Map<String, dynamic>.from(s))
              .toList();
          // Append any section introduced after this profile last saved its
          // order, so new sections show up here instead of being invisible.
          final knownKeys = stored.map((s) => s['key']).toSet();
          final missing = _defaultSectionConfig
              .where((s) => !knownKeys.contains(s['key']))
              .map((s) => Map<String, dynamic>.from(s));
          _sections = [...stored, ...missing];
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiClient.instance.update('/me/profile', {
        'theme': _theme,
        'animation': _animation,
        'avatar_size': _avatarSize,
        'text_size': _textSize,
        'section_config': _sections,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appearance saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Failed to load: $_error'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Choose the color palette for your public page.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themeOptions.map((option) {
                    final selected = option.key == _theme;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _theme = option.key),
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? option.color : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(radius: 16, backgroundColor: option.color),
                            const SizedBox(height: 6),
                            Text(option.label, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                Text('Animation', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Pick an effect to play on your public page.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _animationOptions.map((option) {
                    final selected = option.key == _animation;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _animation = option.key),
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              option.icon,
                              color: selected ? Theme.of(context).colorScheme.primary : null,
                            ),
                            const SizedBox(height: 6),
                            Text(option.label, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                Text('Avatar size', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _SizePicker(
                  value: _avatarSize,
                  onChanged: (value) => setState(() => _avatarSize = value),
                ),
                const SizedBox(height: 28),
                Text('Text size', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _SizePicker(
                  value: _textSize,
                  onChanged: (value) => setState(() => _textSize = value),
                ),
                const SizedBox(height: 28),
                Text('Section order', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Drag to reorder. Toggle off a section to hide it from your public page.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _sections.removeAt(oldIndex);
                      _sections.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (final section in _sections)
                      _SectionTile(
                        key: ValueKey(section['key']),
                        label: _sectionLabels[section['key']]!,
                        visible: section['visible'] as bool? ?? true,
                        onChanged: (value) => setState(() => section['visible'] = value),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
    );
  }
}

class _SizePicker extends StatelessWidget {
  const _SizePicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: _sizeOptions
          .map((o) => ButtonSegment(value: o.key, label: Text(o.label)))
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required super.key,
    required this.label,
    required this.visible,
    required this.onChanged,
  });

  final _SectionLabel label;
  final bool visible;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(label.icon),
        title: Text(label.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: visible, onChanged: onChanged),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
