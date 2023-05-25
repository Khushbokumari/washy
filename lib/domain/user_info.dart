class UserInf {
  String name;
  String email;
  int wallet;
  String phoneNumber;
  toJson() {
    return {
      "name": name,
      "email": email,
      "wallet": wallet,
      "phoneNumber": phoneNumber
    };
  }
}
