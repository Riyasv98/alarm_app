class WeatherModel {
  String? name;
  String? country;
  String? region;
  String? lat;
  String? lon;
  String? timezoneId;
  String? localtime;
  int? localtimeEpoch;
  String? utcOffset;

  WeatherModel({
    this.name,
    this.country,
    this.region,
    this.lat,
    this.lon,
    this.timezoneId,
    this.localtime,
    this.localtimeEpoch,
    this.utcOffset,
  });
  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
    name: json["name"],
    country: json["country"],
    region: json["region"],
    lat: json["lat"],
    lon: json["lon"],
    timezoneId: json["timezoneId"],
    localtime: json["localtime"],
    localtimeEpoch: json["localtimeEpoch"],
    utcOffset: json["utcOffset"],

  );

  // Map<String, dynamic> toJson() => {
  //   "id": id,
  // };
}
