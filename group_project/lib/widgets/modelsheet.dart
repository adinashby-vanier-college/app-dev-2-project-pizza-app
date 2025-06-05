import 'package:flutter/material.dart';

void showPaymentSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Payment MODE - CARD ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Card information", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Card number',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                  // suffixIcon: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Image.asset('assets/visa.png', width: 30), // Add your icons here
                  //     SizedBox(width: 4),
                  //     Image.asset('assets/mastercard.png', width: 30),
                  //     SizedBox(width: 4),
                  //     Image.asset('assets/amex.png', width: 30),
                  //     SizedBox(width: 4),
                  //     Image.asset('assets/discover.png', width: 30),
                  //     SizedBox(width: 10),
                  //   ],
                  // ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'MM / YY',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'CVC',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("Billing address", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: 'United States',
                items: ['United States', 'United Kingdom', 'India']
                    .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
                    .toList(),
                onChanged: (value) {},
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Country or region',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'ZIP Code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (val) {}),
                  Expanded(
                    child: Text("Save for future pizza payments"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null, // Locked button
                  icon: Icon(Icons.lock, color: Colors.white),
                  label: Text(
                    "Pay £26.25",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}