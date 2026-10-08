class AppConstants {
  static const String appName = 'NIKHY';
  static const String appTagline = 'Smart Ride Lifecycle Management';

  // Popular Hyderabad Location Presets
  static const List<Map<String, dynamic>> locationPresets = [
    {
      'title': 'Hitec City ➔ RGIA Airport',
      'pickupLocation': 'Hitec City Cyber Towers, Hyderabad',
      'pickupLatitude': 17.4504,
      'pickupLongitude': 78.3808,
      'destinationLocation': 'Rajiv Gandhi International Airport (RGIA), Hyderabad',
      'destinationLatitude': 17.2403,
      'destinationLongitude': 78.4294,
      'fare': 750.0,
      'distance': 32.4,
      'estimatedDuration': 45,
    },
    {
      'title': 'Gachibowli ➔ Banjara Hills',
      'pickupLocation': 'DLF Cyber City, Gachibowli, Hyderabad',
      'pickupLatitude': 17.4435,
      'pickupLongitude': 78.3582,
      'destinationLocation': 'Road No. 12, Banjara Hills, Hyderabad',
      'destinationLatitude': 17.4156,
      'destinationLongitude': 78.4350,
      'fare': 280.0,
      'distance': 12.8,
      'estimatedDuration': 30,
    },
    {
      'title': 'Jubilee Hills ➔ Inorbit Mall Madhapur',
      'pickupLocation': 'Jubilee Hills Check Post, Hyderabad',
      'pickupLatitude': 17.4319,
      'pickupLongitude': 78.4073,
      'destinationLocation': 'Inorbit Mall, Mindspace, Madhapur, Hyderabad',
      'destinationLatitude': 17.4358,
      'destinationLongitude': 78.3828,
      'fare': 160.0,
      'distance': 5.5,
      'estimatedDuration': 18,
    },
    {
      'title': 'Secunderabad ➔ Charminar',
      'pickupLocation': 'Secunderabad Railway Station, Hyderabad',
      'pickupLatitude': 17.4344,
      'pickupLongitude': 78.5017,
      'destinationLocation': 'Charminar, Old City, Hyderabad',
      'destinationLatitude': 17.3616,
      'destinationLongitude': 78.4747,
      'fare': 220.0,
      'distance': 11.2,
      'estimatedDuration': 35,
    },
    {
      'title': 'Kondapur ➔ Financial District',
      'pickupLocation': 'Kondapur Main Road, Hyderabad',
      'pickupLatitude': 17.4687,
      'pickupLongitude': 78.3612,
      'destinationLocation': 'WaveRock, Financial District, Nanakramguda, Hyderabad',
      'destinationLatitude': 17.4162,
      'destinationLongitude': 78.3444,
      'fare': 190.0,
      'distance': 8.4,
      'estimatedDuration': 22,
    },
  ];
}
