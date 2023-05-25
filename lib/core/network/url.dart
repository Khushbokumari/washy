class URL {
  static const String API_KEY = 'AIzaSyCJ6-55FWelmuYjo87y5c8IRt2wrEER-7I';
  static const String SIGN_UP_URL =
      "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY";
  static const String EMAIL_VERIFY_URL =
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$API_KEY';
  static const String USER_DATA_URL =
      'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$API_KEY';
  static const String PASSWORD_RESET_URL =
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$API_KEY';
  static const String LOGIN_URL =
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$API_KEY";
  static const String BASE_DATABASE_URL =
      "https://cleanforsure-cbcd0-default-rtdb.firebaseio.com";
  static const String CATEGORY_DATABASE_URL = "$BASE_DATABASE_URL/categories";
  static const String LOCATION_DATABASE_URL = "$BASE_DATABASE_URL/location";
  static const String ADDRESSES_DATABASE_URL = "$BASE_DATABASE_URL/addresses";
  static const String ORDERS_DATABASE_URL = "$BASE_DATABASE_URL/orders";
  static const String USER_INFO_URL = "$BASE_DATABASE_URL/userInfo";
  static const String REFERRAL_URL = "$BASE_DATABASE_URL/referral";
  static const String TRANSACTION_URL = "$BASE_DATABASE_URL/transaction";
  static const String OFFERS_URL = "$BASE_DATABASE_URL/offers";
  static const String APPDATAURL = "$BASE_DATABASE_URL/appData";
}
