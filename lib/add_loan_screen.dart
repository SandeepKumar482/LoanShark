import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_shark/DatabaseHelper.dart';
import 'package:loan_shark/LoanModel.dart';
import 'package:loan_shark/utils.dart';
import 'package:strings/strings.dart';

class AddLoanPopup extends StatefulWidget {
  final Loan? loan; // Optional loan data for editing

  AddLoanPopup({this.loan});
  @override
  _AddLoanPopupState createState() => _AddLoanPopupState();
}

class _AddLoanPopupState extends State<AddLoanPopup> {
  final dbHelper = DatabaseHelper();
  late final db;
  final _formKey = GlobalKey<FormState>();
  final _borrowerNameController = TextEditingController();
  final _principalAmountController = TextEditingController();
  final _monthlyInterestRateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emiRepaymentDateController = TextEditingController();
  List<PlatformFile?> _selectedDocuments = [null];
  DateTime? _selectedEmiRepaymentDate;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _borrowerNameController.text = widget.loan!.borrowerName;
      _principalAmountController.text = widget.loan!.principalAmount.toString();
      _monthlyInterestRateController.text=widget.loan!.monthlyInterestRate.toString();
      _addressController.text=widget.loan!.address.toString();
      _phoneNumberController.text=widget.loan!.phoneNumber.toString();
      _emiRepaymentDateController.text=DateFormat('dd-MM-yyyy').format(widget.loan!.emiRepaymentDate!);
      _selectedEmiRepaymentDate=widget.loan!.emiRepaymentDate;
      final documentPaths = widget.loan!.documents.split(',');
      if(documentPaths.isNotEmpty) {
        _selectedDocuments = documentPaths.map((path) {
        return PlatformFile(path: path, name: path.split('/').last, size: 0);
      }).toList();
      }
      setState(() {});
    }else{
      _emiRepaymentDateController.text=DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 30)));
      _selectedEmiRepaymentDate=DateTime.now().add(Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _principalAmountController.dispose();
    _monthlyInterestRateController.dispose();
    _phoneNumberController.dispose();
    _emiRepaymentDateController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedEmiRepaymentDate = pickedDate;
        _emiRepaymentDateController.text =
            DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      title: Text('Add Loan Record',style: TextStyle(fontWeight: FontWeight.w600),),
      // insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      content: Container(
        width: screenSize.width * 0.6,
        height: screenSize.height * 0.6,
        padding: EdgeInsets.all(24.0), // Add padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _borrowerNameController,
                      decoration: InputDecoration(
                        labelText: 'Borrower Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter borrower name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height*0.016),
                    TextFormField(
                      controller: _principalAmountController,
                      decoration: InputDecoration(
                        labelText: 'Principal Amount',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter principal amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height*0.016),
                    TextFormField(
                      controller: _monthlyInterestRateController,
                      decoration: InputDecoration(
                        labelText: 'Monthly Interest Rate',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter monthly interest rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height*0.016),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height*0.016),
                    TextFormField(
                      controller: _emiRepaymentDateController,
                      decoration: InputDecoration(
                        labelText: 'EMI Repayment Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                      ),
                      readOnly: true,
                      onTap: _presentDatePicker,
                    ),
                    SizedBox(height: screenSize.height*0.016),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on), // Add location icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height*0.016), // Add spacing below the address field
                    ..._selectedDocuments
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final document = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child:
                            Text(document?.name ?? 'No document selected'),
                          ),
                          IconButton(
                            icon: Icon(Icons.upload_file),
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                              );
                              if (result != null) {
                                setState(() {
                                  _selectedDocuments[index] =
                                      result.files.first;
                                });
                              }
                            },
                          ),
                          if (index == _selectedDocuments.length - 1)
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _selectedDocuments.add( PlatformFile(name: "", size: 0));
                                });
                              },
                            ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: screenSize.height*0.024),
                    ElevatedButton(
                      onPressed: () async{
                        if (_formKey.currentState!.validate()) {
                          // Gather loan details
                          final borrowerName = _borrowerNameController.text;
                          final principalAmount =
                          double.parse(_principalAmountController.text);
                          final monthlyInterestRate = double.parse(
                              _monthlyInterestRateController.text);
                          final phoneNumber = _phoneNumberController.text;
                          final emiRepaymentDate = _selectedEmiRepaymentDate;
          
                          // Join document names with comma
                          final documentNames = _selectedDocuments
                              .where((document) => document != null)
                              .map((document) => document!.path)
                              .join(',');

                          // Insert loan record into the database
                          // ... (your database insertion logic here) ...
                          //db=await dbHelper.database;
                          final newLoan = Loan(
                            borrowerName:Strings.toCamelCase(borrowerName),
                            principalAmount: principalAmount,
                            monthlyInterestRate: monthlyInterestRate,
                            address: Strings.toCamelCase(_addressController.text),
                            phoneNumber: phoneNumber,
                            balance: (principalAmount/100)*monthlyInterestRate,
                            emiRepaymentDate: emiRepaymentDate!,
                            documents: documentNames,
                          );
                          //Navigator.of(context).pop(newLoan);
                          if (widget.loan != null) {
                            newLoan.id = widget.loan!.id;
                            if(newLoan.principalAmount!=widget.loan!.principalAmount || newLoan.monthlyInterestRate!=widget.loan!.monthlyInterestRate) {
                              double newEmi=(newLoan.principalAmount/100)*newLoan.monthlyInterestRate;
                              newLoan.balance=newEmi+widget.loan!.balance!;// Set the ID for updating
                            }else{
                              newLoan.balance=widget.loan!.balance;
                            }
                            final loanId =
                                await dbHelper.updateLoan(newLoan);
                            // Update the loan record in the database
                            //await dbHelper.updateLoan(newLoan);
                            Utils.showToast(context, 'Record Updated Successfully');
                            final loans = Utils.loanListNotifier.value;
                            final index = loans.indexWhere((l) => l.id == newLoan.id);
                            if (index != -1) {
                              loans[index] = newLoan;
                              Utils.loanListNotifier.value = [...loans];
                            }
                            Navigator.of(context).pop(newLoan);
                          } else {
                            final loanId = await dbHelper.insertLoan(newLoan);
                            final loan = await dbHelper.getLoanRecord(loanId);
                            if (loan != null) {
                              Utils.loanListNotifier.value = [
                                ...Utils.loanListNotifier.value,
                                loan
                              ];
                              Utils.showToast(context, 'Loan Record Added Successfully');
                            } else {
                              //implement Toast message
                            }
                            Navigator.of(context).pop();
                          }

                          // Close the dialog
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.016, vertical: screenSize.height * 0.012),
                        textStyle: TextStyle(fontSize: 16.0),
                      ),
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}