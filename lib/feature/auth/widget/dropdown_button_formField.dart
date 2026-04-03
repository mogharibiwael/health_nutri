import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoleDropdown extends StatelessWidget {
  final String? value;
  final List<String> items; // مثل ["patient","doctor"]
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const RoleDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !enabled
          ? null
          : () async {
        final picked = await showModalBottomSheet<String?>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => _RolePickerSheet(
            selected: value,
            items: items,
          ),
        );
        if (picked != null || value != null) {
          // picked can be null only if user chooses "clear"
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "roleOptional".tr,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabled: enabled,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? "selectRole".tr : value!.tr,
                style: TextStyle(
                  color: value == null
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}

class _RolePickerSheet extends StatefulWidget {
  final String? selected;
  final List<String> items;

  const _RolePickerSheet({
    required this.selected,
    required this.items,
  });

  @override
  State<_RolePickerSheet> createState() => _RolePickerSheetState();
}

class _RolePickerSheetState extends State<_RolePickerSheet> {
  final TextEditingController _search = TextEditingController();
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List<String>.from(widget.items);
    _search.addListener(() {
      final q = _search.text.trim().toLowerCase();
      setState(() {
        _filtered = widget.items
            .where((e) => e.tr.toLowerCase().contains(q) || e.toLowerCase().contains(q))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    "selectRole".tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop<String?>(context, null),
                  child: Text("clear".tr),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Search
            TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "search".tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 10),

            // List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = _filtered[i];
                  final selected = item == widget.selected;
                  return ListTile(
                    title: Text(item.tr),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded)
                        : const SizedBox.shrink(),
                    onTap: () => Navigator.pop<String?>(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
