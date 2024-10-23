import 'package:flutter/material.dart';
import 'package:loan_shark/DatabaseHelper.dart';
import 'package:loan_shark/LoanModel.dart';
import 'package:intl/intl.dart';
import 'package:loan_shark/add_loan_screen.dart';
import 'package:loan_shark/payment_history.dart';
import 'package:loan_shark/repayment_model.dart';
import 'package:loan_shark/repayment_screen.dart';
import 'package:loan_shark/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:strings/strings.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();
  late final db;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  void addDummyLoan() async {
    db = await dbHelper.database;
    final newLoan = Loan(
      borrowerName: 'John Doe',
      principalAmount: 10000,
      monthlyInterestRate: 5,
      address: '123 Main St',
      phoneNumber: '555-1234',
      balance: 3000.0,
      emiRepaymentDate: DateTime.now(),
      documents: '',
    );
    final loanId = await dbHelper.insertLoan(newLoan);
  }

  @override
  void initState() {
    //addDummyLoan();
    _fetchLoansNew('');
    super.initState();
  }

  Future<void> _fetchLoans() async {
    //db=await dbHelper.database;
    final fetchedLoans = await dbHelper.getAllLoans();
    Utils.loanListNotifier.value = fetchedLoans;
  }

  Future<void> _fetchLoansNew([String query = '']) async {
    final fetchedLoans = await dbHelper.searchLoans(query);
    if(fetchedLoans.isNotEmpty){
      List<Loan>loans=fetchedLoans;
      for(Loan loan in loans){
        if(loan.emiRepaymentDate!.isBefore(DateTime.now())){
          loan.emiRepaymentDate=loan.emiRepaymentDate!.add(Duration(days: 30));
          loan.balance=loan.balance!+((loan.principalAmount/100)*loan.monthlyInterestRate);
          await dbHelper.updateLoan(loan);
        }
      }
    }
    final loans=await dbHelper.searchLoans(query);
    Utils.loanListNotifier.value = loans;

  }

  void _showLoanDetails(Loan loan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          title: Text('Loan Details',
              style: TextStyle(
                  fontSize: screenSize.height * 0.026,
                  fontWeight: FontWeight.w800)),
          titlePadding: EdgeInsets.fromLTRB(screenSize.width * 0.024,
              screenSize.height * 0.024, 24, screenSize.height * 0.012),
          // Add padding
          contentPadding: EdgeInsets.fromLTRB(
              screenSize.width * 0.024,
              screenSize.height * 0.012,
              screenSize.width * 0.024,
              screenSize.height * 0.024),
          // Add padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          elevation: 5.0,
          actions: <Widget>[
            TextButton(
              child: Text('Update'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the details dialog
                _showUpdateLoanScreen(context, loan);
                //
                // Open update screen
              },
            ),
            TextButton(
              child: Text('Record Payment'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the details dialog
                _showRecordPaymentScreen(
                    context, loan); // Open record payment screen
              },
            ),
            TextButton(
              child: Text('Payment History'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the details dialog
                _showRepaymentRecordsScreen(
                    context, loan.id!); // Open repayment records screen
              },
            ),
            TextButton(
              child: Text('Loan Update History'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the details dialog
                _showUpdateHistoryDialog(context, loan.id!);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context, loan);
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', loan.id.toString(), Icons.tag),
                _buildDetailRow(
                    'Borrower Name', loan.borrowerName, Icons.person),
                _buildDetailRow('Principal Amount', '₹${loan.principalAmount}',
                    Icons.currency_rupee),
                _buildDetailRow('Monthly Interest Rate',
                    '${loan.monthlyInterestRate}%', Icons.percent),
                _buildDetailRow('Address', loan.address, Icons.location_on),
                _buildDetailRow('Phone Number', loan.phoneNumber, Icons.phone),
                _buildDetailRow(
                    'EMI Repayment Date',
                    DateFormat('dd-MM-yyyy').format(loan.emiRepaymentDate!),
                    Icons.calendar_today),
                _buildDetailRow('Balance', '₹${loan.balance}',
                    Icons.currency_rupee),
                SizedBox(height: screenSize.height * 0.016),
                Text('Documents:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize.height * 0.020)),
                _buildDocumentList(loan.documents),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.004),
      child: Row(
        children: [
          Icon(icon, size: screenSize.height * 0.024, color: Colors.blueGrey),
          // Add icon
          SizedBox(width: screenSize.width * 0.008),
          Text('$label:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenSize.height * 0.020)),
          SizedBox(width: screenSize.width * 0.008),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: screenSize.height * 0.020))),
        ],
      ),
    );
  }

  Widget _buildDocumentList(String documents) {
    final documentPaths = documents.split(',');
    return Column(
      children: documentPaths.map((path) {
        final fileName = path.split('/').last;
        return ListTile(
          leading: Icon(Icons.insert_drive_file),
          title: Text(fileName),
          onTap: () {
            if (fileName.isNotEmpty) _openFile(path);
          },
        );
      }).toList(),
    );
  }

  void _openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print('Error opening file: ${result.message}');
    }
  }

  void _showUpdateLoanScreen(BuildContext context, Loan loan) async {
    final updatedLoan = await showDialog(
      context: context,
      builder: (context) {
        return AddLoanPopup(loan: loan);
      },
    );
    if (updatedLoan != null) {
      // Insert update history
      // Update the loan list in the ValueNotifier
      await dbHelper.insertLoanUpdateHistory({
        'loan_id': loan.id,
        'updated_at': DateTime.now().toIso8601String(),
        'old_borrower_name': loan.borrowerName,
        'new_borrower_name': updatedLoan.borrowerName,
        'old_principal_amount': loan.principalAmount,
        'new_principal_amount': updatedLoan.principalAmount,
        'old_emi_date':loan.emiRepaymentDate!.toIso8601String(),
        'new_emi_date':updatedLoan.emiRepaymentDate.toIso8601String(),
        'old_interest_rate':loan.monthlyInterestRate,
        'new_interest_rate':updatedLoan.monthlyInterestRate
        // Add other fields as needed
      });
      _fetchLoansNew('');
      /*final loans = Utils.loanListNotifier.value;
      final index = loans.indexWhere((l) => l.id == updatedLoan.id);
      if (index != -1) {
        loans[index] = updatedLoan;
        Utils.loanListNotifier.value = [...loans];
      }*/
    }
  }

  void _showRecordPaymentScreen(BuildContext context, Loan loan) async {
    Repayment repayment = await showDialog(
      context: context,
      builder: (context) {
        return RecordPaymentScreen(loanId: loan.id!);
      },
    );
    if (repayment != null) {
      // Insert the repayment record into the databas

      // Update the UI or state if needed
      final loans = Utils.loanListNotifier.value;
      final index = loans.indexWhere((l) => l.id == repayment.loanId);
      if (index != -1) {
        Loan? updatedLoan = await dbHelper.getLoanRecord(repayment.loanId);
        loans[index] = updatedLoan!;
        Utils.loanListNotifier.value = [...loans];
      }
      //}
    }
  }

  void _showRepaymentRecordsScreen(BuildContext context, int loanId) async {
    final screenSize = MediaQuery.of(context).size;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.200,
              vertical: screenSize.height * 0.200),
          child: Dialog(
            elevation: 5.0,
            child: RepaymentRecordsScreen(loanId: loanId),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Loan loan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this loan record?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteLoanRecord(loan); // Call delete function
                Navigator.of(context).pop();
                Utils.showToast(context, 'Record Deleted Successfully');// Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateHistoryDialog(BuildContext context, int loanId) async {
    final history = await dbHelper.getLoanUpdateHistory(loanId);
    final screenSize=MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Loan Update History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          content: history.isEmpty
              ? Text('No update history found.',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              : SizedBox(
            height: screenSize.height*0.300,
                width: screenSize.width*0.300,
                child: ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                final entry = history[index];
                return Card( // Wrap with Card for elevation
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: screenSize.height*0.004), // Add spacing
                  child: ListTile(
                    leading: Icon(Icons.history, color: Colors.grey), // Add icon
                    title: Text(
                      'Updated at: ${entry['updated_at']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0), // Add padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display changes for each field
                          if (entry['old_borrower_name'] != entry['new_borrower_name'])
                            Text(
                              'Borrower Name: ${entry['old_borrower_name']} -> ${entry['new_borrower_name']}',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                            ),
                          if (entry['old_principal_amount'] != entry['new_principal_amount'])
                            Text(
                              'Principal Amount: ${entry['old_principal_amount']} -> ${entry['new_principal_amount']}',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                            ),
                          if (entry['old_interest_rate'] != entry['new_interest_rate'])
                            Text(
                              'Interest Rate: ${entry['old_interest_rate']} -> ${entry['new_interest_rate']}',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                            ),
                          if (entry['old_emi_date'] != entry['new_emi_date'])
                            Text(
                              'EMI Date: ${entry['old_emi_date']} -> ${entry['new_emi_date']}',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                            ),
                          // Add more fields as needed
                        ],
                      ),
                    ),
                  ),
                );
                            },
                          ),
              ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLoanRecord(Loan loan) async {
    await dbHelper.deleteLoan(loan.id!);
    await dbHelper.deleteRepayment(loan.id!); // Delete from database
    // Update UI
    _fetchLoansNew('');
    // Assuming you have this function in your widget
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<List<Loan>>(
      valueListenable: Utils.loanListNotifier,
      builder: (context, loans, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: height*0.016,
                        fontWeight: FontWeight.w500),
                    onChanged: (query) {
                      _fetchLoansNew(query); // Filter loans as the user types
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or date...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                        borderSide:
                            BorderSide(color: Colors.grey), // Border color
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      // Background color
                      prefixIcon: Icon(Icons.search),
                      // Search icon
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: width*0.016, vertical: height*0.012), // Padding
                    ),
                  )
                : Text(
                    'All Loan Records',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        //fontStyle: FontStyle.italic,
                        fontSize: height * 0.028,
                        color: Colors.white,
                        letterSpacing: 3.5),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _fetchLoansNew(''); // Reset to show all loans
                    }
                  });
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to the add loan record screen
              showDialog(
                context: context,
                builder: (context) {
                  return AddLoanPopup();
                },
              );
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black, // Match the app bar color
          ),
          body:loans.isEmpty
              ? Center(
            child: Text(
              'No Records Found',
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w700,color: Colors.white),
            ),
          )
              :  ListView.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return Card(
                margin: EdgeInsets.symmetric(
                    vertical: height * 0.010, horizontal: width * 0.020),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: width * 0.016,
                            vertical: height * 0.012),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          '${Strings.toCamelCase(loan.borrowerName)}(${loan.id})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black87, // Darker title color
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ID: ${loan.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, // Semi-bold ID
                                    fontSize: 16.0,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Repayment Date: ${DateFormat('dd-MM-yyyy').format(loan.emiRepaymentDate!)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, // Semi-bold ID
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Principal: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(loan.principalAmount)}',
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    // Slightly larger principal amount
                                    fontWeight: FontWeight
                                        .w600, // Semi-bold principal amount
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Interest Rate: ${loan.monthlyInterestRate}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, // Semi-bold ID
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Phone: ${loan.phoneNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, // Semi-bold ID
                                    fontSize: 16.0,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'Balance:  ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(loan.balance ?? (loan.principalAmount/100)*loan.monthlyInterestRate)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, // Semi-bold ID
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          _showLoanDetails(loan);
                        },
                      ),
              );
              // Divider(),
            },
          ),
        );
      },
    );
  }
}
