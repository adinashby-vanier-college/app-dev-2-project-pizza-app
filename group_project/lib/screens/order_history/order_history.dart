import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Map<String, List<Map<String, dynamic>>> ordersByMonth = {};

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance.collection('bookings')
        .where('userId', isEqualTo: user.uid).get();

    final orders = snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final monthYear = DateFormat('MMMM yyyy').format(createdAt); // "May 2025"
      return {
        'monthYear': monthYear,
        ...data,
      };
    }).toList();

    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var order in orders) {
      final monthYear = order['monthYear'];
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(order);
    }

    setState(() {
      ordersByMonth = grouped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4DE),
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFFF8F4DE),
        centerTitle: true,
      ),
      body: ordersByMonth.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No orders found.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: ordersByMonth.entries.map((entry) {
          final monthYear = entry.key;
          final orders = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthYear,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...orders.map((order) => OrderCard(
                items: order['items'],
                subTotal: order['subTotal'].toDouble(),
                tax: order['tax'].toDouble(),
                total: order['total'].toDouble(),
                paymentMethod: order['paymentMethod'],
                createdDate: order['createdAt'],
              )),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final List<dynamic> items;
  final double subTotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final Timestamp createdDate;

  const OrderCard({
    super.key,
    required this.items,
    required this.subTotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.createdDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(createdDate.toDate())}",
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${item['name']} x${item['quantity']}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text("\$${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          Text("Payment: $paymentMethod", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Text("Subtotal: \$${subTotal.toStringAsFixed(2)}"),
          Text("Tax: \$${tax.toStringAsFixed(2)}"),
          Text(
            "Total: \$${total.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
