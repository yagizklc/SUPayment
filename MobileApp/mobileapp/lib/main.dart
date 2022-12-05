import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "globalVariables.dart" as globals;
import 'register.dart';
import "recoverPage.dart";
import "mnemonic.dart";
import "makePayment.dart";
import "dart:convert";
import "walletPage.dart";
import "dart:io";

import "mnemonicCheck.dart";

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
        '/walletPage': (context) => MyHomePage(title: "Wallet Page"),
        "/register": (context) => Register(),
        "/recover": (context) => recoverPage(),
        "/loading": (context) => Loading(),
        "/login": (context) => Login(),
        "/mnemonic": (context) => mnemonic(),
        "/makePayment": (context) => MakePayment(
            paymentAddr: "",
            paymentList: "",
            paymentType: "",
            totalValue: BigInt.zero),
        "/mnemonicCheck": (context) => MnemonicCheck(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Loading(),
    );
  }
}

class Loading extends StatelessWidget {
  Loading({Key? key}) : super(key: key);
  Widget build(BuildContext context) {
    Future<void> checkUserLog() async {
      final prefs = await SharedPreferences.getInstance();

      final counter = prefs.getString('password') ?? null;
      if (counter == null) {
        Navigator.popAndPushNamed(context, "/register");
      } else {
        Navigator.popAndPushNamed(context, "/login");
      }
    }

    checkUserLog();
    return Scaffold(
      backgroundColor: globals.primaryColor,
    );
  }
}

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  late Web3Client avaxClient;
  late Client httpClient;

  Future<void> checkUserLog() async {
    final prefs = await SharedPreferences.getInstance();

    final counter = prefs.getString('password') ?? null;
    if (counter == null) {
      Navigator.pushNamed(context, "/register");
    }
    await loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    httpClient = Client();
    avaxClient = Web3Client(globals.RPC, httpClient); // JSON RPC
    final counter = prefs.getString('password') ?? "PROBLEM";
    globals.dummyPrivateKey = prefs.getString('privateKey') ?? "NULL";
    print(counter);
    globals.pass = counter;
    globals.credentials = EthPrivateKey.fromHex(globals.dummyPrivateKey);
    globals.userAddress = await globals.credentials.extractAddress();

    await createTransactionList();
  }

  Future<String> changeData(String privateKey, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
    prefs.setString('privateKey', privateKey);
    print("successfully set pass and privateKey");
    await loadData();

    return "okay";
  }

  Future<String> DEBUG(String privateKey, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
    prefs.setString('privateKey', privateKey);
    print("successfully set pass and privateKey");
    await loadData();

    return "okay";
  }

  Future<void> createTransactionList() async {
    Client apiClient = new Client();
    Response returnValue;
    Response ERC20ReturnValue;
    returnValue = await apiClient.get(Uri.parse(globals.apiFirstPart +
        "${globals.userAddress}" +
        globals.apiSecondPart));
    globals.itemCount =
        await avaxClient.getTransactionCount(globals.userAddress!);
    ERC20ReturnValue = await apiClient.get(Uri.parse(globals.ERC20apiFirstPart +
        "${globals.userAddress}" +
        globals.ERC20apiSecondPart));
    globals.ERC20ReturnValue = json.decode(ERC20ReturnValue.body)["result"];
    globals.returnValue = json.decode(returnValue.body)["result"];
    globals.tokenAddresses = new Map<String, Map<String, dynamic>>();
    for (int i = 0; i < globals.ERC20ReturnValue.length; i++) {
      if (globals.ERC20ReturnValue[i]["contractAddress"] !=
          globals.suCoinContract) {
        globals.tokenAddresses![globals.ERC20ReturnValue[i]
            ["contractAddress"]] = globals.ERC20ReturnValue[i];
      }
    }
    print(globals.tokenAddresses!.keys);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    TextEditingController myController = new TextEditingController();

    return Scaffold(
      backgroundColor: globals.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/2699268.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Text("Welcome Back!",
                      style: TextStyle(
                        color: globals.fourthColor,
                        fontSize: 40,
                        fontWeight: FontWeight.w100,
                      )),
                  SizedBox(
                    height: 100,
                  ),
                  Center(
                    child: Container(
                      width: 300,
                      height: 50,
                      child: TextField(
                        obscureText: true,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 3, color: globals.fourthColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 3, color: globals.thirdColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                        ),
                        controller: myController,
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            globals.thirdColor),
                      ),
                      onPressed: () {
                        print(myController.text);
                        if (myController.text == globals.pass) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyHomePage(title: "Web3")),
                          );
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "or",
                        style: TextStyle(color: Colors.white54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/recover");
                        },
                        child: Text(
                          "import using Secret Recovery Phrase",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(height: 20),
                  Container(
                    width: 20,
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            globals.thirdColor),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            globals.thirdColor),
                      ),
                      onPressed: () {
                        print(myController.text);
                        DEBUG(
                            "902f3babddfe6955425f7fb8aab559bab752158b9e76d3001b5c9c2a2b336f18",
                            "1234");
                      },
                      child: Text(
                        "DEBUG",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ]))
          ],
        ),
      ),
    );
  }
}
