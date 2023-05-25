import '../domain/promocode_model.dart';

class Promos {
  final List<PromoCodeModel> _promos = [];
  Map<String, List<PromoCodeModel>> promosMap = {};
  List<PromoCodeModel> get promos => [..._promos];
  String locationId;
  Promos(this.locationId, this._promos, this.promosMap);

  PromoCodeModel getPromo(String promoId) {
    return (_promos.firstWhere((item) => item.id == promoId,
        orElse: () => null));
  }

  PromoCodeModel getPromoMap(String promoId) {
    PromoCodeModel promoCodeItem;
    int flag = 0;

    promosMap.forEach((key, value) {
      if (flag == 0) {
        promoCodeItem = (value.firstWhere(
            (item) => item.minCartAmount.keys.toList()[0] == promoId,
            orElse: () => null));
        flag = 1;
      }
    });

    return promoCodeItem;
  }

  String getPromoName(String promoId) {
    String promoName;

    promosMap.forEach((key, promos) {
      for (var promo in promos) {
        if (promo.id == promoId) promoName = promo.name;
      }
    });
    return promoName;
  }
}
