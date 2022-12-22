import 'package:flutter/material.dart';

// Routes of the app
import 'routes/loading_page.dart';
import 'routes/login_page.dart';
import 'routes/register_page.dart';
import 'routes/recover_page.dart';
import 'routes/mnemonic_page.dart';
import 'routes/make_payment_page.dart';
import 'routes/mnemonic_check_page.dart';
import 'routes/wallet_page.dart';

import "dart:io";

/* TODO:
- Add Loading Screen


*/

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUPayment',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/wallet_page': (context) => MyHomePage(title: "Wallet Page"),
        "/register": (context) => Register(),
        "/recover": (context) => recoverPage(),
        "/loading": (context) => const Loading(),
        "/login": (context) => Login(),
        "/mnemonic": (context) => mnemonic(),
        "/make_payment": (context) => MakePayment(
            paymentAddr: "",
            paymentList: "",
            paymentType: "",
            totalValue: BigInt.zero),
        "/mnemonic_check": (context) => MnemonicCheck(),
      },
      home: const Loading(),
    );
  }
}
