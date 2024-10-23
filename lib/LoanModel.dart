class Loan {
  int? id; // Make id nullable for insertion
  final String borrowerName;
  final double principalAmount;
  final double monthlyInterestRate;
  double? balance=0;
  final String address;
  final String phoneNumber;
  DateTime? emiRepaymentDate;
  final String documents;

  Loan({
    this.id, // Id can be null for new loans
    required this.borrowerName,
    required this.principalAmount,
    required this.monthlyInterestRate,
    required this.address,
    required this.phoneNumber,
    this.balance,
    this.emiRepaymentDate,
    required this.documents,
  });

  // Convert a Map (from database query) to a Loan object
  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as int,
      borrowerName: map['borrower_name'] as String,
      principalAmount: map['principal_amount'] ,
      monthlyInterestRate: map['monthly_interest_rate'],
      address: map['address'] as String,
      balance: map['balance'],
      phoneNumber: map['phone_number'] as String,
      emiRepaymentDate: DateTime.parse(map['emi_repayment_date'] as String),
      documents: map['documents'] as String,
    );
  }

  // Convert a Loan object to a Map (for database insertion/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'borrower_name': borrowerName,
      'principal_amount': principalAmount,
      'monthly_interest_rate': monthlyInterestRate,
      'address': address,
      'phone_number': phoneNumber,
      'balance':balance,
      'emi_repayment_date': emiRepaymentDate!.toIso8601String(),
      'documents': documents,
    };
  }
}