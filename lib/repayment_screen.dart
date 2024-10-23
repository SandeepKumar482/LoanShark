import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_shark/LoanModel.dart';
import 'package:loan_shark/utils.dart';

import 'DatabaseHelper.dart';
import 'repayment_model.dart';

class RecordPaymentScreen extends StatefulWidget {
  final int loanId;

  RecordPaymentScreen({required this.loanId});

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentDateController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  String? _selectedPaymentMethod;
  final _notesController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _paymentDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.300,
          vertical: screenSize.height * 0.290),
      child: Padding(
        // Return Padding directly
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Payment Date
              TextFormField(
                controller: _paymentDateController,
                decoration: InputDecoration(
                  labelText: 'Payment Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  // ... (validation logic)
                },
              ),
              // Payment Amount
              TextFormField(
                controller: _paymentAmountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  // ... (validation logic)
                },
              ),
              // Payment Method
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: ['Online Banking', 'Credit-Debit Card', 'UPI', 'Cash']
                    .map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                validator: (value) {
                  // ... (validation logic)
                },
              ),
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              SizedBox(height: screenSize.height * 0.020),
              // Record Payment Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5, // Set elevation to 5
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // ... (create Repayment object and return it)
                    // Create a Repayment object
                    final loan = await dbHelper.getLoanRecord(widget.loanId);
                    if (loan != null) {
                      /*double minInstallment = loan.balance!;
                      if (double.parse(_paymentAmountController.text) >=
                          minInstallment) {*/
                        // await dbHelper.insertRepayment(repayment);
                        // await recordPayment(repayment);
                        final repayment = Repayment(
                          loanId: widget.loanId,
                          paymentDate:
                              DateTime.parse(_paymentDateController.text),
                          paymentAmount:
                              double.parse(_paymentAmountController.text),
                          paymentMethod: _selectedPaymentMethod!,
                          notes: _notesController.text,
                        );
                        try {
                          await dbHelper.insertRepayment(repayment);
                          await recordPayment(repayment);
                          Utils.showToast(context, 'Payment Recorded Successfully');
                        }catch(e){
                          Utils.showToast(context, e.toString());
                        }
                        // Return the repayment object
                        Navigator.of(context).pop(repayment);
                      /*} else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Minimum Repayment Amount for ${loan.borrowerName} should be of ${minInstallment}')),
                        );
                      }*/
                    }
                  }
                },
                child: Text(
                  'Record Payment',
                  style: TextStyle(fontSize: screenSize.height * 0.018),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> recordPayment(Repayment repayment) async {
    final loan = await dbHelper.getLoanRecord(repayment.loanId);
    if (loan != null) {
      double minInstallment = loan.balance!;
      if (repayment.paymentAmount >= minInstallment) {
        double newPrincipalAmount =
            loan.principalAmount - (repayment.paymentAmount - minInstallment);
        final newLoan = Loan(
            id: loan.id,
            borrowerName: loan.borrowerName,
            principalAmount: newPrincipalAmount,
            monthlyInterestRate: loan.monthlyInterestRate,
            address: loan.address,
            balance: (newPrincipalAmount/100)*loan.monthlyInterestRate,
            phoneNumber: loan.phoneNumber,
            emiRepaymentDate: loan.emiRepaymentDate!.add(Duration(days: 30)),
            documents: loan.documents);
        final loanId = await dbHelper.updateLoan(newLoan);
      } else {
        //Handle other cases.
        final newLoan = Loan(
            id: loan.id,
            borrowerName: loan.borrowerName,
            principalAmount: loan.principalAmount,
            monthlyInterestRate: loan.monthlyInterestRate,
            address: loan.address,
            balance: loan.balance!-repayment.paymentAmount,
            phoneNumber: loan.phoneNumber,
            emiRepaymentDate: loan.emiRepaymentDate,
            documents: loan.documents);
        final loanId = await dbHelper.updateLoan(newLoan);
      }
    }
  }
}
