class PromoCodeModel {
  String id;
  String name;
  Map<String, num> minCartAmount = {};
  num discountPercentage;
  num maxLiability;
  String type;
  int maxUsage;
  DateTime endDate;
  num coolDownHours;

  PromoCodeModel.fromMappedObject(this.id, Map<String, dynamic> item) {
    name = item['name'];
    discountPercentage = item['discountPercentage'];
    maxLiability = item['maxLiability'];
    type = item['type'];
    maxUsage = item['maxUsage'];
    coolDownHours = item['coolDownHours'] ?? 0;
    endDate = DateTime.parse(item['endDate']);
    if (item.containsKey('minCartAmount')) {
      var minCartAmountData = item['minCartAmount'] as Map<String, dynamic>;
      minCartAmountData.forEach((serviceId, amount) =>
          minCartAmount.putIfAbsent(serviceId, () => amount));
    }
  }
}
