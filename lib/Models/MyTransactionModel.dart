class MyTransactionModel {
  final String Phonember;
  final String AmountPay;
  final int invoiceid;

  MyTransactionModel({
    required this.Phonember,
    required this.AmountPay,
     required this.invoiceid,
  });
 Map<String, dynamic> toJson() {
    return {
      'phonenumber': Phonember,
      'amount': AmountPay,
      'invoiceid': invoiceid,
   
    };

}
  factory MyTransactionModel.fromJson(Map<String, dynamic> json) {
    return MyTransactionModel(
  
        Phonember: json['phonenumber'] as String,
      AmountPay: json['amount'] as String,
    invoiceid: json['invoiceid'] as int,
    );
  }
}