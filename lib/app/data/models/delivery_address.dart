class DeliveryAddress {
  final String addressLine;
  final double latitude;
  final double longitude;
  final String? city;
  final String? postalCode;

  const DeliveryAddress({
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    this.city,
    this.postalCode,
  });

  Map<String, dynamic> toJson() => {
        'addressLine': addressLine,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'postalCode': postalCode,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      addressLine: (json['addressLine'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
    );
  }
}
