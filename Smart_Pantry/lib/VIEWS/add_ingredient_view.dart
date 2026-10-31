import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/DATA/shelf_life.dart';
import 'package:smart_pantry/VIEWS/common_widgets.dart';
import 'package:smart_pantry/VIEWS/expiry_scan_helper.dart';

/// Add a new ingredient, or edit one when [existing] is given.
class IngredientFormView extends ConsumerStatefulWidget {
  const IngredientFormView({super.key, this.existing});
  final Ingredient? existing;

  @override
  ConsumerState<IngredientFormView> createState() => _IngredientFormViewState();
}

class _IngredientFormViewState extends ConsumerState<IngredientFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _qty;
  late final TextEditingController _price;
  late String _unit;
  late String _location;
  late DateTime _expiry;
  late bool _dateTouched;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _qty = TextEditingController(text: e == null ? '1' : Ingredient.formatQty(e.quantity));
    _price = TextEditingController(
        text: (e == null || e.price == 0) ? '' : Ingredient.formatQty(e.price));
    _unit = e?.unit ?? 'pcs';
    _location = e?.location ?? 'Fridge';
    _expiry = e?.expiry ??
        Ingredient.today().add(const Duration(days: ShelfLife.defaultDays));
    _dateTouched = e != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  /// While the user has not picked a date themselves, suggest one from the name.
  void _onNameChanged(String value) {
    if (_dateTouched || _isEdit) return;
    setState(() {
      _expiry = Ingredient.today().add(Duration(days: ShelfLife.daysFor(value)));
      _location = ShelfLife.locationFor(value);
    });
  }

  Future<void> _pickDate() async {
    final today = Ingredient.today();
    final first = DateTime(today.year - 1, today.month, today.day);
    final last = DateTime(today.year + 5, today.month, today.day);
    var initial = DateTime(_expiry.year, _expiry.month, _expiry.day);
    if (initial.isBefore(first)) initial = first; // old dates would crash the picker
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Expiry date',
    );
    if (picked == null) return;
    setState(() {
      _expiry = DateTime.utc(picked.year, picked.month, picked.day);
      _dateTouched = true;
    });
  }

  Future<void> _scanDate() async {
    final date = await scanExpiryDate(context);
    if (date == null || !mounted) return;
    setState(() {
      _expiry = date;
      _dateTouched = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final item = Ingredient(
      id: widget.existing?.id,
      name: _name.text.trim(),
      quantity: double.parse(_qty.text.trim().replaceAll(',', '.')),
      unit: _unit,
      expiryDate: Ingredient.formatDate(_expiry),
      location: _location,
      price: double.tryParse(_price.text.trim().replaceAll(',', '.')) ?? 0,
      addedAt: widget.existing?.addedAt ?? '',
    );

    try {
      final notifier = ref.read(pantryProvider.notifier);
      if (_isEdit) {
        await notifier.updateIngredient(item);
      } else {
        await notifier.add(item);
      }
      navigator.pop();
      showSnack(messenger, _isEdit ? 'Saved changes to ${item.name}' : 'Added ${item.name}');
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      showSnack(messenger, 'Could not save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = {...Ingredient.units, _unit}.toList();
    final daysLeft = Ingredient.daysUntil(_expiry);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit ingredient' : 'Add ingredient')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Ingredient name (e.g., Tomatoes)'),
                onChanged: _onNameChanged,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _qty,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                        return (n == null || n <= 0) ? 'Enter a number above 0' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: [
                        for (final u in units)
                          DropdownMenuItem(value: u, child: Text(u)),
                      ],
                      onChanged: (v) => setState(() => _unit = v ?? _unit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expiry date',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Scan the expiry date on the package',
                          icon: const Icon(Icons.document_scanner_outlined),
                          onPressed: _scanDate,
                        ),
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 12),
                      ],
                    ),
                    helperText: _dateTouched
                        ? null
                        : 'Estimated from the item name - tap to change',
                  ),
                  child: Text(
                    '${Ingredient.formatDate(_expiry)}  ·  ${Ingredient.labelForDays(daysLeft)}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Stored in', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  for (final loc in Ingredient.locations)
                    ButtonSegment(
                        value: loc, icon: Icon(locationIcon(loc)), label: Text(loc)),
                ],
                selected: {_location},
                onSelectionChanged: (s) => setState(() => _location = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price paid in KES (optional)',
                  helperText: 'Used to show how much money you save',
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  final n = double.tryParse(t.replaceAll(',', '.'));
                  return (n == null || n < 0) ? 'Enter a valid amount' : null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: _saving ? null : _save,
                child: Text(_isEdit ? 'Save changes' : 'Save to pantry',
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
