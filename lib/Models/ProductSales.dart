class ProductSales {
   String productName;
   String ProductAmount;
    String ProductSellerId;
   


  ProductSales({
    required this.productName,
    required this.ProductAmount,
    required this.ProductSellerId,
  

  });

 Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'ProductAmount': ProductAmount,
      'productSeller': ProductSellerId,
      
   
    };

}

  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      productName: json['productName'] as String,
      ProductAmount: json['ProductAmount'] as String,
        ProductSellerId: json['productSeller'] as String,
    
    );
  }
}