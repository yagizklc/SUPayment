import 'dart:ui';
import "dart:convert";
import 'QRCodeGeneratorPage.dart';
import 'models/backend.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'dart:math'; //used for the random number generator
import "globalVariables.dart" as globals;
import 'QRCodeReaderPage.dart';
import 'package:animate_icons/animate_icons.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AnimateIconController refresh;
  late Client httpClient;
  late Client apiClient;
  late Web3Client avaxClient;
  late Response returnValue;
  late List<dynamic> ProjectObjList = [];
  List testObjects = [];
  List projectIDs = [];
  List testIcons = [];
  bool maestroLoaded = false;
  ScrollController scr = new ScrollController();
  ScrollController balanceScr = new ScrollController();
  var myData = "Loading..";
  final address = globals.userAddress; // your address
  int _counter = 0;
  String imagePath = "assets/sucoin.png";
  bool whatCoin = false;
  bool loaded = false;
  bool visible = true;
  IconData eyeIcon = CupertinoIcons.eye_fill;
  List<ProjectDTO> projects = [];

  Future getProjects() async {
    Client apiClient = new Client();
    returnValue =
        await apiClient.get(Uri.parse("http://10.0.2.2:5000/Project/Get"));
    print("kanser");
    print(returnValue.body); //finally
  }

  Future loadContract(String addr) async {
    String ABI = await rootBundle.loadString("assets/contractAbi.json");
    String contractAddress = addr; //DEPLOYMENT ADDRESS COMES HERE

    final contract = DeployedContract(ContractAbi.fromJson(ABI, "HW2Token"),
        EthereumAddress.fromHex(contractAddress));
    print("loadContract ran for $addr");
    return contract;
  }

  Future<List<dynamic>> query(
      String addr, String functionName, List<dynamic> arguments) async {
    final contract = await loadContract(addr);

    final ethFunction = contract.function(functionName);
    final result = await avaxClient.call(
        contract: contract, function: ethFunction, params: arguments);
    return result;
  }

  Future<void> getBalance() async {
    globals.credentials = EthPrivateKey.fromHex(globals.dummyPrivateKey);
    globals.userAddress = await globals.credentials.extractAddress();

    List<dynamic> result = await query(globals.suCoinContract, "balanceOf",
        [globals.userAddress]); //FONKSIYON ISMI + ARGUMANLAR
    await createTransactionList();
    myData = result[0].toString();
    List<dynamic> nameResult;
    globals.balances = [];
    globals.tokenNames = [];
    for (int i = 0; i < globals.tokenAddresses!.length; i++) {
      //loading contract twice, fix that (later maybe).
      result = await query(globals.tokenAddresses!.keys.elementAt(i),
          "balanceOf", [globals.userAddress]);
      nameResult =
          await query(globals.tokenAddresses!.keys.elementAt(i), "symbol", []);

      globals.balances.add(result[0].toString());
      globals.tokenNames.add(nameResult[0].toString());
    }

    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

//creates project obj. list
  Future<void> LoadMaestro() async {
    String ABI = await rootBundle.loadString("assets/MaestroAbi.json");
    String contractAddress = globals.MaestroAddress;

    final maestroContract = DeployedContract(
        ContractAbi.fromJson(ABI, "Maestro"),
        EthereumAddress.fromHex(contractAddress));
    final ethFunction = maestroContract.function("projectTokens");
    for (int i = 0; i < globals.projectList.length; i++) {
      List<dynamic> addr = [
        globals.projectList[i],
      ];
      final result = await avaxClient.call(
          contract: maestroContract, function: ethFunction, params: addr);
      print(result);
      ProjectObjList.add(result);
    }
    for (int i = 0; i < ProjectObjList.length; i++) {
      testObjects.add([ProjectObjList[i][0]]);
      projectIDs.add([ProjectObjList[i][1]]);
      testIcons.add([ProjectObjList[i][2]]);
    }
    setState(() {
      maestroLoaded = true;
    });
  }

  Future<void> useSwap(BigInt amount, bool whatCoin) async {
    var approvalResult;
    String ABI = await rootBundle.loadString("assets/swapAbi.json");
    String contractAbi = await rootBundle.loadString("assets/contractAbi.json");
    String contractAddress =
        globals.swapContract; //DEPLOYMENT ADDRESS COMES HERE
    final swapContract = DeployedContract(ContractAbi.fromJson(ABI, "Exchange"),
        EthereumAddress.fromHex(contractAddress));
    List<dynamic> arguments = [];
    arguments.add(amount);
    arguments.add(whatCoin);
    final swapFunction = swapContract.function("Swap");
    //APPROVAL YAZ
    List<dynamic> swapApprovalArguments = [
      EthereumAddress.fromHex(globals.swapContract),
      amount
    ];
    setState(() {
      isLoading = true;
      condition = "Approving";
    });
    if (whatCoin) {
      final contract = DeployedContract(
          ContractAbi.fromJson(contractAbi, "HW2Token"),
          EthereumAddress.fromHex(globals.suCoinContract));
      final approval = contract.function("approve");

      approvalResult = await avaxClient.sendTransaction(
          globals.credentials,
          Transaction.callContract(
              contract: contract,
              function: approval,
              parameters: swapApprovalArguments));
    } else {
      final contract = DeployedContract(
          ContractAbi.fromJson(contractAbi, "HW2Token"),
          EthereumAddress.fromHex(globals.biLiraContract));
      final approval = contract.function("approve");
      approvalResult = await avaxClient.sendTransaction(
          globals.credentials,
          Transaction.callContract(
              contract: contract,
              function: approval,
              parameters: swapApprovalArguments));
    }
    setState(() {
      condition = "Swapping";
    });
    print(approvalResult);
    await Future.delayed(Duration(seconds: 10));
    final result = await avaxClient.sendTransaction(
        globals.credentials,
        Transaction.callContract(
            contract: swapContract,
            function: swapFunction,
            parameters: arguments));
    print(result);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> createTransactionList() async {
    Client apiClient = new Client();
    Response returnValue;
    Response ERC20ReturnValue;
    returnValue = await apiClient.get(Uri.parse(globals.apiFirstPart +
        "${globals.userAddress}" +
        globals.apiSecondPart));
    ERC20ReturnValue = await apiClient.get(Uri.parse(globals.ERC20apiFirstPart +
        "${globals.userAddress}" +
        globals.ERC20apiSecondPart));
    globals.ERC20ReturnValue =
        await json.decode(ERC20ReturnValue.body)["result"];
    globals.returnValue = await json.decode(returnValue.body)["result"];
    globals.itemCount = globals.returnValue.length;
    print("createTransactionList ran");
    for (int i = 0; i < globals.ERC20ReturnValue.length; i++) {
      if (globals.ERC20ReturnValue[i]["contractAddress"] !=
          globals.suCoinContract) {
        globals.tokenAddresses![globals.ERC20ReturnValue[i]
            ["contractAddress"]] = globals.ERC20ReturnValue[i];
      }
    }

    //HashMap creator, used for speeding up creation of txlist.
  }

  Future<void> resetPage() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/walletPage');
  }

  bool onEndIconPress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Refreshing.."),
        duration: Duration(seconds: 1),
      ),
    );
    return true;
  }

  bool onStartIconPress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Refreshing.."),
        duration: Duration(seconds: 1),
      ),
    );

    resetPage();
    return true;
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  void makeInvis() {
    setState(() {
      if (eyeIcon == CupertinoIcons.eye_slash_fill) {
        eyeIcon = CupertinoIcons.eye_fill;
        visible = true;
      } else {
        eyeIcon = CupertinoIcons.eye_slash_fill;
        visible = false;
      }
    });
  }

  bool isLoading = false;
  String condition = "Approving";
  @override
  void initState() {
    super.initState();
    isLoading = false;
    httpClient = Client();
    avaxClient = Web3Client(globals.RPC, httpClient); // JSON RPC

    refresh = AnimateIconController();
    //similar to JS very simple.
    getProjects();
    getBalance();
    LoadMaestro();
  }

  @override
  int currentIndex = 0;

  Widget build(BuildContext context) {
    if (currentIndex == 0) {
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
                margin: EdgeInsets.symmetric(horizontal: 64, vertical: 64),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //address part
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40)),
                          color: globals.fourthColor,
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text("Address: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: globals.secondaryColor)),
                            Flexible(
                              fit: FlexFit.loose,
                              child: new Container(
                                padding: new EdgeInsets.only(right: 13.0),
                                child: new Text(
                                  "${globals.userAddress}",
                                  overflow: TextOverflow.ellipsis,
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                    color: globals.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      //balance part at top
                      Row(children: <Widget>[
                        Flexible(
                            flex: 5,
                            fit: FlexFit.tight,
                            child: Text(
                                visible == true
                                    ? "$myData\₺SU"
                                    : '${"$myData\₺SU".replaceAll(RegExp(r"."), "*")}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700))),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: IconButton(
                              onPressed: () {
                                makeInvis();
                              },
                              alignment: Alignment.center,
                              icon: Icon(
                                eyeIcon,
                                color: Colors.white,
                                size: 32,
                              )),
                        ),
                      ]),

                      //sending and receiving buttons
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        globals.thirdColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const qrCodeGenerator(),
                                ));
                              },
                              child: const Text('Receive'),
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        globals.thirdColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const QRViewExample(),
                                ));
                              },
                              child: const Text('Send'),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
              //top part

              DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.3,
                  maxChildSize: 0.81,
                  builder: (context, balanceScr) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage("assets/Txbackground.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 5,
                                    fit: FlexFit.tight,
                                    child: Text("Other balances",
                                        style: TextStyle(
                                            color: globals.secondaryColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24)),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: AnimateIcons(
                                      clockwise: true,
                                      startIcon: Icons.update_sharp,
                                      endIcon: Icons.update_sharp,
                                      controller: refresh,
                                      startIconColor: globals.secondaryColor,
                                      endIconColor: globals.secondaryColor,
                                      size: 24,
                                      onEndIconPress: () =>
                                          onEndIconPress(context),
                                      onStartIconPress: () =>
                                          onStartIconPress(context),
                                    ),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 0),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  controller: balanceScr,
                                  itemCount: globals.tokenAddresses!.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int indexing) {
                                    if (indexing ==
                                        globals.tokenAddresses!.length) {
                                      return (SizedBox(
                                        height: 250,
                                      ));
                                    }
                                    if (loaded) {
                                      return Card(
                                        child: ListTile(
                                          tileColor: Colors.white,

                                          leading: FlutterLogo(),
                                          title: Text(
                                            (
                                                //globals.tokenAddresses![globals.tokenAddresses!.keys.elementAt(indexing)]!["hash"]
                                                globals.balances[
                                                    indexing] // token amount

                                            ),
                                          ),
                                          subtitle: Text(globals.tokenNames[
                                              indexing]), // token symbol
                                        ),
                                      );
                                    } else {
                                      return Card(
                                        color: Colors.white54,
                                        child: ListTile(
                                          title: Text((
                                              //globals.tokenAddresses![globals.tokenAddresses!.keys.elementAt(indexing)]!["hash"]
                                              "Loading..")),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                          ]),
                    );
                  }),
              //Other balances

              DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.2,
                  maxChildSize: 0.7,
                  builder: (context, scr) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage("assets/Txbackground.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  flex: 5,
                                  fit: FlexFit.tight,
                                  child: Text("Transaction History",
                                      style: TextStyle(
                                          color: globals.secondaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24)),
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: AnimateIcons(
                                    clockwise: true,
                                    startIcon: Icons.update_sharp,
                                    endIcon: Icons.update_sharp,
                                    controller: refresh,
                                    startIconColor: globals.secondaryColor,
                                    endIconColor: globals.secondaryColor,
                                    size: 24,
                                    onEndIconPress: () =>
                                        onEndIconPress(context),
                                    onStartIconPress: () =>
                                        onStartIconPress(context),
                                  ),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 0),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: scr,
                              itemCount: globals.itemCount,
                              itemBuilder:
                                  (BuildContext context, int indexing) {
                                int index = globals.itemCount - indexing - 1;
                                var sentBalance = BigInt.tryParse(
                                        globals.returnValue[index]["value"])! /
                                    BigInt.tryParse("1000000000000000000")!;
                                var gas = BigInt.tryParse(
                                    globals.returnValue[index]["gas"]);
                                var gasPrice = BigInt.tryParse(
                                    globals.returnValue[index]["gasPrice"]);
                                double gasPriceInAvax = (gas! * gasPrice!) /
                                    BigInt.tryParse("1000000000000000000")!;
                                DateTime txTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.tryParse(globals.returnValue[index]
                                                ["timeStamp"])! *
                                            1000);
                                DateTime currentTime = DateTime.now();
                                String minute = "";
                                int SendRecv = 0;
                                //check if sent balance is too low

                                //Arrange time
                                if (txTime.minute < 10) {
                                  minute = "0" + txTime.minute.toString();
                                } else {
                                  minute = txTime.minute.toString();
                                }

                                //Arrange sender-receiver for UI
                                if (globals.returnValue[index]["from"] ==
                                    "${globals.userAddress}") {
                                  SendRecv = 1;
                                } else if (globals.returnValue[index]["to"] ==
                                    "${globals.userAddress}") {
                                  SendRecv = 2;
                                } else {
                                  SendRecv = 0;
                                }

                                //ERC-20 CHECK
                                int iterator = 0;
                                String ERC20Value = "AVAX";

                                if (globals.returnValue[index]["input"].length >
                                    10) {
                                  if (globals.returnValue[index]["input"]
                                          .substring(0, 10) ==
                                      "0x095ea7b3") {
                                    return SizedBox.shrink();
                                  }
                                }

                                //too slow, use hash table.
                                while (iterator <
                                    globals.ERC20ReturnValue.length) {
                                  if (globals.returnValue[index]["hash"] ==
                                      globals.ERC20ReturnValue[iterator]
                                          ["hash"]) {
                                    if (globals.ERC20ReturnValue[iterator]
                                            ["from"] ==
                                        "0x0000000000000000000000000000000000000000") {
                                      SendRecv = 3;
                                    }
                                    //check if interaction is between user and swap

                                    if (globals.ERC20ReturnValue[iterator]
                                            ["to"] ==
                                        globals.swapContract) {
                                      //check lenght for iterator+1
                                      if (globals.ERC20ReturnValue.length >
                                          iterator + 1) {
                                        if (globals.ERC20ReturnValue[
                                                iterator + 1]["from"] ==
                                            globals.swapContract) {
                                          SendRecv = 5;
                                          ERC20Value = "Sent:" +
                                              globals.ERC20ReturnValue[iterator]
                                                  ["value"] +
                                              " " +
                                              globals.ERC20ReturnValue[iterator]
                                                  ["tokenSymbol"] +
                                              "\nReceived: " +
                                              globals.ERC20ReturnValue[
                                                  iterator + 1]["value"] +
                                              " " +
                                              globals.ERC20ReturnValue[
                                                  iterator + 1]["tokenSymbol"];
                                        }
                                      }
                                    } else if (globals
                                            .ERC20ReturnValue[iterator]["input"]
                                            .substring(0, 10) ==
                                        "0x095ea7b3") {
                                      return SizedBox.shrink();
                                    } else {
                                      ERC20Value =
                                          globals.ERC20ReturnValue[iterator]
                                                  ["value"] +
                                              " " +
                                              globals.ERC20ReturnValue[iterator]
                                                  ["tokenSymbol"];
                                    }

                                    break;
                                  }
                                  iterator++;
                                }

                                if (globals.returnValue[index]["isError"] ==
                                    "1") {
                                  return Card(
                                    child: ListTile(
                                      leading: Icon(Icons.warning),
                                      title: Text(
                                          'Block ${globals.returnValue[index]["blockNumber"]}'),
                                      tileColor: Colors.white,
                                      onTap: () {},
                                    ),
                                  );
                                } else {
                                  if (globals.returnValue[index]
                                          ["contractAddress"] ==
                                      "") {
                                    if (SendRecv == 1)
                                    //sender
                                    {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(
                                              CupertinoIcons.arrow_up_circle,
                                              size: 30),
                                          title: Text('Sent ${ERC20Value}'),
                                          subtitle: Text(
                                              'Time: ${txTime.hour}:${minute} Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                          trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '$sentBalance AVAX',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                )
                                              ]),
                                          tileColor: Colors.white,
                                          onTap: () {},
                                        ),
                                      );
                                    } else if (SendRecv == 2)
                                    //receiver
                                    {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(
                                              CupertinoIcons.arrow_down_circle,
                                              size: 30),
                                          title: Text('Received ${ERC20Value}'),
                                          subtitle: Text(
                                              'Time: ${txTime.hour}:${minute} Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                          trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '$sentBalance AVAX',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                )
                                              ]),
                                          tileColor: Colors.white,
                                          onTap: () {},
                                        ),
                                      );
                                    } else if (SendRecv == 3) {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(CupertinoIcons.hammer,
                                              size: 30),
                                          title: Text('Mint ${ERC20Value}'),
                                          subtitle: Text(
                                              'Time: ${txTime.hour}:${minute} Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                          trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '$sentBalance AVAX',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                )
                                              ]),
                                          tileColor: Colors.white,
                                          onTap: () {},
                                        ),
                                      );
                                    } else if (SendRecv == 4) {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(CupertinoIcons.hammer,
                                              size: 30),
                                          title: Text('Mint ${ERC20Value}'),
                                          subtitle: Text(
                                              'Time: ${txTime.hour}:${minute} Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                          trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '$sentBalance AVAX',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                )
                                              ]),
                                          tileColor: Colors.white,
                                          onTap: () {},
                                        ),
                                      );
                                    } else if (SendRecv == 5) {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(
                                              CupertinoIcons
                                                  .arrow_up_arrow_down_circle,
                                              size: 30),
                                          title: Text('${ERC20Value}'),
                                          subtitle: Text(
                                              'Time: ${txTime.hour}:${minute} Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                          trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '$sentBalance AVAX',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                )
                                              ]),
                                          tileColor: Colors.white,
                                          onTap: () {},
                                        ),
                                      );
                                    } else {
                                      return Card(
                                        child: ListTile(
                                          leading: Icon(
                                              CupertinoIcons.tray_arrow_down,
                                              size: 30),
                                          title:
                                              Text('THIS IS A BUG $ERC20Value'),
                                          subtitle: Text(
                                              'Time: ${txTime.hour}:$minute Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                          trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '$sentBalance AVAX',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                                Text(
                                                  'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                )
                                              ]),
                                          tileColor: Colors.white,
                                          onTap: () {},
                                        ),
                                      );
                                    }
                                  } else {
                                    return Card(
                                      child: ListTile(
                                        leading:
                                            Icon(Icons.wysiwyg_sharp, size: 30),
                                        tileColor: Colors.white,
                                        title: Text('Contract Creation'),
                                        subtitle: Text(
                                            'Time: ${txTime.hour}:${minute} Date: ${txTime.day}/${txTime.month}/${txTime.year}'),
                                        trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '$sentBalance AVAX',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              Text(
                                                'Gas: ${roundDouble(gasPriceInAvax, 6)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              )
                                            ]),
                                        onTap: () {},
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              //tx history
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: globals.primaryColor,
            selectedItemColor: globals.secondaryColor,
            unselectedItemColor: globals.fourthColor,
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: "Wallet",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: "Swap",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: "Funding",
              )
            ]),
      );
    } else if (currentIndex == 1) {
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
              Column(children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 300,
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 3, color: globals.fourthColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 3, color: globals.thirdColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Swap amount',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                      ),
                      controller: myController,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("For:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 100,
                      icon: Image(image: AssetImage("$imagePath")),
                      onPressed: () {
                        setState(() {
                          //Set swap parameters
                          if (imagePath == "assets/bilira.png") {
                            imagePath = "assets/sucoin.png";
                            whatCoin = false;
                          } else {
                            imagePath = "assets/bilira.png";
                            whatCoin = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(globals.thirdColor),
                    ),
                    child: Text(
                      "Swap",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: globals.fourthColor),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      useSwap(BigInt.tryParse(myController.text)!, whatCoin);
                    },
                  ),
                ),
                Container(
                  height: 50,
                ),
                Visibility(
                  child: Column(
                    children: <Widget>[
                      Image(image: AssetImage("assets/loading.gif"), width: 50),
                      Text("Please don't leave this page."),
                      Text(condition),
                    ],
                  ),
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isLoading,
                ),
              ]),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: globals.primaryColor,
            selectedItemColor: globals.secondaryColor,
            unselectedItemColor: globals.fourthColor,
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: "Wallet",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: "Swap",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: "Funding",
              )
            ]),
      );
    } else {
      ScrollController borsaScroll = new ScrollController();

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/2699268.jpg"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40))),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: Text(
                  "Funding",
                  style: TextStyle(
                      color: globals.secondaryColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 28),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  "Fund your favourite projects on Sabanci University",
                  style: TextStyle(
                      color: globals.secondaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  controller: borsaScroll,
                  itemCount: testObjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (maestroLoaded) {
                      return Card(
                        child: ListTile(
                          tileColor: Colors.white,
                          subtitle: Column(
                            children: [
                              Text("Auction address: " +
                                  projectIDs[index].toString()),
                              Text("Token address: " +
                                  testIcons[index].toString()),
                            ],
                          ),
                          title: Text(
                              "Proposer: " + testObjects[index].toString()),
                          trailing: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: globals.primaryColor),
                                ),
                              ),
                            ),
                            child: Text("More info"),
                            onPressed: () {},
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        child: ListTile(
                          tileColor: Colors.white,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: globals.primaryColor,
            selectedItemColor: globals.secondaryColor,
            unselectedItemColor: globals.fourthColor,
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: "Wallet",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: "Swap",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: "Funding",
              )
            ]),
      );
    }
  }
}
