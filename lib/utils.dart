import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LoanModel.dart';

class Utils{
  static final loanListNotifier = ValueNotifier<List<Loan>>([]);

  static void  showToast(BuildContext context, String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
        duration: Duration(seconds: 2), // Adjust duration as needed
      ),
    );
  }
}