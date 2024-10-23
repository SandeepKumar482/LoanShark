class Repayment {
  int? id;
  int loanId;
  DateTime paymentDate;
  double paymentAmount;
  String paymentMethod;
  String? notes;

  Repayment({
    this.id,
    required this.loanId,
    required this.paymentDate,
    required this.paymentAmount,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loan_id': loanId,
      'payment_date': paymentDate.toIso8601String(), // Store as ISO8601 string
      'payment_amount': paymentAmount,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }

  factory Repayment.fromMap(Map<String, dynamic> map) {
    return Repayment(
      id: map['id'],
      loanId: map['loan_id'],
      paymentDate: DateTime.parse(map['payment_date']), // Parse from ISO8601 string
      paymentAmount: map['payment_amount'],
      paymentMethod: map['payment_method'],
      notes: map['notes'],
    );
  }
}