import 'QRCodeGeneratorPage.dart';
import 'package:flutter/material.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:rflutter_alert/rflutter_alert.dart';
import "globalVariables.dart" as globals;
import 'package:shared_preferences/shared_preferences.dart';

class MnemonicCheck extends StatefulWidget {
  MnemonicCheck({Key? key}) : super(key: key);

  @override
  _MnemonicCheck createState() => _MnemonicCheck();
}

class _MnemonicCheck extends State<MnemonicCheck> {
  @override
  Widget build(BuildContext context) {
    TextEditingController passphraseController1 = new TextEditingController();
    TextEditingController passphraseController2 = new TextEditingController();
    TextEditingController passphraseController3 = new TextEditingController();

    bool invisible = false;
    var wrongpass;
    List<String> result = globals.tempMnemonic.split(' ');

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
          child: Column(children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              flex: 3,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Restore an account using a 12-word Passphrase",
                    style: TextStyle(
                        color: globals.fourthColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w200),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 11,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(100),
                      topLeft: Radius.circular(100)),
                  color: globals.thirdColor,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                    ),
                    TextField(
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
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
                        hintText: '3rd word of your passphrase',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                      ),
                      controller: passphraseController1,
                    ),
                    TextField(
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
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
                        hintText: '7th word of your passphrase',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                      ),
                      controller: passphraseController2,
                    ),
                    TextField(
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
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
                        hintText: '10th word of your passphrase',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                      ),
                      controller: passphraseController3,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            globals.thirdColor),
                      ),
                      onPressed: () {
                        if (passphraseController1.text == result[2] &&
                            passphraseController2.text == result[6] &&
                            passphraseController3.text == result[9]) {
                          changeData(
                              bip39.mnemonicToSeedHex(globals.tempMnemonic),
                              globals.pass);
                          Navigator.popAndPushNamed(context, "/login");
                        } else {
                          globals.pass = wrongpass;
                          Alert(
                              context: context,
                              type: AlertType.warning,
                              content: Column(
                                children: <Widget>[
                                  Center(
                                      child: Text(
                                    "Wrong Passphrase\n",
                                  )),
                                ],
                              ),
                              buttons: [
                                DialogButton(
                                  color: globals.primaryColor,
                                  onPressed: () {
                                    Navigator.popAndPushNamed(
                                        context, "/register");
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
                        }
                      },
                      child: Text(
                        "Create account",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    TextButton(
                      child: Text("Go back",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}
