class Point {
  int? id;
  String? placeHeader;
  String? placeDetails;
  String? placeId;
  double? latitude;
  double? longitude;

  Point(
  {
    this.id,
    this.placeHeader,
    this.placeDetails,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  Point.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    placeHeader = json['place_name'].toString();
    placeDetails = json['place_details'].toString();
    placeId = json['place_id'].toString();
    latitude = double.parse(json['latitude'].toString());
    longitude = double.parse(json['longitude'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['place_name'] = placeHeader;
    data['place_details'] = placeDetails;
    data['place_id'] = placeId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}