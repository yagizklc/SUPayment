import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import "dart:convert";
import "globalVariables.dart" as globals;
import "package:qr_flutter/qr_flutter.dart";

class qrCodeGenerator extends StatefulWidget {
  const qrCodeGenerator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _qrCodeGenerator();
}

class _qrCodeGenerator extends State<qrCodeGenerator> {


  int requestAmount = 0;
  @override
  void initState(){
    super.initState();
    requestAmount = 0;
  }



  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    void stateSetter(var x){
    setState(() {
      requestAmount = x;
    });
  }
    return Scaffold(
      backgroundColor: globals.primaryColor,
      appBar: AppBar(backgroundColor: globals.thirdColor,
          title: const Text('QR code generator',
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: globals.fourthColor)
          )
      ),
      body:  Container(
      decoration: BoxDecoration(
      image: DecorationImage(
      image: AssetImage("assets/2699268.jpg"),
      fit: BoxFit.cover,
      ),
      ),
        child: Column(


          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[
            SizedBox(height: 30,),
            Text("Enter amount",style: TextStyle(color: globals.secondaryColor,fontSize: 16,fontWeight: FontWeight.w700)),

            SizedBox(height: 30,),

            Center(
            child: Container(
              width: 300,
              height: 50,
              child: TextField(
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: globals.thirdColor),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  filled: true,
                  fillColor: globals.fourthColor,
                  hintText: 'Amount',
                  contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),

                ),
              controller: myController,

              onSubmitted: (String value) async {
                await showDialog<void>(
                  barrierColor: globals.fourthColor,

                  context: context,
                  builder: (BuildContext context)
                  {
                    Map<String,dynamic> jsonObject = new Map<String,dynamic>() ;
                    Map<String,dynamic> jsonObject2 = new Map<String,dynamic>() ;
                    jsonObject["address"] = globals.userAddress!.hex;
                    jsonObject2["payment"] = value;
                    jsonObject["bill"] = json.encode(jsonObject2);
                    jsonObject["type"] = "SU";
                    print(json.encode(jsonObject));

                    return Column(

                      children: [
                        QrImage(data: json.encode(


                            jsonObject

                        ),
                            size: MediaQuery.of(context).size.width - 20,

                        ),
                  ElevatedButton(

                  style: ButtonStyle(

                  backgroundColor: MaterialStateProperty.all<Color>( globals.thirdColor),
                  ),
                  onPressed:(){
                    Navigator.pushNamed(
                        context,
                        "/walletPage"
                    );


                  },
                  child: Text(
                  "Go back",
                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,color:  globals.fourthColor),
                    ),
                  ),
                      ],
                    );

                  },
                );
              },
        ),
            ),
          ),












          ],
        ),
      ),



    );

  }
}