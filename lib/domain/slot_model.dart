class SlotsModel {
  String slotId;
  String from;
  String to;
  int availableSlots;
  int maxSlots;

  SlotsModel(
      {this.slotId, this.from, this.to, this.availableSlots, this.maxSlots});

  SlotsModel.fromMappedObject(String id, Map<String, dynamic> item) {
    slotId = id;
    from = item['from'];
    to = item['to'];
    availableSlots = item['availableSlots'];
    maxSlots = item['maxSlots'];
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }

  String _toReadableTime(String time) {
    final hour = time.substring(0, 2);
    if (hour == "00" || hour == "24") {
      return "12${time.substring(2, 5)} AM";
    } else if (hour == "12") {
      return "${time}PM";
    } else if (hour.compareTo("12") < 0) {
      return "$time AM";
    } else {
      return "${int.parse(hour) - 12}${time.substring(2, 5)} PM";
    }
  }

  String get formattedTime =>
      "${_toReadableTime(from)} - ${_toReadableTime(to)}";
}
