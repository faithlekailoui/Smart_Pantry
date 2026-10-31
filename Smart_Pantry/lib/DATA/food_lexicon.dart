// lib/DATA/food_lexicon.dart
//
// Knows what is food. Used for two jobs:
//   1. Receipt scanning: keep food lines, skip detergents, tissue, soap etc.
//   2. Recipe matching: turn an item name such as "BROOKSIDE MILK 500ML" into
//      tags such as {milk} so the recipe book can use it.
// Keywords are lower-case whole words (a plural "s" or "es" is accepted).
// English, Swahili and common Kenyan brand names are included. Receipts are
// messy, so anything not recognised is "unsure" and is left for the user.

enum FoodClass { food, nonFood, unsure }

class FoodLexicon {
  FoodLexicon._();

  static const Map<String, List<String>> tags = {
    'egg': ['egg', 'mayai', 'yai'],
    'eggplant': ['eggplant', 'brinjal', 'aubergine', 'biringanya'],
    'milk': ['milk', 'maziwa', 'uht', 'brookside', 'tuzo', 'fresha', 'daima', 'ilara', 'kcc'],
    'yoghurt': ['yoghurt', 'yogurt', 'mala', 'lala'],
    'cheese': ['cheese', 'cheddar', 'mozzarella', 'jibini'],
    'cream': ['cream'],
    'butter': ['butter', 'blue band', 'blueband', 'margarine', 'kasuku', 'ghee', 'samli'],
    'bread': ['bread', 'loaf', 'loaves', 'bun', 'mkate', 'supaloaf', 'festive', 'broadway', 'broadways'],
    'flour_wheat': ['wheat', 'ngano', 'ajab', 'exe', 'atta', 'all purpose', 'self raising', 'chapati flour', 'baking flour', 'mandazi flour'],
    'flour_maize': ['maize flour', 'maize meal', 'sembe', 'unga', 'jogoo', 'soko', 'dola', 'pembe', 'ugali'],
    'flour_porridge': ['uji', 'millet', 'wimbi', 'sorghum', 'porridge flour'],
    'rice': ['rice', 'mchele', 'pishori', 'basmati', 'wali', 'pearl rice'],
    'pasta': ['pasta', 'spaghetti', 'macaroni', 'penne', 'tagliatelle', 'tambi', 'fusilli'],
    'noodles': ['noodles', 'indomie'],
    'beans': ['beans', 'maharagwe', 'njahi', 'rosecoco', 'kidney'],
    'ndengu': ['ndengu', 'dengu', 'green gram', 'greengram', 'lentil', 'mbaazi', 'kunde', 'cowpea', 'pigeon pea'],
    'maize_kernels': ['maize', 'mahindi', 'githeri', 'corn', 'sweetcorn'],
    'potato': ['potato', 'irish', 'viazi'],
    'sweet_potato': ['sweet potato', 'viazi vitamu'],
    'cassava': ['cassava', 'muhogo'],
    'arrowroot': ['arrow root', 'arrowroot', 'nduma'],
    'banana_cooking': ['matoke', 'plantain', 'cooking banana', 'ndizi mbichi'],
    'banana': ['banana', 'ndizi'],
    'tomato': ['tomato', 'nyanya'],
    'tomato_paste': ['tomato paste', 'tomato sauce', 'ketchup', 'puree', 'tomato puree'],
    'onion': ['onion', 'kitunguu', 'spring onion'],
    'garlic': ['garlic', 'swaumu'],
    'ginger': ['ginger', 'tangawizi'],
    'greens': ['sukuma', 'kale', 'collard', 'spinach', 'mchicha', 'terere', 'managu', 'saget', 'pumpkin leaves', 'mrenda', 'cowpea leaves'],
    'sukuma': ['sukuma', 'kale', 'collard'],
    'spinach': ['spinach', 'mchicha'],
    'cabbage': ['cabbage', 'kabichi'],
    'carrot': ['carrot', 'karoti'],
    'capsicum': ['capsicum', 'green pepper', 'bell pepper', 'pilipili hoho', 'hoho'],
    'chilli': ['chilli', 'chili', 'pilipili'],
    'cucumber': ['cucumber', 'matango'],
    'lettuce': ['lettuce'],
    'peas': ['peas', 'green peas', 'njegere'],
    'green_beans': ['green beans', 'french beans', 'french bean'],
    'pumpkin': ['pumpkin', 'malenge'],
    'herb': ['dhania', 'coriander', 'parsley', 'mint', 'basil', 'celery'],
    'avocado': ['avocado', 'parachichi'],
    'mango': ['mango', 'mangoes', 'embe'],
    'orange': ['orange', 'machungwa'],
    'lemon': ['lemon', 'ndimu', 'lime'],
    'apple': ['apple', 'tufaha'],
    'watermelon': ['watermelon', 'tikiti'],
    'pineapple': ['pineapple', 'nanasi'],
    'grapes': ['grape', 'grapes', 'zabibu'],
    'strawberry': ['strawberry', 'strawberries'],
    'blueberry': ['blueberry', 'blueberries'],
    'kiwi': ['kiwi'],
    'pawpaw': ['pawpaw', 'papaya', 'papai'],
    'passion': ['passion', 'passion fruit'],
    'coconut': ['coconut', 'nazi'],
    'beef': ['beef', 'steak', 'mince', 'minced', 'kima', 'ngombe', 'brisket', 'ribs'],
    'goat': ['goat', 'mbuzi'],
    'chicken': ['chicken', 'kuku', 'kenchic', 'drumstick', 'drumsticks'],
    'pork': ['pork', 'bacon', 'nguruwe'],
    'sausage': ['sausage', 'smokie', 'smokies', 'frankfurter', 'viennas', 'vienna'],
    'fish': ['fish', 'tilapia', 'samaki', 'perch', 'tuna', 'sardine', 'sardines', 'salmon'],
    'omena': ['omena', 'dagaa', 'mukene'],
    'oil': ['oil', 'elianto', 'fresh fri', 'freshfri', 'golden fry', 'kimbo', 'cookmate', 'prestige', 'rina', 'mafuta'],
    'salt': ['salt', 'chumvi', 'kensalt'],
    'sugar': ['sugar', 'sukari', 'mumias', 'kabras', 'chemelil', 'sony sugar'],
    'tea': ['tea', 'chai', 'ketepa', 'tetley', 'kericho gold', 'sasini'],
    'coffee': ['coffee', 'kahawa', 'nescafe'],
    'spice': ['royco', 'mchuzi mix', 'pilau masala', 'masala', 'curry', 'turmeric', 'cumin', 'cardamom', 'hiliki', 'cinnamon', 'mdalasini', 'cloves', 'karafuu', 'pepper', 'paprika', 'spice', 'spices', 'seasoning', 'cube', 'stock', 'rosemary', 'thyme', 'bay leaf', 'garam'],
    'baking': ['baking powder', 'yeast', 'bicarbonate', 'cocoa', 'custard', 'vanilla', 'cornflour', 'corn flour'],
    'spread': ['honey', 'jam', 'peanut butter', 'nutella'],
    'nuts': ['groundnut', 'groundnuts', 'peanut', 'peanuts', 'nuts', 'karanga', 'cashew', 'almonds'],
    'drink': ['juice', 'soda', 'coke', 'coca cola', 'fanta', 'sprite', 'pepsi', 'squash'],
    'snack': ['biscuit', 'cookies', 'cookie', 'crisps', 'chocolate', 'sweets', 'cake', 'muffin', 'samosa', 'mandazi', 'chapati', 'pizza', 'cereal', 'cornflakes', 'weetabix', 'oats'],
    'generic_food': ['fresh', 'frozen', 'tinned', 'canned', 'sauce', 'soup', 'vegetable', 'vegetables', 'fruit', 'fruits', 'meat', 'nyama', 'mboga', 'matunda'],
  };

