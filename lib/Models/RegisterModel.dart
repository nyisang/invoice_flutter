class RegisterModel {
   String firstname;
   String lastname;
    String phonenumber;
   String Password;


  RegisterModel({
    required this.firstname,
    required this.lastname,
    required this.phonenumber,
    required this.Password,

  });

 Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'phonenumber': phonenumber,
      'Password': Password,
   
    };

}

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
        phonenumber: json['phonenumber'] as String,
      Password: json['Password'] as String,
    );
  }
}