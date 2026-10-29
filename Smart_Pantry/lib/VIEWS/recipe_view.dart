import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/ai_service.dart';
import 'package:smart_pantry/VIEWS/common_widgets.dart';

/// "Expiry Alchemist": turns soon-to-expire pantry items into a recipe.
class RecipeView extends ConsumerStatefulWidget {
  const RecipeView({super.key});

  @override
  ConsumerState<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends ConsumerState<RecipeView> {
  RecipeResult? _result;
  bool _loading = false;

  Future<void> _generate({bool force = false}) async {
    final items = ref.read(pantryProvider).valueOrNull ?? const <Ingredient>[];
    setState(() => _loading = true);
    final result = await AIService.generateRecipe(items, forceRefresh: force);
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(pantryProvider).valueOrNull ?? const <Ingredient>[];
    final urgent = (items.where((i) => !i.isExpired).toList()
          ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)))
        .take(4)
        .toList();
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Expiry Alchemist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Use these first',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (urgent.isEmpty)
            const Text('Nothing usable in your pantry yet. Add some items to get started.',
                style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final i in urgent)
                  Chip(
                    avatar: CircleAvatar(
                        backgroundColor: riskColor(i.risk), radius: 6),
                    label: Text('${i.name} · ${i.shortLabel}'),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: _loading ? null : () => _generate(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Create a zero-waste recipe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          avatar: Icon(
                              result.fromAI ? Icons.auto_awesome : Icons.offline_bolt_outlined,
                              size: 16),
                          label: Text(result.fromAI ? 'Gemini AI' : 'Offline recipe'),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Copy recipe',
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            final messenger = ScaffoldMessenger.of(context);
                            Clipboard.setData(ClipboardData(text: result.text));
                            showSnack(messenger, 'Recipe copied');
                          },
                        ),
                      ],
                    ),
                    if (result.note != null) ...[
                      const SizedBox(height: 4),
                      Text(result.note!,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ],
                    const SizedBox(height: 12),
                    SelectableText(result.text,
                        style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _generate(force: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Another idea'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Tap the button to turn the items closest to expiry into a recipe.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }
}