  // If any blocker word is present, the tag is dropped (e.g. "maize flour" is
  // not maize kernels, "green beans" are not dry beans).
  static const Map<String, List<String>> _blockers = {
    'maize_kernels': ['flour', 'unga', 'sembe', 'meal', 'oil', 'starch', 'ugali'],
    'beans': ['green', 'french'],
    'milk': ['coconut', 'soy', 'almond', 'lotion', 'body'],
    'potato': ['sweet', 'vitamu', 'chips', 'crisps'],
    'banana': ['cooking', 'plantain', 'matoke', 'mbichi'],
    'orange': ['juice', 'squash', 'soda', 'fanta', 'flavour', 'flavor', 'drink'],
    'tomato': ['paste', 'sauce', 'ketchup', 'puree', 'soup'],
    'onion': ['swaumu', 'soup', 'crisps', 'ring'],
    'peas': ['pigeon', 'cow', 'chick', 'split'],
    'apple': ['juice'],
    'mango': ['juice', 'squash', 'drink', 'flavour', 'flavor', 'yoghurt'],
    'pineapple': ['juice', 'squash', 'drink', 'flavour', 'flavor', 'yoghurt'],
    'grapes': ['juice', 'squash', 'drink', 'flavour', 'flavor'],
    'passion': ['juice', 'squash', 'drink', 'flavour', 'flavor'],
    'strawberry': ['juice', 'drink', 'flavour', 'flavor', 'yoghurt', 'jam'],
    'blueberry': ['juice', 'drink', 'flavour', 'flavor', 'yoghurt', 'jam'],
    'chicken': ['stock', 'flavour', 'flavor', 'cube', 'seasoning'],
    'beef': ['stock', 'flavour', 'flavor', 'cube', 'seasoning'],
    'oil': ['hair', 'baby', 'body', 'massage', 'castor', 'engine', 'motor'],
  };

