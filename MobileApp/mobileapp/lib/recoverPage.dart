import 'dart:convert';
import 'dart:ui';
import "package:bip39/bip39.dart" as bip39;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import "globalVariables.dart" as globals;
import "package:shared_preferences/shared_preferences.dart";

class recoverPage extends StatefulWidget {
  recoverPage({Key? key}) : super(key: key);


  @override
  _recoverPage createState() => _recoverPage();


}




class _recoverPage extends State<recoverPage> {

  late Web3Client avaxClient;
  late Client httpClient;

  Future<void> checkUserLog() async{
    final prefs = await SharedPreferences.getInstance();

    final counter = prefs.getString('password') ?? null;
    if(counter == null){
      Navigator.pushNamed(context, "/register");
    }

  }
  Future<void> loadData()async {
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

  Future<String> changeData(String privateKey,String password) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
    prefs.setString('privateKey', privateKey);
    print("successfully set pass and privateKey");
    await loadData();

    return "okay";
  }
  Future<String> DEBUG(String privateKey,String password) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
    prefs.setString('privateKey', privateKey);
    print("successfully set pass and privateKey");
    await loadData();

    return "okay";
  }
  Future<void> createTransactionList() async
  {

    Client apiClient = new Client();
    Response returnValue;
    Response ERC20ReturnValue;
    returnValue = await apiClient.get(Uri.parse(globals.apiFirstPart + "${globals.userAddress}" + globals.apiSecondPart));
    globals.itemCount = await avaxClient.getTransactionCount(globals.userAddress!);
    ERC20ReturnValue = await apiClient.get(Uri.parse(globals.ERC20apiFirstPart + "${globals.userAddress}" + globals.ERC20apiSecondPart));
    globals.ERC20ReturnValue = json.decode(ERC20ReturnValue.body)["result"];
    globals.returnValue = json.decode(returnValue.body)["result"];


  }

  @override
  Widget build(BuildContext context) {
    TextEditingController passphraseController = new TextEditingController();
    TextEditingController passwordController = new TextEditingController();
    TextEditingController passwordAuthController = new TextEditingController();

    return Scaffold(
      backgroundColor: globals.primaryColor,
      body: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         Flexible(

           fit: FlexFit.tight,
           flex:3,
           child: Container(

             alignment: Alignment.bottomCenter,
             child: Padding(
               padding: const EdgeInsets.all(20.0),

               child: Text("Restore an account using a 12-word Passphrase",
                 style: TextStyle(color: globals.fourthColor,fontSize: 30,fontWeight: FontWeight.w200),
                 textAlign: TextAlign.center,
               ),
             ),
           ),
         ),
          Flexible(
            fit: FlexFit.tight,
            flex:11,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(100),topLeft: Radius.circular(100) ),
                color: globals.thirdColor,
              ),
                child: Column(
                  children: [
                    Container(height: 100,),
                    TextField(
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,

                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: globals.thirdColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: globals.thirdColor),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        filled: true,
                        fillColor: globals.fourthColor,
                        hintText: '12-word Passphrase',
                        helperText: 'Write with a space between words',
                        contentPadding:
                        const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),

                      ),
                      controller: passphraseController,
                    ),

                    Padding(

                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        obscureText: true,


                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 3, color: globals.thirdColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 3, color: globals.thirdColor),
                            borderRadius: BorderRadius.circular(15),
                          ),

                          filled: true,
                          fillColor: globals.fourthColor,
                          hintText: 'New password',
                          contentPadding:
                          const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),

                        ),
                        controller: passwordController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        obscureText: true,


                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 3, color: globals.thirdColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 3, color: globals.thirdColor),
                            borderRadius: BorderRadius.circular(15),
                          ),

                          filled: true,
                          fillColor: globals.fourthColor,
                          hintText: 'Confirm Password',
                          contentPadding:
                          const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),

                        ),
                        controller: passwordAuthController,
                      ),
                    ),

                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(globals.thirdColor),
                      ),
                      onPressed:(){
                        String passphrase = passphraseController.text;
                        print(passphrase);
                        bool validator = bip39.validateMnemonic(passphrase);
                        if(validator) {
                          changeData(bip39.mnemonicToSeedHex(passphrase), passphrase);
                        }
                      },
                      child: Text(
                        "Recover",
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,color: Colors.white),
                      ),
                    ),
                    TextButton(child: Text("Go back",style: TextStyle(color: Colors.white)),onPressed: (){ Navigator.pop(context);},),



                  ],
                ),
            ),
          ),

        ]
      ),
    );
  }
}