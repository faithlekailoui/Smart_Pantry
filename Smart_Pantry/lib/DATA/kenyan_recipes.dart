// lib/DATA/kenyan_recipes.dart
//
// A small recipe book of everyday Kenyan home dishes. Each recipe lists
// "slots": the kinds of ingredient it needs (matched to pantry items through
// FoodLexicon tags). Required slots must be filled; optional slots improve the
// dish. Salt, oil, water, pepper and sugar are always assumed to be at home,
// like the staples under the bench in a MasterChef mystery box challenge.

class RecipeSlot {
  final String label;
  final String amount;
  final Set<String> tags;
  final int min; // how many different pantry items are needed
  final bool required;
  RecipeSlot(this.label, this.amount, List<String> tags,
      {this.min = 1, this.required = true})
      : tags = tags.toSet();
}

class BookRecipe {
  final String id;
  final String title;
  final Set<String> meals; // breakfast, lunch, dinner, snack
  final int minutes;
  final int servings;
  final List<RecipeSlot> slots;
  final List<String> staples;
  final List<String> steps;
  final String tip;
  BookRecipe(
    this.id,
    this.title, {
    required List<String> meals,
    required this.minutes,
    required this.servings,
    required this.slots,
    required this.staples,
    required this.steps,
    this.tip = '',
  }) : meals = meals.toSet();
}

RecipeSlot _r(String label, String amount, List<String> tags, {int min = 1}) =>
    RecipeSlot(label, amount, tags, min: min);
RecipeSlot _o(String label, String amount, List<String> tags) =>
    RecipeSlot(label, amount, tags, required: false);

const _anyMeat = ['beef', 'chicken', 'goat'];

