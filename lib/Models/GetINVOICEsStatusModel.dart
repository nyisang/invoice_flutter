class GetINVOICEsStatusModel {
    final int id;
  final String invoicename;
  final int invoiceamount;
    final String invoicestatus;

  GetINVOICEsStatusModel({
      required this.id,
    required this.invoicename,
    required this.invoiceamount,
     required this.invoicestatus,
  });

  factory GetINVOICEsStatusModel.fromJson(Map<String, dynamic> json) {
    return GetINVOICEsStatusModel(
  id: json['id'] as int,
        invoicename: json['invoice'] as String,
      invoiceamount: json['amount'] as int,
  invoicestatus: json['status'] as String,
    );
  }
}