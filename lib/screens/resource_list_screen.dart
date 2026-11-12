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
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  bool get _reorderable => widget.config.fields.any((f) => f.key == 'sort_order');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ApiClient.instance.list(widget.config.path);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
    if (saved == true) _load();
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
    _load();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    await Future.wait([
      for (var i = 0; i < _items.length; i++)
        ApiClient.instance.update('${widget.config.path}/${_items[i]['id']}', {'sort_order': i}),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Failed to load: $_error'))
          : _items.isEmpty
          ? _EmptyState(config: widget.config)
          : RefreshIndicator(
              onRefresh: _load,
              child: _reorderable
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                      itemCount: _items.length,
                      onReorder: _reorder,
                      itemBuilder: (context, index) => _ResourceCard(
                        key: ValueKey(_items[index]['id']),
                        config: widget.config,
                        item: _items[index],
                        reorderable: true,
                        index: index,
                        onTap: () => _openForm(item: _items[index]),
                        onDelete: () => _delete(_items[index]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                      itemCount: _items.length,
                      itemBuilder: (context, index) => _ResourceCard(
                        config: widget.config,
                        item: _items[index],
                        reorderable: false,
                        index: index,
                        onTap: () => _openForm(item: _items[index]),
                        onDelete: () => _delete(_items[index]),
                      ),
                    ),
            ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    super.key,
    required this.config,
    required this.item,
    required this.reorderable,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final ResourceConfig config;
  final Map<String, dynamic> item;
  final bool reorderable;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Icon(config.icon, size: 20),
          ),
          title: Text(
            item[config.titleField]?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: config.subtitleField != null
              ? Text(item[config.subtitleField]?.toString() ?? '')
              : null,
          onTap: onTap,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.outline),
                onPressed: onDelete,
              ),
              if (reorderable)
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle, color: colorScheme.outline),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.config});
  final ResourceConfig config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Icon(config.icon, size: 28),
          ),
          const SizedBox(height: 16),
          Text('No ${config.title.toLowerCase()} yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Tap + to add one.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
