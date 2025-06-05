import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_project/repositories/models/pizza_model.dart';
import 'package:group_project/utils/colors.dart';
import 'package:group_project/utils/loader.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Home_screen/home_screen_cubit.dart';

class PizzaDetailsPage extends StatefulWidget {
  final Pizza pizza;

  const PizzaDetailsPage({super.key, required this.pizza});

  @override
  State<PizzaDetailsPage> createState() => _PizzaDetailsPageState();
}

class _PizzaDetailsPageState extends State<PizzaDetailsPage> {
  int quantity = 1;
  bool alreadyInCart = false;

  // bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkCartStatus();
    // checkFavoriteStatus();
  }

  void checkCartStatus() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final result = await isPizzaAlreadyInCart(userId, widget.pizza.pizzaId);
    setState(() => alreadyInCart = result);
  }

  Future<bool> isPizzaAlreadyInCart(String userId, String pizzaId) async {
    final doc = await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(pizzaId)
        .get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeScreenCubit>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4DE),
      body: SingleChildScrollView(
        child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: 16,
                      child: IconButton(
                        icon: Icon(
                          cubit.isFavorite(widget.pizza.pizzaId) ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.read<HomeScreenCubit>().toggleFavorite(
                            widget.pizza.pizzaId,
                            widget.pizza.toJson(),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: widget.pizza.picture,
                          height: 200,
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              LoadingAnimationWidget.beat(
                                  color: Colors.white, size: 40),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.pizza.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.pizza.description,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NutrientInfo(
                        icon: Icons.local_fire_department,
                        label: "Calories",
                        value: "${widget.pizza.calories} kcal"),
                    NutrientInfo(
                        icon: Icons.grain,
                        label: "Carbs",
                        value: "${widget.pizza.carbs}g"),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NutrientInfo(
                        icon: Icons.oil_barrel,
                        label: "Fat",
                        value: "${widget.pizza.fat}g"),
                    NutrientInfo(
                        icon: Icons.fitness_center,
                        label: "Protein",
                        value: "${widget.pizza.proteins}g"),
                  ],
                ),
                Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      children: [
                        Text(
                          "\$${widget.pizza.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: alreadyInCart
                              ? null
                              : () async {
                            await addPizzaToCart(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              pizza: widget.pizza,
                              quantity: quantity,
                              context: context,
                            );
                            setState(() => alreadyInCart = true);
                          },
                          icon: const Icon(Icons.shopping_cart_outlined,
                              color: Colors.white),
                          label: Text(
                            alreadyInCart ? 'Already in Cart' : 'Add to Cart',
                            style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            alreadyInCart ? Colors.grey : AppColor.primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const NutrientInfo({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.redAccent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Future<void> addPizzaToCart({required String userId,
  required Pizza pizza,
  required int quantity,
  required BuildContext context}) async {
  try {
    CommonUtils.showProgressLoading(context);
    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(pizza.pizzaId);

    final doc = await cartRef.get();

    if (doc.exists) {
      CommonUtils.hideProgressLoading();
      int currentQty = doc.data()?['quantity'] ?? 1;
      await cartRef.update({'quantity': currentQty + quantity});
    } else {
      CommonUtils.hideProgressLoading();
      await cartRef.set({
        'pizzaId': pizza.pizzaId,
        'name': pizza.name,
        'description': pizza.description,
        'price': pizza.price,
        'quantity': quantity,
        'imageUrl': pizza.picture,
      });
    }

    debugPrint("✅ Pizza added to cart");
  } catch (e) {
    CommonUtils.hideProgressLoading();
    debugPrint("❌ Failed to add to cart: $e");
  }
}
