import 'package:flutter/material.dart';

import '../models/meal.dart';

class MealDetailsScreen extends StatefulWidget {
  const MealDetailsScreen({
    super.key,
    required this.meal,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  final Meal meal;
  final void Function(Meal meal) onToggleFavorite;
  final bool Function(Meal meal) isFavorite;

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onSurface);
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.title),
        actions: [
          IconButton(
            onPressed: () {
              widget.onToggleFavorite(meal);
              // prekreslí ikonu hviezdy (stav obľúbených je v TabsScreen)
              setState(() {});
            },
            icon: Icon(
              widget.isFavorite(meal) ? Icons.star : Icons.star_border,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              meal.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 14),
            Text('Ingredients', style: headingStyle),
            const SizedBox(height: 14),
            ...meal.ingredients.map((i) => Text(i, style: bodyStyle)),
            const SizedBox(height: 24),
            Text('Steps', style: headingStyle),
            const SizedBox(height: 14),
            ...meal.steps.map(
              (step) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  step,
                  textAlign: TextAlign.center,
                  style: bodyStyle,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
