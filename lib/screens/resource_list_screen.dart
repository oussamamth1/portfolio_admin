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
          ? const Center(child: Text('Nothing here yet. Tap + to add one.'))
          : RefreshIndicator(
              onRefresh: _load,
              child: _reorderable
                  ? ReorderableListView.builder(
                      itemCount: _items.length,
                      onReorder: _reorder,
                      itemBuilder: (context, index) => _buildTile(_items[index], key: true),
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) => _buildTile(_items[index]),
                    ),
            ),
    );
  }

  Widget _buildTile(Map<String, dynamic> item, {bool key = false}) {
    return ListTile(
      key: key ? ValueKey(item['id']) : null,
      title: Text(item[widget.config.titleField]?.toString() ?? ''),
      subtitle: widget.config.subtitleField != null
          ? Text(item[widget.config.subtitleField]?.toString() ?? '')
          : null,
      onTap: () => _openForm(item: item),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(item),
          ),
          if (_reorderable) const Icon(Icons.drag_handle),
        ],
      ),
    );
  }
}
