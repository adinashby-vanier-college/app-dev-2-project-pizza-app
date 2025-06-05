import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/models/pizza_model.dart';
import 'package:group_project/screens/Home_screen/home_screen_cubit.dart';
import 'package:group_project/screens/pizza_details/pizza_details_screen.dart';
import 'package:group_project/utils/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pizza> pizzas = [];
  bool isLoading = true;
  Set<String> favoritePizzaIds = {};
  String searchQuery = '';

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
    fetchPizzas();
  }

  Future<void> fetchPizzas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('pizzas').get();
    final fetchedPizzas = snapshot.docs.map((doc) {
      final data = doc.data();
      return Pizza.fromJson(data, doc.id);
    }).toList();

    setState(() {
      pizzas = fetchedPizzas;
      isLoading = false;
    });
  }

  void toggleFavorite(Pizza pizza) async {
    final favCollection = FirebaseFirestore.instance.collection('favorites');

    if (favoritePizzaIds.contains(pizza.pizzaId)) {
      await favCollection.doc(pizza.pizzaId).delete();
      setState(() {
        favoritePizzaIds.remove(pizza.pizzaId);
      });
    } else {
      await favCollection.doc(pizza.pizzaId).set(pizza.toJson());
      setState(() {
        favoritePizzaIds.add(pizza.pizzaId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPizzas = pizzas.where((pizza) {
      final name = pizza.name.toLowerCase();
      final desc = pizza.description.toLowerCase();
      return name.contains(searchQuery) || desc.contains(searchQuery);
    }).toList();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 60),

              const SizedBox(height: 10),
              PizzaOfferSlider(),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F4DE),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search for pizza',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Icon(Icons.local_pizza_outlined,
                        color: AppColor.primaryColor)
                  ],
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? Expanded(
                      child: LoadingAnimationWidget.beat(
                        color: AppColor.primaryColor,
                        size: 50,
                      ),
                    )
                  : Expanded(
                      child: filteredPizzas.isEmpty
                          ? const Center(
                              child: Text(
                                "No pizzas found.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: filteredPizzas.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, index) {
                                final pizza = filteredPizzas[index];
                                final cardColor =
                                    cardColors[index % cardColors.length];
                                final cardColor1 =
                                    cardColors1[index % cardColors1.length];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PizzaDetailsPage(pizza: pizza),
                                      ),
                                    );
                                  },
                                  child: PizzaCard(
                                    pizza: pizza,
                                    colors: cardColor,
                                    colors1: cardColor1,
                                    isFavorite: context.watch<HomeScreenCubit>().isFavorite(pizza.pizzaId),
                                    onFavoriteToggle: () {
                                      context.read<HomeScreenCubit>().toggleFavorite(
                                        pizza.pizzaId,
                                        pizza.toJson(),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class PizzaCard extends StatelessWidget {
  final Pizza pizza;
  final Color colors;
  final Color colors1;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PizzaCard({
    super.key,
    required this.pizza,
    required this.colors,
    required this.colors1,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Center(
                  child: CachedNetworkImage(
                    imageUrl: pizza.picture.toString(),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => LoadingAnimationWidget.beat(
                      color: AppColor.backgroundColor,
                      size: 50,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pizza.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pizza.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        "\$${pizza.price.toString()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          addPizzaToCart(
                            userId: listUser!.userId,
                            pizza: pizza,
                            quantity: 1,
                            context: context,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors1,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> addPizzaToCart({
    required BuildContext context,
    required String userId,
    required Pizza pizza,
    required int quantity,
  }) async {
    try {
      final cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .collection('items')
          .doc(pizza.pizzaId);

      final doc = await cartRef.get();

      if (doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('🍕 ${pizza.name} is already in the cart.',
                style: TextStyle(color: AppColor.primaryColor)),
            backgroundColor: Colors.white,
          ),
        );
      } else {
        await cartRef.set({
          'pizzaId': pizza.pizzaId,
          'name': pizza.name,
          'description': pizza.description,
          'price': pizza.price,
          'quantity': quantity,
          'imageUrl': pizza.picture,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('✅ ${pizza.name} added to cart.',
                style: TextStyle(color: AppColor.primaryColor)),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Error adding to cart: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to add pizza to cart.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class PizzaOfferBanner extends StatelessWidget {
  final String month;
  final String description;
  final String imagePath;
  final Color colorsNew;

  const PizzaOfferBanner({
    required this.month,
    required this.description,
    required this.imagePath,
    super.key,
    required this.colorsNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color:colorsNew,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Special Offer for $month",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                SizedBox(height: 30),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Pizza Image
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              imagePath,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}

class PizzaOfferSlider extends StatefulWidget {
  const PizzaOfferSlider({super.key});

  @override
  State<PizzaOfferSlider> createState() => _PizzaOfferSliderState();
}

class _PizzaOfferSliderState extends State<PizzaOfferSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> banners = [
    {
      "month": "March",
      "description": "best pizzas in town.",
      "image": "assets/images/pizza2.png",
    },
    {
      "month": "April",
      "description": "April Madness! Don't miss the crust.",
      "image": "assets/images/paneer_pizza.png",
    },
    {
      "month": "May",
      "description": "Melted cheese just for May!",
      "image": "assets/images/tomato_pizza.png",
    },
    {
      "month": "June",
      "description": "Cool off with a slice this summer.",
      "image": "assets/images/paneer_pizza.png",
    },
  ];
  final List<Color> cardColors3 = [
    Colors.red,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    startAutoScroll();
  }

  void startAutoScroll() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;

      _currentPage++;
      if (_currentPage >= banners.length) _currentPage = 0;

      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );

      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _controller,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          final colorsNew = cardColors3[index % cardColors3.length];

          return PizzaOfferBanner(
            month: banner["month"]!,
            description: banner["description"]!,
            imagePath: banner["image"]!,
            colorsNew: colorsNew,
          );
        },
      ),
    );
  }
}
