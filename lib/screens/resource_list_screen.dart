import 'package:flutter/material.dart';
import '../models/field_spec.dart';
import '../services/api_client.dart';
import 'resource_form_screen.dart';

class ResourceListScreen extends StatefulWidget {
  const ResourceListScreen({super.key, required this.config});

  final ResourceConfig config;

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.list(widget.config.path);
  }

  void _reload() => setState(() => _future = ApiClient.instance.list(widget.config.path));

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResourceFormScreen(
          title: item == null ? 'Add ${widget.config.title}' : 'Edit ${widget.config.title}',
          fields: widget.config.fields,
          initialValues: item ?? const {},
          onSave: (data) => item == null
              ? ApiClient.instance.create(widget.config.path, data)
              : ApiClient.instance.update('${widget.config.path}/${item['id']}', data),
        ),
      ),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this item?'),
        content: Text(item[widget.config.titleField]?.toString() ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ApiClient.instance.delete('${widget.config.path}/${item['id']}');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Nothing here yet. Tap + to add one.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item[widget.config.titleField]?.toString() ?? ''),
                  subtitle: widget.config.subtitleField != null
                      ? Text(item[widget.config.subtitleField]?.toString() ?? '')
                      : null,
                  onTap: () => _openForm(item: item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
