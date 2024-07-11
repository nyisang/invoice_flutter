class LoginModel {
   String Username;
   String Password;


  LoginModel({
    required this.Username,
    required this.Password,

  });

 Map<String, dynamic> toJson() {
    return {
      'Username': Username,
      'Password': Password,
   
    };

}

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      Username: json['Username'] as String,
      Password: json['Password'] as String,
    
    );
  }
}