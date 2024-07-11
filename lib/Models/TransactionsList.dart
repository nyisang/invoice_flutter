class TransactionsList {
  final String phonepaying;
  final String amounttopay;

  TransactionsList({
    required this.phonepaying,
    required this.amounttopay,
  });

  factory TransactionsList.fromJson(Map<String, dynamic> json) {
    return TransactionsList(
  
        phonepaying: json['type'] as String,
      amounttopay: json['messageout'] as String,
 
    );
  }
}