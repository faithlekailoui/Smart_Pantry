import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/database_helper.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/ai_service.dart';
import 'package:smart_pantry/SERVICES/recipe_engine.dart';
import 'package:smart_pantry/VIEWS/common_widgets.dart';

/// Expiry Alchemist - the Mystery Box. Pick items (the ones about to expire are
/// pre-selected), open the box, and get Kenyan dishes you can actually cook.
class RecipeView extends ConsumerStatefulWidget {
  const RecipeView({super.key});

  @override
  ConsumerState<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends ConsumerState<RecipeView> {
  static const int _maxBox = 8;
  static const Map<String, String> _meals = {
    'any': 'Any',
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
  };

  final Set<int> _boxIds = {};
  bool _initialised = false;
  String _meal = 'any';
  bool _opened = false;
  List<RecipeMatch> _cookable = [];
  List<RecipeMatch> _almost = [];
  RecipeCard? _aiCard;
  String? _aiMessage;
  bool _aiLoading = false;

  List<Ingredient> _usable(List<Ingredient> all) =>
      (all.where((i) => !i.isExpired && i.id != null).toList()
        ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)));

  void _autoPick(List<Ingredient> usable) {
    _boxIds
      ..clear()
      ..addAll(usable.take(5).map((i) => i.id!));
  }

  List<Ingredient> _box(List<Ingredient> usable) =>
      usable.where((i) => _boxIds.contains(i.id)).toList();

  void _toggle(Ingredient item, bool selected) {
    final messenger = ScaffoldMessenger.of(context);
    if (selected && _boxIds.length >= _maxBox) {
      showSnack(messenger, 'A box holds up to $_maxBox items. Untick one first.');
      return;
    }
    setState(() {
      if (selected) {
        _boxIds.add(item.id!);
      } else {
        _boxIds.remove(item.id);
      }
      _opened = false;
    });
  }

  void _openBox(List<Ingredient> box) {
    setState(() {
      _cookable = RecipeEngine.cookable(box, meal: _meal);
      _almost = RecipeEngine.almost(box, meal: _meal);
      _opened = true;
      _aiCard = null;
      _aiMessage = null;
    });
  }

  Future<void> _askAi(List<Ingredient> box) async {
    setState(() => _aiLoading = true);
    final out = await AIService.suggest(box, meal: _meal, forceRefresh: _aiCard != null);
    if (!mounted) return;
    setState(() {
      _aiCard = out.card;
      _aiMessage = out.message;
      _aiLoading = false;
    });
  }

  Future<void> _cooked(RecipeCard card) async {
    final selected = <Ingredient>{};
    final result = await showDialog<Set<Ingredient>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Nice cooking!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Tick the items you used up completely. They are marked as finished, which counts as food saved.'),
                for (final i in card.usedItems)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: selected.contains(i),
                    title: Text('${i.name} (${i.quantityLabel})'),
                    onChanged: (v) => setLocal(() {
                      if (v == true) {
                        selected.add(i);
                      } else {
                        selected.remove(i);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Skip')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, selected), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(pantryProvider.notifier);
    try {
      for (final item in result) {
        await notifier.remove(item, RemoveReason.finished);
      }
      if (!mounted) return;
      setState(() {
        _boxIds.removeWhere((id) => result.any((i) => i.id == id));
        _opened = false;
        _cookable = [];
        _almost = [];
        _aiCard = null;
      });
      showSnack(messenger, '${result.length} item${result.length == 1 ? '' : 's'} marked as finished.');
    } catch (e) {
      showSnack(messenger, 'Something went wrong: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(pantryProvider).valueOrNull ?? const <Ingredient>[];
    final usable = _usable(all);
    if (!_initialised && usable.isNotEmpty) {
      _autoPick(usable);
      _initialised = true;
    }
    _boxIds.removeWhere((id) => !usable.any((i) => i.id == id));
    final box = _box(usable);

    return Scaffold(
      appBar: AppBar(title: const Text('Expiry Alchemist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Your Mystery Box',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Items closest to expiry are already in the box. Tap to swap. Salt, oil, water, pepper and sugar are always allowed, like the MasterChef pantry.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          if (usable.isEmpty)
            const Text('Nothing usable in your pantry yet. Add some food first.',
                style: TextStyle(color: Colors.grey))
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final i in usable)
                  FilterChip(
                    avatar: CircleAvatar(backgroundColor: riskColor(i.risk), radius: 6),
                    label: Text('${i.name} · ${i.shortLabel}'),
                    selected: _boxIds.contains(i.id),
                    onSelected: (v) => _toggle(i, v),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _autoPick(usable);
                  _opened = false;
                }),
                icon: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Pick the items expiring first'),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final e in _meals.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: _meal == e.key,
                    onSelected: (_) => setState(() {
                      _meal = e.key;
                      _opened = false;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: box.isEmpty ? null : () => _openBox(box),
              icon: const Icon(Icons.inventory_2),
              label: Text('Open the box (${box.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
          if (_opened) ...[
            const SizedBox(height: 20),
            if (_cookable.isEmpty)
              const _InfoCard(
                icon: Icons.search_off,
                text:
                    'No dish in the recipe book fits these items on their own. Try adding an item that goes with them (onion, tomato or flour often help), or pick a different meal.',
              )
            else ...[
              Text('You can cook',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              for (final m in _cookable)
                _RecipeCardTile(card: m.toCard(), onCooked: _cooked),
            ],
            if (_almost.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Almost there',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              for (final m in _almost)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_shopping_cart),
                  title: Text(m.recipe.title),
                  subtitle: Text(
                      'Add ${m.missingRequired.first.label.toLowerCase()} to unlock this dish.'),
                ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: _aiLoading ? null : () => _askAi(box),
              icon: const Icon(Icons.auto_awesome),
              label: Text(_aiCard == null ? 'Ask the AI chef for another idea' : 'Another AI idea'),
            ),
            if (_aiLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_aiMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_aiMessage!, style: TextStyle(color: Colors.grey.shade700)),
              ),
            if (_aiCard != null) _RecipeCardTile(card: _aiCard!, onCooked: _cooked, expanded: true),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _RecipeCardTile extends StatelessWidget {
  const _RecipeCardTile({required this.card, required this.onCooked, this.expanded = false});
  final RecipeCard card;
  final Future<void> Function(RecipeCard) onCooked;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isAi = card.source == RecipeSource.ai;
    final pantry = card.lines.where((l) => l.kind == LineKind.pantry);
    final optional = card.lines.where((l) => l.kind == LineKind.optional);
    final extra = card.lines.where((l) => l.kind == LineKind.extra);
    final staple = card.lines.where((l) => l.kind == LineKind.staple);
    final uses = card.usedItems.map((i) => i.name).join(', ');

    Widget section(String title, Iterable<RecipeLine> lines, IconData icon, Color color) {
      if (lines.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(child: Text(l.text)),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(card.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${card.minutes} min · serves ${card.servings}\nUses: $uses'),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: Icon(isAi ? Icons.auto_awesome : Icons.menu_book, size: 16),
              label: Text(isAi ? 'AI chef · checked against your pantry' : 'Recipe book'),
            ),
          ),
          section('From your box', pantry, Icons.check_circle, Colors.green),
          section('Extra to buy', extra, Icons.shopping_basket, Colors.orange),
          section('Optional', optional, Icons.add_circle_outline, Colors.grey),
          section('Staples you already have', staple, Icons.kitchen, Colors.grey),
          const SizedBox(height: 12),
          const Text('Steps', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var i = 0; i < card.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${i + 1}. ${card.steps[i]}'),
            ),
          if (card.tip.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Tip: ${card.tip}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => onCooked(card),
            icon: const Icon(Icons.restaurant),
            label: const Text('I cooked this'),
          ),
        ],
      ),
    );
  }
}
