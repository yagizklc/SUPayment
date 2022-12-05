import 'dart:typed_data';
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
import "QRCodeReaderPage.dart";


class qrCodeScanner extends StatelessWidget {
  const qrCodeScanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.primaryColor,
      appBar: AppBar(backgroundColor: globals.thirdColor,
          title: const Text('QR demo',
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: globals.fourthColor)
          )
      ),
      body:  Column(


        mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[
          Row(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(

          width: 160,
          height: 100,
          child:
          ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(globals.thirdColor),),

          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const qrCodeGenerator(),
            ));
          },
          child: const Text('QR Code Generator'),
        ),),
        SizedBox(
            width: 160,
            height: 100,

            child:
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(globals.thirdColor),),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRViewExample(),
                ));
              },
              child: const Text('QR Code Scanner'),
            ),
        ),
            ]
          )


        ],
      ),



      );

  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  late Client httpClient;
  late Web3Client avaxClient;
  var myData = "Loading..";
  Barcode? result = globals.globalResult;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');


  Future loadContract()async {
    String ABI = await rootBundle.loadString("assets/contractAbi.json");

    final contract = DeployedContract(ContractAbi.fromJson(ABI,"HW2Token"), EthereumAddress.fromHex(globals.suCoinContract));
    return contract;
  }

  Future<List<dynamic>> query(String functionName,List<dynamic> arguments)async{
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await avaxClient.call(contract: contract, function: ethFunction, params: arguments);
    return result;
  }
  Future<String> sendTx(String functionName,List<dynamic> arguments)async{
    final contract = await loadContract();
    final ethFunction = await contract.function(functionName);
    String response = await avaxClient.sendTransaction(globals.credentials, Transaction.callContract(contract: contract, function: ethFunction, parameters: arguments));

    return response;
  }



  Future<void> getBalance(String targetAddress) async
  {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("balanceOf",[address]); //function name + arguments.

    myData = result[0].toString();
    print(result[0]);
    setState(() {
    });
  }

  Future<void> makeSuCoinTransaction(String receiver, BigInt amount, context) async
  {

    globals.credentials = EthPrivateKey.fromHex(globals.dummyPrivateKey);
    globals.userAddress = await globals.credentials.extractAddress();

    List<dynamic> args = [EthereumAddress.fromHex(receiver),amount];
    try {
      await sendTx("transfer", args);

      Navigator.pop(context);

      Alert(
          context: context,
          type: AlertType.success,

          content: Column(

            children: <Widget>[
              Text("Transaction Sent Successfully!"),

            ],
          ),
          buttons: [
            DialogButton(

              color: globals.primaryColor,
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Okay",
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,color: globals.secondaryColor),
              ),
            )
          ]).show();
    }
    catch(err) {
      print(err);
      Alert(
          context: context,
          type: AlertType.error,

          content: Column(

            children: <Widget>[
              Text("Transaction Failed!\nTalk to Eren Akyildiz for info."),

            ],
          ),
          buttons: [
            DialogButton(

              color: globals.primaryColor,
              onPressed: () => Navigator.pop(context),
              child: Text(
                ":(",
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,color: globals.secondaryColor),
              ),
            )
          ]).show();
    }



  }



  void initState() {
    super.initState();


    httpClient = Client();
    avaxClient = Web3Client(globals.RPC, httpClient); // JSON RPC

    //similar to JS very simple.

  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void _openPopup(context) {
    Barcode? result = globals.globalResult;

    if (result != null) {
      Map<String, dynamic> regularInfo = jsonDecode(result.code!);
      Map<String, dynamic> purchaseInfo = jsonDecode(regularInfo["bill"]);
      String paymentAddr = regularInfo["address"];
      String paymentType = regularInfo["type"];
      String paymentList = "";
      int totalValue = 0;
      for(int i = 0; i < purchaseInfo.length;i++){

          paymentList +=
          "${purchaseInfo.keys.elementAt(i)} : ${purchaseInfo.values.elementAt(
              i)} \$${paymentType} \n";


        totalValue += int.tryParse(purchaseInfo.values.elementAt(i))!;
      }

      var x = new BigInt.from(totalValue);

      Alert(
          context: context,
          type: AlertType.warning,

          content: Column(

            children: <Widget>[
              Text("\nPayment to: ${paymentAddr} \n"), // maybe use a database for everyone's addresses
              Text("Your bill:"),
              Text(paymentList),
              Text("Total comes up to: ${totalValue} \$$paymentType")
            ],
          ),
          buttons: [
            DialogButton(

              color: globals.primaryColor,
              onPressed: () => makeSuCoinTransaction(paymentAddr, x,context),
              child: Text(
                "Pay",
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,color: globals.secondaryColor),
              ),
            )
          ]).show();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(flex: 6, child: _buildQrView(context)),
            Expanded(
              flex: 1,
              child: FittedBox(


                fit: BoxFit.contain,
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                      const Text('Scan a QR code', style: TextStyle(color: globals.secondaryColor, fontSize: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 75,
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: globals.thirdColor,
                              textStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),


                            ),
                              onPressed: () async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getFlashStatus(),
                                builder: (context, snapshot) {
                                  if(snapshot.data == false){
                                    return Icon(Icons.flash_off_sharp,size: 40);
                                  }
                                  else {
                                    return Icon(Icons.flash_on_sharp, size: 40,);
                                  }
                                },
                              )),
                        ),

                        Container(
                          width: 100,
                          height: 75,
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(

                              onPressed: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                primary: globals.thirdColor,
                                textStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),

                              ),
                              child: FutureBuilder(
                                future: controller?.getCameraInfo(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    if (snapshot.data == CameraFacing.back){
                                      return Icon(Icons.photo_camera_back,size: 40,);
                                    }
                                    else {

                                      return Icon(Icons.face,size: 40,);
                                    }
                                  } else {
                                    return const Text('loading');
                                  }
                                },
                              )),
                        ),
                        Container(
                          width: 100,
                          height: 75,
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: globals.thirdColor,
                                textStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),


                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context,
                                    "/walletPage"
                                );

                              },
                              child: Icon(Icons.keyboard_return,size: 40),
                              ),
                        ),
                        Container(
                          width: 100,
                          height: 75,
                          margin: const EdgeInsets.all(8),

                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(
                              primary: globals.thirdColor,
                              textStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),

                            ),
                            onPressed: () async {
                              await controller?.pauseCamera();
                            },

                            child: const Icon(

                              Icons.pause,
                              size: 40,
                            ),

                          ),
                        ),
                        Container(
                          width: 100,
                          height: 75,
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: globals.thirdColor,
                              textStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),

                            ),
                            onPressed: () async {
                              await controller?.resumeCamera();
                            },
                            child: const Icon(

                              Icons.play_arrow,
                              size: 40,
                            ),
                          ),
                        )

                      ],
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: globals.fourthColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;


    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        globals.globalResult = result;
        _openPopup(context);
        this.controller?.pauseCamera();
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
