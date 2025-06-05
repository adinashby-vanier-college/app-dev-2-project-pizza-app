import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_project/main.dart';
import 'package:group_project/screens/payment/payment_screen.dart';
import 'package:group_project/utils/colors.dart';

import '../../repositories/models/cartModel.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final String userId = listUser!.userId;

  Stream<List<CartItem>> getCartItems() {
    return FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromFirestore(doc.data())).toList());
  }

  Future<void> updateQuantity(String pizzaId, int quantity) async {
    final docRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(pizzaId);

    if (quantity <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({'quantity': quantity});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0DC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: getCartItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/basket.png', // optional
                    height: 70,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Your cart is empty!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add delicious pizzas to proceed.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final subTotal = cartItems.fold<double>(
              0.0, (sum, item) => sum + item.price * item.quantity);
          final taxes = subTotal * 0.10; // 10% tax
          final baseTime = 20;
          final extraTime = (subTotal / 20).floor();
          final totalTime = baseTime + extraTime; // Dynamic delivery time
          final total = subTotal + taxes;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.imageUrl,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.red)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text("$totalTime Mins",
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey))
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text("\$ ${item.price}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    updateQuantity(item.pizzaId, 0);
                                  },
                                  child: Icon(Icons.close, color: Colors.black),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 14),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          updateQuantity(item.pizzaId, item.quantity - 1);
                                        },
                                        child: const Icon(Icons.remove,
                                            color: Colors.white, size: 22),
                                      ),
                                      const SizedBox(width: 10),
                                      Text('${item.quantity}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          updateQuantity(item.pizzaId, item.quantity + 1);
                                        },
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 22),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order-Information",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sub-Total"),
                          Text("\$ ${subTotal.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Taxes & Charges"),
                          Text("\$ ${taxes.toStringAsFixed(2)}"),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("\$ ${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            cartItems: cartItems,
                            subTotal: subTotal,
                            tax: taxes,
                            total: total,
                          ),
                        ),
                      );
                    },
                    child: const Text("Pay Now",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
