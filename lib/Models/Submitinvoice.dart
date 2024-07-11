class Submitinvoice {
   String invoiceName;
   double grandTotal2;
  


  Submitinvoice({
    required this.invoiceName,
    required this.grandTotal2,
   

  });

 Map<String, dynamic> toJson() {
    return {
      'InvoiceName': invoiceName,
      'InvoiceAmount': grandTotal2,
     
   
    };

}

  factory Submitinvoice.fromJson(Map<String, dynamic> json) {
    return Submitinvoice(
      invoiceName: json['InvoiceName'] as String,
      grandTotal2: json['InvoiceAmount'] as double,
     
    );
  }
}