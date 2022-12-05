import 'package:bip39/bip39.dart' as bip39;
import "globalVariables.dart" as globals;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class mnemonic extends StatelessWidget{
  mnemonic({Key? key}) : super(key: key);
  Widget build(BuildContext context){
    Future<String> changeData(String privateKey,String password) async{
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('password', password);
      prefs.setString('privateKey', privateKey);
      print("successfully set pass and privateKey");
      return "okay";
    }
    Future<void> getMnemonic(var mnemonic) async{

      final prefs = await SharedPreferences.getInstance();
      changeData(bip39.mnemonicToSeedHex(mnemonic), globals.pass);
    }
    var mnemonic = bip39.generateMnemonic();
    getMnemonic(mnemonic);
    globals.tempMnemonic = mnemonic;
    TextEditingController mnemonicController = new TextEditingController();
    mnemonicController.text = mnemonic;
    List<String> result = mnemonic.split(' ');
    print("DEBUG: currently on mnemonic page");
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
            children: [
              Column(

                  children: <Widget>[

                    Container(height: 100),
                    Text("Your Passphrase",style: TextStyle(color: globals.fourthColor,fontSize: 40,fontWeight: FontWeight.w200),textAlign: TextAlign.center,),
                    Container(height: 200),
                    Container(
                      width: 350,
                      height: 100,
                      child: TextField(

                        onTap:() { Clipboard.setData(new ClipboardData(text: globals.tempMnemonic)).then((_){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mnemonic copied to clipboard")));
                        });},
                        readOnly: true,
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
                          contentPadding:
                          const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),

                        ),
                        controller: mnemonicController,
                      ),
                    ),
                    ElevatedButton(onPressed: () {

                      Navigator.popAndPushNamed(context,"/mnemonicCheck");
                    },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(globals.thirdColor)),
                      child: Text(
                        "Next",
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,color:  globals.fourthColor),
                      ),
                    ),
                    Container(height: 100,),

                  ]

              ),
            ],
          ),
        )


    );
  }
}