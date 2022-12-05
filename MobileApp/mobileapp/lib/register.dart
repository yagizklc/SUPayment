import 'QRCodeGeneratorPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'dart:math'; //used for the random number generator
import 'package:bip39/bip39.dart' as bip39;
import 'package:rflutter_alert/rflutter_alert.dart';
import "walletPage.dart";
import "dart:io";
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import "globalVariables.dart" as globals;
import "dart:convert";
import "walletPage.dart";
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  @override
  Widget build(BuildContext context) {
    TextEditingController myController1 = new TextEditingController();
    var rng = new Random.secure();
    EthPrivateKey random = EthPrivateKey.createRandom(rng);
    bool invisible = false;

    Future<void> loadData() async {
      final prefs = await SharedPreferences.getInstance();

      final counter = prefs.getString('password') ?? "PROBLEM";
      globals.dummyPrivateKey = prefs.getString('privateKey') ?? "NULL";
      print(counter);
      globals.pass = counter;
    }

    Future<String> changeData(String privateKey, String password) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('password', password);
      prefs.setString('privateKey', privateKey);
      print("successfully set pass and privateKey");
      await loadData();

      return "okay";
    }

    return Scaffold(
        backgroundColor: globals.primaryColor,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/2699268.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
              ),
              Text(
                "Welcome To SuCoin Mobile Wallet",
                style: TextStyle(
                    color: globals.fourthColor,
                    fontWeight: FontWeight.w200,
                    fontSize: 40),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 50,
              ),
              Text(
                "To continue, Please register, or recover a wallet using your 12-word passphrase",
                style: TextStyle(
                    color: globals.fourthColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 50,
              ),
              Center(
                child: Container(
                  width: 200,
                  height: 50,
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 3, color: globals.thirdColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 3, color: globals.thirdColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: globals.fourthColor,
                      hintText: 'New password',
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 8.0, top: 8.0),
                    ),
                    controller: myController1,
                  ),
                ),
              ),
              Container(height: 50),
              Container(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(globals.thirdColor),
                  ),
                  onPressed: () {
                    globals.pass = myController1.text;
                    Alert(
                        context: context,
                        type: AlertType.warning,
                        content: Column(
                          children: <Widget>[
                            Center(
                                child: Text(
                              "Write down your passphrase, you will not be able to recover it if you lose it.\n",
                            )),
                          ],
                        ),
                        buttons: [
                          DialogButton(
                            color: globals.primaryColor,
                            onPressed: () {
                              Navigator.popAndPushNamed(context, "/mnemonic");
                            },
                            child: Text(
                              "Okay",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: globals.secondaryColor),
                            ),
                          )
                        ]).show();
                  },
                  child: Text(
                    "Register New User",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: globals.fourthColor),
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
            ],
          ),
        ));
  }
}
