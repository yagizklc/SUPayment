import 'dart:typed_data';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import "dart:convert";
import "dart:typed_data";

import 'package:convert/convert.dart';

//QR code result
Barcode? globalResult;

//User info
var credentials;
var dummyPrivateKey =
    ""; //test account, private key will be generated later on.
var pass;
var tempMnemonic;

//Su coin contract details, and RPC
var suCoinContract = "0xaecef529f34bbf7eac10fce59b7c068685c81d9c";
var swapContract = "0xa289d3ef1e6dc646be5c4c764c4b33d74ce35070";
var biLiraContract = "0x748b33652d3dF39be54a1c3C378b7d9178D20543";
const RPC = "https://api.avax-test.network/ext/bc/C/rpc";
EthereumAddress? userAddress;
var apiFirstPart =
    "https://api-testnet.snowtrace.io/api?module=account&action=txlist&address=";
var apiSecondPart =
    "&startblock=1&endblock=999999999&sort=asc&apikey=PZS5ZQDASD1E8VY7JSXAEQIKG43XGIYIA7";
var ERC20apiFirstPart =
    "https://api-testnet.snowtrace.io/api?module=account&action=tokentx&address=";
var ERC20apiSecondPart =
    "&startblock=0&endblock=999999999&sort=asc&apikey=PZS5ZQDASD1E8VY7JSXAEQIKG43XGIYIA7";
var returnValue;
var ERC20ReturnValue;
var MaestroAddress = "0x4ED02B5dA043d8c9882f11B9784D67f2a7E9cC7C";
List<List<dynamic>> projectList = [
  hex.decode(
      "a190d2b3a3323f420e5df6078d27bf6d7d76144aea19e32cb66ff61b4ad07d2d"),
  hex.decode("4fd063a659cd3fe36b2ae58f30c5b7e36e5b0e10fcc2e447ebd76a5443ea2689")
]; // should come from backend
Map<String, Map<String, dynamic>?>? tokenAddresses;
int itemCount = 0;
List<String> balances = [];
List<String> tokenNames = [];
Map<String, Map<String, dynamic>> returnValueMapped = {};

//UI design
const primaryColor = Colors.blue;
const secondaryColor = Colors.black;
const thirdColor = Colors.black12;
const fourthColor = Colors.white;
