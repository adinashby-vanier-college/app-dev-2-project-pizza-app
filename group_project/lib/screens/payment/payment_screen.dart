import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/models/cartModel.dart';
import 'package:group_project/utils/loader.dart';
import 'package:group_project/widgets/modelsheet.dart';
import 'package:group_project/widgets/snackbar.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subTotal;
  final double tax;
  final double total;

  const PaymentScreen(
      {super.key,
      required this.cartItems,
      required this.subTotal,
      required this.tax,
      required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<void> placeBooking(String paymentMethod,BuildContext context) async {
    final userId = listUser!.userId;
    final timestamp = DateTime.now();
    final bookingRef = FirebaseFirestore.instance.collection('bookings').doc();

    try {
      CommonUtils.showProgressLoading(context);
      await bookingRef.set({
        'userId': userId,
        'bookingId': bookingRef.id,
        'createdAt': timestamp,
        'subTotal': widget.subTotal,
        'tax': widget.tax,
        'total': widget.total,
        'paymentMethod': paymentMethod,
        'items': widget.cartItems
            .map((item) => {
                  'pizzaId': item.pizzaId,
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                  'imageUrl': item.imageUrl,
                })
            .toList(),
      });

      // Clear cart
      final cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .collection('items');
      final cartSnapshot = await cartRef.get();
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      if (context.mounted) {
        CommonUtils.hideProgressLoading();
        showCustomSnackbar(
          context: context,
          title: "SUCCESS",
          message: "Your order has been placed successfully!",
          color: Colors.green,
        );
        if(paymentMethod=="debit Card"||paymentMethod=="Credit Card"){
          Navigator.of(context).pop();
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        CommonUtils.hideProgressLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to place booking: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4DE), // light cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4DE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Options',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PaymentTile(
            icon: Icons.credit_card,
            title: "Credit Card",
            onTap: () {
              // Handle Credit card option
              showPaymentSheet(context,"Credit Card");
            },
          ),
          const SizedBox(height: 12),
          PaymentTile(
            icon: Icons.credit_card,
            title: "Debit Card",
            onTap: () {
              // Handle debit card option
              showPaymentSheet(context,"debit Card");
            },
          ),
          const SizedBox(height: 12),
          PaymentTile(
            icon: Icons.money,
            title: "Cash On Delivery",
            onTap: () {
              // Handle cash on delivery
              placeBooking("Cash On Delivery",context);
            },
          ),
        ],
      ),
    );
  }

  void showPaymentSheet(BuildContext context, String payment) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvcController = TextEditingController();
    final zipController = TextEditingController();
    final cardController = TextEditingController();
    String selectedCountry = 'canada';

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Payment MODE - CARD ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Card information",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Card number',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final rawNumber = value?.replaceAll(' ', '');
                      if (rawNumber == null || rawNumber.length != 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpiryDateFormatter(),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Expiry date is required';
                            }

                            final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                            if (!regex.hasMatch(value)) {
                              return 'Enter valid format MM/YY';
                            }

                            final parts = value.split('/');
                            final int month = int.parse(parts[0]);
                            final int year = int.parse('20${parts[1]}');

                            final now = DateTime.now();
                            final expiryDate = DateTime(year, month + 1, 0);

                            if (expiryDate.isBefore(now)) {
                              return 'Card has expired';
                            }

                            return null;
                          },
                        )
                        ,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: cvcController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'CVC',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.length != 3) {
                              return 'CVC must be 3 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Billing address",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    items: ['canada',]
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                        .toList(),
                    onChanged: (value) {
                      selectedCountry = value!;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Country or region',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: zipController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'ZIP Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ZIP Code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: cardController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Card holder Name',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Card holder Name required';
                      }
                      return null;
                    },
                  ),
                  // Row(
                  //   children: [
                  //     Checkbox(value: false, onChanged: (_) {}),
                  //     const Expanded(
                  //       child: Text("Save for future pizza payments"),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          placeBooking(payment,context);
                          Navigator.canPop(context);
                        }
                      },
                      icon: const Icon(Icons.lock, color: Colors.white),
                      label: Text(
                        "Pay \$${widget.total}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

class PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const PaymentTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }


}
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}


