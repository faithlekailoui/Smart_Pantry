import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/database_helper.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/VIEWS/add_ingredient_view.dart';
import 'package:smart_pantry/VIEWS/common_widgets.dart';
import 'package:smart_pantry/VIEWS/scan_receipt_view.dart';

/// Bento-style pantry: the most urgent item gets a wide "use first" tile and
/// everything else sits in a two-column grid, each tile tinted by risk.
class PantryHomeView extends ConsumerWidget {
  const PantryHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantry = ref.watch(pantryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        actions: [
          IconButton(
            tooltip: 'Scan a receipt',
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScanReceiptView())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const IngredientFormView())),
      ),
      body: pantry.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text('Could not load your pantry.\n$e',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: () => ref.invalidate(pantryProvider),
                    child: const Text('Try again')),
              ],
            ),
          ),
        ),
        data: (_) => const _PantryBody(),
      ),
    );
  }
}

class _PantryBody extends ConsumerWidget {
  const _PantryBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(visibleIngredientsProvider);
    final total = ref.watch(pantryProvider).valueOrNull?.length ?? 0;

    final slivers = <Widget>[const SliverToBoxAdapter(child: _PantryHeader())];

    if (items.isEmpty) {
      slivers.add(SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(hasItems: total > 0),
      ));
    } else {
      slivers.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        sliver: SliverToBoxAdapter(
          child: _IngredientTile(
              key: ValueKey('f${items.first.id}'),
              item: items.first,
              featured: true),
        ),
      ));
      if (items.length > 1) {
        slivers.add(SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 132,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _IngredientTile(
                key: ValueKey(items[i + 1].id),
                item: items[i + 1],
                featured: false,
              ),
              childCount: items.length - 1,
            ),
          ),
        ));
      } else {
        slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 96)));
      }
    }
    return CustomScrollView(slivers: slivers);
  }
}

class _PantryHeader extends ConsumerWidget {
  const _PantryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(locationFilterProvider);
    final all = ref.watch(pantryProvider).valueOrNull ?? const <Ingredient>[];
    final urgent = all.where((i) => i.risk == RiskLevel.high).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Search your pantry',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == null,
                  onSelected: (_) =>
                      ref.read(locationFilterProvider.notifier).state = null,
                ),
                for (final loc in Ingredient.locations) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(locationIcon(loc), size: 16),
                    label: Text(loc),
                    selected: filter == loc,
                    onSelected: (_) =>
                        ref.read(locationFilterProvider.notifier).state = loc,
                  ),
                ],
              ],
            ),
          ),
          if (urgent > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      urgent == 1
                          ? '1 item needs attention - use it first.'
                          : '$urgent items need attention - use them first.',
                      style: TextStyle(
                          color: Colors.red.shade700, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasItems});
  final bool hasItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(hasItems ? Icons.search_off : Icons.inventory_2_outlined,
              size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            hasItems ? 'No items match your search.' : 'Your pantry is empty.',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            hasItems
                ? 'Try another word or location.'
                : 'Tap "Add item" or scan a receipt to start tracking.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends ConsumerWidget {
  const _IngredientTile({super.key, required this.item, required this.featured});
  final Ingredient item;
  final bool featured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = riskColor(item.risk);
    final radius = BorderRadius.circular(18);

    final content = featured
        ? Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('USE FIRST',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    const SizedBox(height: 4),
                    Text(item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(locationIcon(item.location), size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text('${item.quantityLabel} · ${item.location}'),
                    ]),
                    const SizedBox(height: 2),
                    Text(item.expiryLabel,
                        style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              RiskBadge(item: item),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(locationIcon(item.location), size: 18, color: Colors.grey.shade700),
                const Spacer(),
                RiskBadge(item: item),
              ]),
              const Spacer(),
              Text(item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(item.quantityLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
          );

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _showActions(context, ref),
        child: Container(
          padding: EdgeInsets.all(featured ? 18 : 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: content,
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(pantryProvider.notifier);

    Future<void> guarded(Future<void> Function() action, String done) async {
      try {
        await action();
        showSnack(messenger, done);
      } catch (e) {
        showSnack(messenger, 'Something went wrong: $e');
      }
    }

    final useAmount = item.quantity < 1 ? item.quantity : 1.0;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${item.quantityLabel} · ${item.location} · ${item.expiryLabel}'),
              trailing: RiskBadge(item: item),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: Text('Use ${Ingredient.formatQty(useAmount)} ${item.unit}'),
              onTap: () {
                Navigator.pop(ctx);
                guarded(() => notifier.use(item, useAmount),
                    'Used ${Ingredient.formatQty(useAmount)} ${item.unit} of ${item.name}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('Finished - I used it all'),
              onTap: () {
                Navigator.pop(ctx);
                guarded(() => notifier.remove(item, RemoveReason.finished),
                    'Nice! ${item.name} was used before it spoiled.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Thrown away (spoiled)'),
              onTap: () {
                Navigator.pop(ctx);
                guarded(() => notifier.remove(item, RemoveReason.discarded),
                    '${item.name} logged as wasted.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => IngredientFormView(existing: item)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('Entered by mistake (remove, not counted)'),
              onTap: () {
                Navigator.pop(ctx);
                guarded(() => notifier.remove(item, RemoveReason.mistake),
                    '${item.name} removed.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
