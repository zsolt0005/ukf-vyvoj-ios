// Dátový model odpovede z USGS Earthquake API (GeoJSON).

class EarthquakeModel {
  EarthquakeModel({this.type, this.metadata, this.features, this.bbox});

  final String? type;
  final Metadata? metadata;
  final List<Feature>? features;
  final List<double>? bbox;

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) => EarthquakeModel(
        type: json['type'] as String?,
        metadata: json['metadata'] == null
            ? null
            : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
        features: (json['features'] as List?)
            ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
            .toList(),
        bbox: (json['bbox'] as List?)?.map((e) => (e as num).toDouble()).toList(),
      );
}

class Metadata {
  Metadata({this.generated, this.url, this.title, this.status, this.api, this.count});

  final int? generated;
  final String? url;
  final String? title;
  final int? status;
  final String? api;
  final int? count;

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        generated: (json['generated'] as num?)?.toInt(),
        url: json['url'] as String?,
        title: json['title'] as String?,
        status: (json['status'] as num?)?.toInt(),
        api: json['api'] as String?,
        count: (json['count'] as num?)?.toInt(),
      );
}

class Feature {
  Feature({this.type, this.properties, this.geometry, this.id});

  final String? type;
  final Properties? properties;
  final Geometry? geometry;
  final String? id;

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json['type'] as String?,
        properties: json['properties'] == null
            ? null
            : Properties.fromJson(json['properties'] as Map<String, dynamic>),
        geometry: json['geometry'] == null
            ? null
            : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
        id: json['id'] as String?,
      );
}

class Properties {
  Properties({
    this.mag,
    this.place,
    this.time,
    this.updated,
    this.alert,
    this.title,
    this.url,
  });

  final double? mag;
  final String? place;
  final int? time;
  final int? updated;
  final String? alert;
  final String? title;
  final String? url;

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mag: (json['mag'] as num?)?.toDouble(),
        place: json['place'] as String?,
        time: (json['time'] as num?)?.toInt(),
        updated: (json['updated'] as num?)?.toInt(),
        alert: json['alert'] as String?,
        title: json['title'] as String?,
        url: json['url'] as String?,
      );
}

class Geometry {
  Geometry({this.type, this.coordinates});

  final String? type;
  final List<double>? coordinates;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json['type'] as String?,
        coordinates: (json['coordinates'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList(),
      );
}
