import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/models/pizza_model.dart';
import 'package:group_project/screens/Home_screen/home_screen.dart';
import 'package:group_project/screens/Home_screen/home_screen_cubit.dart';

import '../pizza_details/pizza_details_screen.dart';

class FavoritePizza extends StatefulWidget {
  const FavoritePizza({super.key});

  @override
  State<FavoritePizza> createState() => _FavoritePizzaState();
}

class _FavoritePizzaState extends State<FavoritePizza> {
  late Future<List<Pizza>> _futureFavorites;

  final List<Color> cardColors = [
    Colors.red,
    Colors.orangeAccent,
  ];
  final List<Color> cardColors1 = [
    Colors.orangeAccent,
    Colors.redAccent,
  ];

  @override
  void initState() {
    super.initState();
    _futureFavorites = fetchFavoritePizzas(listUser!.userId);
  }

  Future<List<Pizza>> fetchFavoritePizzas(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Pizza.fromJson(data, doc.id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Pizzas')),
      body: FutureBuilder<List<Pizza>>(
        future: _futureFavorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favoritePizzas = snapshot.data ?? [];

          if (favoritePizzas.isEmpty) {
            return const Center(child: Text('No favorite pizzas found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoritePizzas.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final pizza = favoritePizzas[index];
              final cardColor = cardColors[index % cardColors.length];
              final cardColor1 = cardColors1[index % cardColors1.length];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PizzaDetailsPage(pizza: pizza),
                    ),
                  );
                },
                child: PizzaCard(
                  pizza: pizza,
                  colors: cardColor,
                  colors1: cardColor1,
                  isFavorite: context
                      .watch<HomeScreenCubit>()
                      .isFavorite(pizza.pizzaId),
                  onFavoriteToggle: () {
                    context.read<HomeScreenCubit>().toggleFavorite(
                          pizza.pizzaId,
                          pizza.toJson(),
                        );
                    setState(() {
                      _futureFavorites = fetchFavoritePizzas(listUser!.userId);
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
