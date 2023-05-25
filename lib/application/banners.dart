class BannerProvider {
  final List<String> _banners = [];
  List<String> get banners => _banners.map((f) => f).toList();
  String locationId;

  BannerProvider(this.locationId, this._banners);
}