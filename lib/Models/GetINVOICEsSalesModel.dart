class GetINVOICEsSalesModel {
  final String productsale;
  final int amountsale;

  GetINVOICEsSalesModel({
    required this.productsale,
    required this.amountsale,
  });

  factory GetINVOICEsSalesModel.fromJson(Map<String, dynamic> json) {
    return GetINVOICEsSalesModel(
  
        productsale: json['product'] as String,
      amountsale: json['Amount'] as int,
 
    );
  }
}