import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:uber_payments/keys.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double amount = 100;
  Map<String, dynamic>? paymentIntentData;

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((val) {
        paymentIntentData = null;
      }).onError((errorMsg, sTrace) {
        if (kDebugMode) {
          print(sTrace);
        }
        print(errorMsg.toString() + sTrace.toString());
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print(error);
      }
      print(error.toString());
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  makeIntentForPayement(amountToBeCharge, currency) async {
    try {
      Map<String, dynamic> paymentInfo = {
        "amount": (int.parse(amountToBeCharge) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };
      var responseFromStripeAPI = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer ${SecretKey}",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      print("responseFromStripeAPI =" + responseFromStripeAPI.body);

      return jsonDecode(responseFromStripeAPI.body);
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  paymentSheetInitialization(amountToBeCharge, currency) async {
    try {
      paymentIntentData = await makeIntentForPayement(amountToBeCharge, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: paymentIntentData!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Uber Payments",
        ),
      ).then((val) {
        print(val);
      });
      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                paymentSheetInitialization(
                  amount.round().toString(),
                  "CAD",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Pay Now CAD ${amount.toString()}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