final List<BookRecipe> kenyanRecipes = [
  BookRecipe('mayai', 'Mayai with tomato and onion',
      meals: ['breakfast', 'snack', 'lunch'], minutes: 10, servings: 2,
      slots: [
        _r('Eggs', '4', ['egg']),
        _o('Tomato', '1 medium, chopped', ['tomato']),
        _o('Onion', '1 small, chopped', ['onion']),
        _o('Greens', 'a handful, chopped fine', ['greens']),
      ],
      staples: ['Cooking oil - 1 tbsp', 'Salt - a pinch'],
      steps: [
        'Heat the oil in a pan on medium heat.',
        'If you have onion, fry it for 2 minutes until soft.',
        'Add the tomato (and greens, if using) and cook 3 minutes until soft.',
        'Beat the eggs with a pinch of salt, pour them in and stir gently for 2 to 3 minutes until just set.',
        'Serve hot with bread, chapati or ugali.'
      ],
      tip: 'Take the pan off the heat while the eggs still look slightly wet; they finish cooking on the plate.'),
  BookRecipe('eggbread', 'Egg bread (French toast)',
      meals: ['breakfast', 'snack'], minutes: 15, servings: 2,
      slots: [
        _r('Bread', '4 slices', ['bread']),
        _r('Eggs', '2', ['egg']),
        _o('Milk', '3 tbsp', ['milk']),
      ],
      staples: ['Cooking oil - 1 tbsp', 'Salt - a pinch', 'Sugar - 1 tsp (optional)'],
      steps: [
        'Beat the eggs with the milk (if using), the salt and the sugar in a shallow dish.',
        'Heat a little oil in a pan on medium-low heat.',
        'Dip each slice of bread in the egg mixture for a few seconds on each side.',
        'Fry 2 to 3 minutes on each side until golden.',
        'Serve warm with tea.'
      ],
      tip: 'A great way to finish bread that is a day or two old.'),
  BookRecipe('avocadotoast', 'Avocado on toast',
      meals: ['breakfast', 'snack'], minutes: 8, servings: 2,
      slots: [
        _r('Avocado', '1 ripe', ['avocado']),
        _r('Bread', '2 to 4 slices', ['bread']),
        _o('Tomato', '1, sliced', ['tomato']),
        _o('Eggs', '2, fried', ['egg']),
        _o('Lemon', 'a squeeze', ['lemon']),
      ],
      staples: ['Salt and pepper - to taste'],
      steps: [
        'Toast the bread in a dry pan or toaster until crisp.',
        'Mash the avocado with salt, pepper and a squeeze of lemon if you have it.',
        'Spread on the toast and top with tomato slices or a fried egg.'
      ]),
  BookRecipe('chapati', 'Soft chapati',
      meals: ['lunch', 'dinner', 'breakfast'], minutes: 45, servings: 3,
      slots: [
        _r('Wheat flour', '2 cups', ['flour_wheat']),
        _o('Milk', '1/4 cup (makes it softer)', ['milk']),
      ],
      staples: ['Cooking oil - 4 tbsp', 'Salt - 1/2 tsp', 'Warm water - about 3/4 cup'],
      steps: [
        'Mix the flour and salt, then add 1 tbsp oil and the warm water (and milk) a little at a time.',
        'Knead for 8 to 10 minutes until the dough is soft and smooth, then rest it for 20 minutes.',
        'Divide into 6 balls. Roll each into a thin circle, brush with oil, roll it up like a rope, coil it and rest 5 minutes.',
        'Roll each coil out again into a circle.',
        'Cook on a hot dry pan for about 1 minute, flip, brush with oil and cook until golden spots appear, 1 to 2 minutes each side.',
        'Keep wrapped in a clean cloth so they stay soft.'
      ],
      tip: 'The coiling step is what makes the layers.'),
  BookRecipe('mandazi', 'Mandazi',
      meals: ['breakfast', 'snack'], minutes: 40, servings: 4,
      slots: [
        _r('Wheat flour', '2 cups', ['flour_wheat']),
        _o('Milk', '1/2 cup', ['milk']),
      ],
      staples: ['Sugar - 3 tbsp', 'Baking powder - 1 tsp (recommended)', 'Cooking oil - for frying', 'Cardamom - a pinch (optional)'],
      steps: [
        'Mix the flour, sugar, baking powder and cardamom.',
        'Add the milk (or water) a little at a time and knead into a soft dough. Rest 20 minutes.',
        'Roll out about 1 cm thick and cut into triangles.',
        'Heat oil on medium heat and fry the mandazi 2 to 3 minutes on each side until puffed and golden.',
        'Drain on paper and serve with chai.'
      ],
      tip: 'If the oil is too hot they brown outside and stay raw inside; keep the heat medium.'),
  BookRecipe('uji', 'Uji (porridge)',
      meals: ['breakfast'], minutes: 20, servings: 2,
      slots: [
        _r('Porridge or maize flour', '4 tbsp', ['flour_maize', 'flour_porridge']),
        _o('Milk', '1 cup', ['milk']),
        _o('Lemon', 'a squeeze', ['lemon']),
      ],
      staples: ['Water - 3 cups', 'Sugar - to taste'],
      steps: [
        'Mix the flour with 1/2 cup cold water into a smooth paste.',
        'Bring 2 1/2 cups water to the boil.',
        'Add the paste slowly, stirring all the time so there are no lumps.',
        'Simmer 10 to 15 minutes until thick and cooked, with no raw flour taste.',
        'Add the milk and sugar and simmer 2 more minutes. A little lemon juice gives a nice sour note.'
      ]),
  BookRecipe('chai', 'Kenyan milk tea (chai)',
      meals: ['breakfast', 'snack'], minutes: 10, servings: 2,
      slots: [
        _r('Tea', '2 tsp leaves or 2 tea bags', ['tea']),
        _r('Milk', '1 cup', ['milk']),
        _o('Ginger', 'a small piece, crushed', ['ginger']),
      ],
      staples: ['Water - 1 cup', 'Sugar - to taste'],
      steps: [
        'Boil the water with the tea (and ginger) for 2 minutes.',
        'Add the milk and bring to the boil, then simmer 2 to 3 minutes. Watch it so it does not boil over.',
        'Sweeten, strain and serve hot.'
      ],
      tip: 'A good use for milk that is close to its date.'),
  BookRecipe('banana_shake', 'Banana milkshake',
      meals: ['breakfast', 'snack'], minutes: 5, servings: 2,
      slots: [
        _r('Ripe bananas', '2', ['banana']),
        _r('Milk or yoghurt', '1 cup', ['milk', 'yoghurt']),
      ],
      staples: ['Sugar or honey - optional'],
      steps: [
        'Peel and slice the bananas.',
        'Blend with the milk until smooth, or mash well and whisk by hand.',
        'Serve chilled.'
      ],
      tip: 'Very ripe bananas need no sugar.'),
  BookRecipe('fruit_salad', 'Fruit salad',
      meals: ['snack', 'breakfast'], minutes: 10, servings: 3,
      slots: [
        _r('Fruit', '2 to 4 kinds, bite-size', ['fruit'], min: 2),
        _o('Yoghurt', '1/2 cup', ['yoghurt']),
        _o('Lemon', 'juice of 1/2', ['lemon']),
      ],
      staples: [],
      steps: [
        'Wash the fruit, peel it and cut into bite-size pieces.',
        'Mix in a bowl. Squeeze lemon over bananas or apples so they do not turn brown.',
        'Top with yoghurt and chill for 15 minutes before serving.'
      ]),
  BookRecipe('ugali_sukuma', 'Ugali na sukuma wiki',
      meals: ['lunch', 'dinner'], minutes: 35, servings: 3,
      slots: [
        _r('Maize flour', '2 cups', ['flour_maize']),
        _r('Sukuma wiki or other greens', '1 bunch (about 500 g), sliced fine', ['greens']),
        _o('Tomato', '1 to 2, chopped', ['tomato']),
        _o('Onion', '1, chopped', ['onion']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water - 3 cups'],
      steps: [
        'Sukuma: heat the oil, fry the onion 2 minutes, add the tomato and cook 3 minutes.',
        'Add the greens and a pinch of salt and cook 5 to 7 minutes, stirring. Do not overcook; keep them green.',
        'Ugali: bring 3 cups of water to the boil in a heavy pot and lower the heat.',
        'Add the maize flour a little at a time, stirring with a wooden spoon until thick. Cover and cook 5 minutes.',
        'Stir firmly for 5 more minutes until the ugali is smooth and leaves the sides of the pot.',
        'Serve the ugali hot with the sukuma.'
      ]),
  BookRecipe('sukuma', 'Sukuma wiki stir-fry',
      meals: ['lunch', 'dinner'], minutes: 15, servings: 3,
      slots: [
        _r('Sukuma wiki or other greens', '1 bunch, sliced fine', ['greens']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '1 to 2, chopped', ['tomato']),
        _o('Eggs', '2, beaten (adds protein)', ['egg']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt'],
      steps: [
        'Heat the oil and fry the onion for 2 minutes.',
        'Add the tomato and cook until soft.',
        'Add the greens and salt and stir-fry 5 to 7 minutes.',
        'If using eggs, push the greens aside, scramble the eggs and mix in.',
        'Serve with ugali, chapati or rice.'
      ]),
  BookRecipe('beef_stew', 'Beef stew',
      meals: ['lunch', 'dinner'], minutes: 90, servings: 4,
      slots: [
        _r('Beef', '500 g, cubed (or minced)', ['beef']),
        _o('Potatoes', '2 medium, cubed', ['potato']),
        _o('Carrot', '1, sliced', ['carrot']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '2, chopped', ['tomato']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water - 2 cups', 'Royco or curry powder - optional'],
      steps: [
        'Boil the beef with salt and enough water for 45 to 60 minutes until nearly tender (about 20 minutes in a pressure cooker). Skip this step for minced beef; brown it in the pan instead.',
        'In a separate pot heat the oil and fry the onion until golden.',
        'Add the tomato and cook to a thick paste.',
        'Add the beef with 1 cup of its stock, then the potato and carrot.',
        'Simmer 20 minutes until the vegetables are soft and the gravy is thick. Adjust the salt.'
      ]),
  BookRecipe('chicken_stew', 'Chicken stew',
      meals: ['lunch', 'dinner'], minutes: 60, servings: 4,
      slots: [
        _r('Chicken', 'about 600 g, in pieces', ['chicken']),
        _o('Potatoes', '2 medium, cubed', ['potato']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '2, chopped', ['tomato']),
        _o('Carrot', '1, sliced', ['carrot']),
      ],
      staples: ['Cooking oil - 3 tbsp', 'Salt and pepper', 'Water - 1 cup'],
      steps: [
        'Season the chicken with salt and pepper and brown it in hot oil for about 8 minutes. Remove it.',
        'In the same pot fry the onion, then the tomato, for 5 minutes.',
        'Return the chicken, add the water, cover and simmer 25 to 30 minutes.',
        'Add the potato and carrot for the last 15 minutes.',
        'Check the chicken is cooked through (the juices run clear) before serving.'
      ]),
  BookRecipe('githeri', 'Githeri',
      meals: ['lunch', 'dinner'], minutes: 120, servings: 4,
      slots: [
        _r('Dry maize', '2 cups', ['maize_kernels']),
        _r('Beans', '1 cup, soaked overnight', ['beans']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '2, chopped', ['tomato']),
        _o('Potatoes', '1 to 2, cubed', ['potato']),
        _o('Carrot', '1, diced', ['carrot']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water'],
      steps: [
        'Boil the maize and soaked beans together in plenty of water for 1 1/2 to 2 hours until soft (30 to 40 minutes in a pressure cooker). Top up with hot water if needed.',
        'Heat the oil in another pot and fry the onion until golden, then add the tomato and cook to a paste.',
        'Add the boiled maize and beans with a little of the cooking water. Add potato and carrot now if using.',
        'Season with salt and simmer 15 to 20 minutes until thick.'
      ]),
  BookRecipe('beans', 'Bean stew (maharagwe)',
      meals: ['lunch', 'dinner'], minutes: 100, servings: 4,
      slots: [
        _r('Beans', '2 cups, soaked overnight', ['beans']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '2, chopped', ['tomato']),
        _o('Carrot', '1, diced', ['carrot']),
        _o('Potatoes', '1, cubed', ['potato']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water'],
      steps: [
        'Boil the soaked beans for 1 to 1 1/2 hours until tender.',
        'Fry the onion in oil until golden, add the tomato and cook to a paste.',
        'Add the beans with some of their water, and the potato and carrot if using.',
        'Simmer 15 minutes until thick. Serve with rice, chapati or ugali.'
      ]),
  BookRecipe('ndengu', 'Ndengu (green gram stew)',
      meals: ['lunch', 'dinner'], minutes: 60, servings: 4,
      slots: [
        _r('Green grams (ndengu)', '1 1/2 cups', ['ndengu']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '2, chopped', ['tomato']),
        _o('Garlic', '2 cloves', ['garlic']),
        _o('Coconut milk', '1/2 cup', ['coconut']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water'],
      steps: [
        'Wash the ndengu and boil 30 to 40 minutes until soft, adding water as needed.',
        'Fry the onion and garlic in oil, then add the tomato and cook to a paste.',
        'Add the ndengu (and coconut milk if using) and simmer 10 minutes. Mash a few to thicken.',
        'Serve with chapati or rice.'
      ]),
  BookRecipe('pilau', 'Pilau',
      meals: ['lunch', 'dinner'], minutes: 90, servings: 4,
      slots: [
        _r('Rice', '2 cups', ['rice']),
        _r('Meat (beef, chicken or goat)', '500 g, in pieces', _anyMeat),
        _o('Onion', '3 medium, sliced', ['onion']),
        _o('Potatoes', '2, quartered', ['potato']),
        _o('Garlic', '3 cloves', ['garlic']),
        _o('Pilau masala or spice mix', '2 tbsp', ['spice']),
      ],
      staples: ['Cooking oil - 4 tbsp', 'Salt', 'Water'],
      steps: [
        'Fry the onions in the oil until deep golden brown. This gives pilau its colour.',
        'Add the garlic and pilau masala and cook 1 minute.',
        'Add the meat and brown for 5 minutes, then add 3 cups hot water and salt. Cover and cook 30 to 40 minutes until nearly tender. Add the potatoes for the last 10 minutes.',
        'Add the washed rice and enough hot water to cover it by 1 cm.',
        'Cover tightly and cook on low heat for 20 to 25 minutes without stirring, then fluff with a fork.'
      ]),
  BookRecipe('fried_rice', 'Vegetable fried rice',
      meals: ['lunch', 'dinner'], minutes: 25, servings: 3,
      slots: [
        _r('Rice', '2 cups cooked (leftover works best)', ['rice']),
        _o('Carrot', '1, diced', ['carrot']),
        _o('Peas', '1/2 cup', ['peas']),
        _o('Capsicum', '1/2, diced', ['capsicum']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Eggs', '2', ['egg']),
        _o('Cabbage', '1 cup, shredded', ['cabbage']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt and pepper'],
      steps: [
        'If the rice is not cooked yet, cook it and let it cool.',
        'Heat the oil and fry the onion, then the carrot and other vegetables for 3 to 4 minutes.',
        'Push the vegetables aside and scramble the eggs in the pan if using.',
        'Add the rice, salt and pepper and toss on high heat for 3 minutes.'
      ]),
  BookRecipe('mukimo', 'Mukimo',
      meals: ['lunch', 'dinner'], minutes: 40, servings: 4,
      slots: [
        _r('Potatoes', '4 medium, peeled', ['potato']),
        _r('Leafy greens (pumpkin leaves, spinach or kale)', '1 bunch, chopped', ['greens']),
        _o('Dry maize or peas', '1 cup, boiled', ['maize_kernels', 'peas']),
        _o('Onion', '1, chopped', ['onion']),
      ],
      staples: ['Cooking oil or butter - 1 tbsp', 'Salt', 'Water'],
      steps: [
        'Boil the potatoes (with the maize or peas) in salted water for 20 to 25 minutes until soft.',
        'In a pan, cook the greens with the onion for 5 minutes.',
        'Drain the potatoes and mash them together with the greens and maize into a green mash.',
        'Mix in the oil or butter and adjust the salt. Serve with stew.'
      ]),
  BookRecipe('matoke', 'Matoke',
      meals: ['lunch', 'dinner'], minutes: 45, servings: 4,
      slots: [
        _r('Cooking bananas (matoke)', '6 to 8, peeled', ['banana_cooking']),
        _o('Beef', '250 g, cooked', ['beef']),
        _o('Potatoes', '1, cubed', ['potato']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '2, chopped', ['tomato']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water - 2 cups'],
      steps: [
        'Peel the matoke and keep it in water so it does not darken. Cut into chunks.',
        'Fry the onion, then the tomato, until soft.',
        'Add the beef (if using), the matoke, the potato, the water and salt.',
        'Cover and simmer 25 to 30 minutes until soft. Mash lightly or serve whole.'
      ]),
  BookRecipe('fish_fry', 'Fried tilapia with kachumbari',
      meals: ['lunch', 'dinner'], minutes: 30, servings: 3,
      slots: [
        _r('Fish', '2 whole tilapia (or 500 g fillets)', ['fish']),
        _o('Tomato', '2, diced (for kachumbari)', ['tomato']),
        _o('Onion', '1, sliced (for kachumbari)', ['onion']),
        _o('Lemon', '1', ['lemon']),
      ],
      staples: ['Cooking oil - for shallow frying', 'Salt'],
      steps: [
        'Clean the fish and cut a few slits in each side. Rub with salt (and lemon juice if you have it). Pat dry.',
        'Heat enough oil to shallow-fry on medium-high heat.',
        'Fry 5 to 7 minutes on each side until crisp and cooked through.',
        'Mix the tomato and onion with a pinch of salt and lemon juice for kachumbari.',
        'Serve the fish with kachumbari and ugali.'
      ]),
  BookRecipe('omena', 'Omena with tomatoes',
      meals: ['lunch', 'dinner'], minutes: 25, servings: 3,
      slots: [
        _r('Omena', '1 cup (about 100 g)', ['omena']),
        _o('Tomato', '2, chopped', ['tomato']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Greens', 'a handful', ['greens']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water - 1/4 cup'],
      steps: [
        'Wash the omena well, two or three times, and drain.',
        'Fry the onion in oil, then add the tomato and cook until soft.',
        'Add the omena, a pinch of salt and the water and simmer 10 minutes.',
        'Serve with ugali.'
      ]),
  BookRecipe('kachumbari', 'Kachumbari',
      meals: ['lunch', 'dinner', 'snack'], minutes: 10, servings: 4,
      slots: [
        _r('Tomatoes', '2 to 3, diced', ['tomato']),
        _r('Onion', '1 medium, finely sliced', ['onion']),
        _o('Chilli', 'to taste', ['chilli']),
        _o('Coriander (dhania)', 'a handful, chopped', ['herb']),
        _o('Cucumber', '1/2, diced', ['cucumber']),
        _o('Lemon', 'juice of 1/2', ['lemon']),
      ],
      staples: ['Salt'],
      steps: [
        'Soak the onion slices in cold water with a pinch of salt for 5 minutes, then drain. This removes the sharpness.',
        'Mix with the tomato and the other optional ingredients.',
        'Add lemon juice and salt and leave 10 minutes before serving.'
      ],
      tip: 'Serve with nyama choma, ugali, fish or smokies.'),
  BookRecipe('chips_mayai', 'Chips mayai',
      meals: ['lunch', 'dinner', 'snack'], minutes: 35, servings: 3,
      slots: [
        _r('Potatoes', '3 large', ['potato']),
        _r('Eggs', '3', ['egg']),
        _o('Onion', '1/2, chopped', ['onion']),
        _o('Tomato', '1, chopped', ['tomato']),
      ],
      staples: ['Cooking oil - for frying', 'Salt'],
      steps: [
        'Peel and cut the potatoes into chips. Soak 10 minutes, then dry well.',
        'Fry in hot oil until golden and cooked inside, then drain.',
        'Beat the eggs with salt, and the onion and tomato if using.',
        'Pour the egg over the chips in a lightly oiled pan and cook until set, or scramble it through.',
        'Serve with kachumbari or tomato sauce.'
      ]),
  BookRecipe('chips', 'Homemade chips',
      meals: ['lunch', 'dinner', 'snack'], minutes: 30, servings: 3,
      slots: [
        _r('Potatoes', '4 large', ['potato']),
      ],
      staples: ['Cooking oil - for frying', 'Salt'],
      steps: [
        'Peel the potatoes and cut into even chips. Soak in cold water for 10 minutes, then dry completely.',
        'Fry in hot oil in two batches until golden and crisp.',
        'Drain, sprinkle with salt and serve.'
      ]),
  BookRecipe('tomato_soup', 'Tomato soup',
      meals: ['lunch', 'dinner', 'snack'], minutes: 30, servings: 3,
      slots: [
        _r('Tomatoes', '6 ripe, chopped', ['tomato']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Carrot', '1, chopped', ['carrot']),
        _o('Garlic', '2 cloves', ['garlic']),
        _o('Milk', 'a splash', ['milk', 'cream']),
      ],
      staples: ['Cooking oil - 1 tbsp', 'Salt and pepper', 'Water - 2 cups'],
      steps: [
        'Fry the onion and garlic in oil for 2 minutes.',
        'Add the tomato, carrot and water and simmer 20 minutes until soft.',
        'Blend or mash well and pass through a sieve if you like it smooth.',
        'Return to the pot, season, add a splash of milk and heat for 3 minutes.'
      ]),
  BookRecipe('cabbage_fry', 'Cabbage stir-fry',
      meals: ['lunch', 'dinner'], minutes: 15, servings: 3,
      slots: [
        _r('Cabbage', '1/2 head, shredded', ['cabbage']),
        _o('Carrot', '1, grated', ['carrot']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '1, chopped', ['tomato']),
        _o('Capsicum', '1/2, sliced', ['capsicum']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt'],
      steps: [
        'Heat the oil and fry the onion for 2 minutes.',
        'Add the carrot (and capsicum, tomato) and cook 2 minutes.',
        'Add the cabbage and salt and stir-fry 5 to 6 minutes until just tender but still a little crunchy.',
        'Serve with ugali, chapati or rice.'
      ]),
  BookRecipe('pasta', 'Pasta with tomato sauce',
      meals: ['lunch', 'dinner'], minutes: 30, servings: 3,
      slots: [
        _r('Pasta', '250 g', ['pasta']),
        _r('Tomatoes (or tomato paste)', '4 ripe, or 3 tbsp paste', ['tomato', 'tomato_paste']),
        _o('Onion', '1, chopped', ['onion']),
        _o('Garlic', '2 cloves', ['garlic']),
        _o('Minced beef', '200 g', ['beef']),
        _o('Cheese', 'grated, to top', ['cheese']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt and pepper', 'Water'],
      steps: [
        'Boil the pasta in salted water for 8 to 10 minutes. Keep 1/2 cup of the water, then drain.',
        'Fry the onion and garlic in oil. If using mince, brown it first.',
        'Add the chopped tomato (or paste with 1/2 cup water) and simmer 10 minutes.',
        'Toss the pasta in the sauce, adding a little pasta water to loosen it. Top with cheese.'
      ]),
  BookRecipe('boiled_roots', 'Boiled sweet potatoes, cassava or arrowroot',
      meals: ['breakfast', 'snack', 'dinner'], minutes: 35, servings: 3,
      slots: [
        _r('Root vegetable', 'about 500 g', ['sweet_potato', 'cassava', 'arrowroot']),
      ],
      staples: ['Salt - a pinch', 'Water'],
      steps: [
        'Wash, peel and cut into even pieces.',
        'Boil in lightly salted water: sweet potato 20 minutes, cassava 25 to 30 minutes, arrowroot 30 to 40 minutes, until soft.',
        'Drain and serve with chai, avocado or a stew.'
      ]),
  BookRecipe('mboga', 'Mixed vegetable stew (mboga)',
      meals: ['lunch', 'dinner'], minutes: 30, servings: 3,
      slots: [
        _r('Vegetables (any two)', 'about 500 g in total',
            ['potato', 'carrot', 'cabbage', 'capsicum', 'peas', 'green_beans', 'pumpkin', 'tomato', 'eggplant'],
            min: 2),
        _o('Onion', '1, chopped', ['onion']),
        _o('Tomato', '1, chopped', ['tomato']),
      ],
      staples: ['Cooking oil - 2 tbsp', 'Salt', 'Water - 1/2 cup'],
      steps: [
        'Fry the onion in oil until soft.',
        'Add the harder vegetables first (potato, carrot, pumpkin) with the water and simmer 10 minutes.',
        'Add the softer vegetables (cabbage, peas, tomato, capsicum) and salt and cook 5 to 8 minutes more.',
        'Serve with ugali, chapati or rice.'
      ]),
  BookRecipe('smokie', 'Smokie pasua',
      meals: ['snack', 'lunch'], minutes: 15, servings: 2,
      slots: [
        _r('Smokies or sausages', '4', ['sausage']),
        _o('Tomato', '1, diced', ['tomato']),
        _o('Onion', '1/2, diced', ['onion']),
        _o('Chilli', 'to taste', ['chilli']),
      ],
      staples: ['Salt', 'Cooking oil - 1 tsp'],
      steps: [
        'Heat the smokies in a pan with a little oil for 5 minutes, turning until hot and lightly browned.',
        'Mix the tomato, onion and chilli with a pinch of salt for a quick kachumbari.',
        'Split each smokie lengthways and fill or top with the kachumbari.'
      ]),
];
