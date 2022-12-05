import 'package:http/http.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import "globalVariables.dart" as globals;
import 'package:shared_preferences/shared_preferences.dart';


class MakePayment extends StatefulWidget{
  MakePayment({Key? key, required this.paymentAddr, required this.paymentType, required this.paymentList, required this.totalValue}) : super(key: key);
  final String paymentAddr;
  final String paymentType;
  final String paymentList;
  final BigInt totalValue;
  late Web3Client avaxClient;
  @override
  _MakePayment createState() => _MakePayment(paymentAddr: paymentAddr,paymentList: paymentList,paymentType: paymentType,totalValue: totalValue);
}


class _MakePayment extends State<MakePayment>{
  _MakePayment({Key? key, required this.paymentAddr, required this.paymentType, required this.paymentList, required this.totalValue}) ;

  final String paymentAddr;
  final String paymentType;
  final String paymentList;
  final BigInt totalValue;
  late Web3Client avaxClient;
  late Client httpClient;

  @override
  void initState(){
    httpClient = Client();
    avaxClient = Web3Client(globals.RPC, httpClient); // JSON RPC
    super.initState();

  }

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
  Future<void> makeSuCoinTransaction(String receiver, BigInt amount, context) async {

    globals.credentials = EthPrivateKey.fromHex(globals.dummyPrivateKey);
    globals.userAddress = await globals.credentials.extractAddress();

    List<dynamic> args = [EthereumAddress.fromHex(receiver),amount];
    try {
      await sendTx("transfer", args);
      Navigator.pop(context);
    }
    catch(err) {
      print(err);

    }



  }



  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: globals.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/2699268.jpg"),
            fit: BoxFit.cover,
          ),

        ),

        child: IconButton(
          icon: Icon(Icons.announcement),
          onPressed: (){
            makeSuCoinTransaction(paymentAddr, totalValue, context);
            },
        ),

      ),
    );
  }
}