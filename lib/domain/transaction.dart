class MoneyTransaction {
  double walletMoney;
  double walletCoins;

  toJson() {
    return {
      "walletMoney": walletMoney,
      "walletCoins": walletCoins,
    };
  }
}
