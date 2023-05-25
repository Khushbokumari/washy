
class AddressModel {
  String id;
  num lat;
  num lng;
  String title;
  String landmark;
  String addressText;
  String contactNumber;
  String contactName;

  AddressModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    required this.landmark,
    required this.addressText,
    required this.contactName,
    required this.contactNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'title': title,
      'landmark': landmark,
      'addressText': addressText,
      'contactNumber': contactNumber,
      'contactName': contactName,
    };
  }

  AddressModel.fromMappedObjectWithoutId(Map<String, dynamic> item) {
    lat = item['lat'];
    lng = item['lng'];
    title = item['title'];
    landmark = item['landmark'];
    addressText = item['addressText'];
    contactNumber = item['contactNumber'];
    contactName = item['contactName'];
  }

  AddressModel.fromMappedObject(this.id, Map<String, dynamic> item) {
    lat = item['lat'];
    lng = item['lng'];
    title = item['title'];
    landmark = item['landmark'];
    addressText = item['addressText'];
    contactNumber = item['contactNumber'];
    contactName = item['contactName'];
  }
  String get formattedAddress => "$addressText $landmark";
}
