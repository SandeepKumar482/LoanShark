import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_shark/repayment_model.dart';

import 'DatabaseHelper.dart';

class RepaymentRecordsScreen extends StatefulWidget {
  final int loanId;

  RepaymentRecordsScreen({required this.loanId});

  @override
  _RepaymentRecordsScreenState createState() => _RepaymentRecordsScreenState();
}

class _RepaymentRecordsScreenState extends State<RepaymentRecordsScreen> {
  List<Repayment> _repayments = [];
  final dbHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _fetchRepaymentRecords();
  }

  Future<void> _fetchRepaymentRecords() async {
    final repayments = await dbHelper.getRepaymentsForLoan(widget.loanId);
    setState(() {
      _repayments = repayments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize=MediaQuery.of(context).size;
    return SingleChildScrollView( // Enable scrolling for long lists
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repayment Records',
              style: TextStyle(fontSize: screenSize.height*0.020, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: screenSize.height*0.012),
            if (_repayments.isEmpty)
              Center(child: Text('No repayment records found.',style: TextStyle(fontSize: screenSize.height*0.016,fontWeight: FontWeight.w800),),)
            else
              ListView.builder(
                shrinkWrap: true, // Important for ListView inside Column
                physics: NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
                itemCount: _repayments.length,
                itemBuilder: (context, index) {
                  final repayment = _repayments[index];
                  return ListTile(
                    leading: Icon(Icons.payment,size: screenSize.height*0.040,),
                    title: Text('₹${repayment.paymentAmount.toStringAsFixed(2)}',style: TextStyle(fontSize: screenSize.height*0.020,fontWeight: FontWeight.w600),),
                    subtitle: Text(
                      '${DateFormat('dd-MM-yyyy').format(repayment.paymentDate)} - ${repayment.paymentMethod}',style: TextStyle(fontSize: screenSize.height*0.016,fontWeight: FontWeight.w500),
                    ),
                    trailing: repayment.notes != null ? Text('Remarks: ${repayment.notes}',style: TextStyle(fontSize: screenSize.height*0.016,fontWeight: FontWeight.w600),) : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}