  static const Set<String> fruitTags = {
    'banana', 'orange', 'mango', 'apple', 'watermelon', 'pineapple', 'grapes',
    'strawberry', 'blueberry', 'kiwi', 'pawpaw', 'passion',
  };

  // Strong non-food words always win, even if a food word is also present.
  static const List<String> strongNonFood = [
    'detergent', 'soap', 'omo', 'ariel', 'persil', 'sunlight', 'toilet', 'tissue', 'tissues',
    'bleach', 'jik', 'harpic', 'domestos', 'dettol', 'savlon', 'izal', 'handwash', 'hand wash',
    'sanitizer', 'sanitiser', 'shampoo', 'conditioner', 'lotion', 'toothpaste', 'toothbrush',
    'colgate', 'sensodyne', 'razor', 'deodorant', 'perfume', 'insecticide', 'doom', 'mortein',
    'repellent', 'sanitary', 'tampon', 'tampons', 'kotex', 'diaper', 'diapers', 'nappy', 'nappies',
    'pampers', 'huggies', 'softcare', 'velvex', 'zesta', 'kleenex', 'vaseline', 'nivea', 'rexona',
    'cussons', 'imperial leather', 'lifebuoy', 'geisha', 'protex', 'battery', 'batteries', 'bulb',
    'candle', 'matchbox', 'polythene', 'garbage', 'sponge', 'scourer', 'mop', 'broom', 'disinfectant',
    'freshener', 'softener', 'downy', 'comfort', 'airtime', 'charger', 'wipes', 'washing', 'dishwash',
    'dish wash', 'fabric', 'cleaner', 'laundry', 'dog food', 'cat food', 'baby oil', 'hair oil',
    'body oil', 'body cream', 'hand cream', 'face cream', 'shaving', 'toilet paper', 'kitchen roll',
  ];

  // Weak non-food words only apply when no food word is found ("tea bags" is food).
  static const List<String> weakNonFood = [
    'bag', 'bags', 'paper', 'foil', 'wrap', 'brush', 'cloth', 'cup', 'plate', 'bottle', 'pen',
    'book', 'gas', 'charcoal', 'pad', 'pads', 'tape', 'glue', 'towel', 'cotton', 'plastic',
    'spray', 'pet', 'carrier', 'lighter', 'matches', 'sufuria', 'jiko', 'spoon', 'fork', 'knife',
  ];

  static final Map<String, Set<String>> _memo = {};

  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll("'", '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

  static bool _has(String t, String kw) =>
      RegExp('(^| )$kw(s|es)?( |\$)').hasMatch(t);

  /// Tags describing what an item is, e.g. "BROOKSIDE MILK 500ML" -> {milk}.
  static Set<String> tagsFor(String name) {
    final t = normalize(name);
    final cached = _memo[t];
    if (cached != null) return cached;

    final found = <String>{};
    tags.forEach((tag, words) {
      if (tag == 'generic_food') return;
      for (final w in words) {
        if (_has(t, w)) {
          found.add(tag);
          break;
        }
      }
    });
    _blockers.forEach((tag, words) {
      if (found.contains(tag) && words.any((w) => _has(t, w))) found.remove(tag);
    });
    // "unga ngano" is wheat flour, not maize flour.
    if (found.contains('flour_wheat') && !(_has(t, 'maize') || _has(t, 'sembe'))) {
      found.remove('flour_maize');
    }
    if (found.any(fruitTags.contains)) found.add('fruit');

    _memo[t] = found;
    return found;
  }

  static FoodClass classify(String name) {
    final t = normalize(name);
    if (t.isEmpty) return FoodClass.unsure;
    if (strongNonFood.any((k) => _has(t, k))) return FoodClass.nonFood;
    if (tagsFor(name).isNotEmpty) return FoodClass.food;
    if (tags['generic_food']!.any((k) => _has(t, k))) return FoodClass.food;
    if (weakNonFood.any((k) => _has(t, k))) return FoodClass.nonFood;
    return FoodClass.unsure;
  }
}
