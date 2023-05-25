class TransactionHistory {
  String orderId;
  DateTime date;
  double amount;
  int coins;
  String referral;
  String transactionRefId;
  String title;
  bool credit;
  bool debit;
  String paymentId;

  toJson() {
    return {
      "orderId": orderId,
      "date": date.toIso8601String(),
      "amount": amount,
      "coins": coins,
      "referral": referral,
      "transactionRefId": transactionRefId,
      "title": title,
      "credit": credit,
      "debit": debit,
      "paymentId": paymentId
    };
  }
}
