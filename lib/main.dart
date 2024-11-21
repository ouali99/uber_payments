import 'package:flutter/material.dart';
import 'package:uber_payments/home_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:uber_payments/keys.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = PublishbleKey;
  await Stripe.instance.applySettings();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:HomePage(),
    );
  }
}
