import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_data.dart';
import '../models/filter.dart';
import '../models/meal.dart';
import '../widgets/main_drawer.dart';
import 'categories.dart';
import 'filters.dart';
import 'meals.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoriteMeals = [];
  Map<Filter, bool> _selectedFilters = kInitialFilters;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Bonus: obnovenie obľúbených jedál a filtrov z pamäte zariadenia.
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorites') ?? [];
    final filters = {
      for (final f in Filter.values)
        f: prefs.getBool('filter_${f.name}') ?? false,
    };

    if (!mounted) return;
    setState(() {
      _favoriteMeals
        ..clear()
        ..addAll(dummyMeals.where((m) => favoriteIds.contains(m.id)));
      _selectedFilters = filters;
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      _favoriteMeals.map((m) => m.id).toList(),
    );
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _selectedFilters.entries) {
      await prefs.setBool('filter_${entry.key.name}', entry.value);
    }
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  bool _isFavorite(Meal meal) => _favoriteMeals.contains(meal);

  void _toggleMealFavoriteStatus(Meal meal) {
    final isExisting = _favoriteMeals.contains(meal);

    setState(() {
      if (isExisting) {
        _favoriteMeals.remove(meal);
      } else {
        _favoriteMeals.add(meal);
      }
    });

    _showInfoMessage(
      isExisting ? 'Meal removed from favorites.' : 'Meal added to favorites!',
    );
    _saveFavorites();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  List<Meal> get _availableMeals {
    return dummyMeals.where((meal) {
      if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop(); // zatvorí Drawer

    if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => FiltersScreen(currentFilters: _selectedFilters),
        ),
      );

      if (!mounted) return;
      setState(() {
        _selectedFilters = result ?? kInitialFilters;
      });
      _saveFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = _availableMeals;

    Widget activePage = CategoriesScreen(
      onToggleFavorite: _toggleMealFavoriteStatus,
      isFavorite: _isFavorite,
      availableMeals: availableMeals,
    );
    String activePageTitle = 'Pick your category';

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
        meals: _favoriteMeals,
        onToggleFavorite: _toggleMealFavoriteStatus,
        isFavorite: _isFavorite,
      );
      activePageTitle = 'Your Favorites';
    }

    return Scaffold(
      appBar: AppBar(title: Text(activePageTitle)),
      drawer: MainDrawer(onSelectScreen: _setScreen),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }
}
