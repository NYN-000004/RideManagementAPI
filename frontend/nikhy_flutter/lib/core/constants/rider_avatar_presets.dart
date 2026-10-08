class RiderAvatarPreset {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;

  const RiderAvatarPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class RiderAvatarPresets {
  static const List<RiderAvatarPreset> presets = [
    RiderAvatarPreset(
      id: 'rider_1',
      title: 'Captain Rajesh',
      subtitle: 'City Pro • Royal Enfield',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop&q=80',
    ),
    RiderAvatarPreset(
      id: 'rider_2',
      title: 'Captain Vikram',
      subtitle: 'Top Rated • Honda Activa',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop&q=80',
    ),
    RiderAvatarPreset(
      id: 'rider_3',
      title: 'Captain Priya',
      subtitle: 'Eco Cruiser • Ather 450X',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80',
    ),
    RiderAvatarPreset(
      id: 'rider_4',
      title: 'Captain Arjun',
      subtitle: 'Express Navigator • Yamaha FZ',
      imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=300&auto=format&fit=crop&q=80',
    ),
    RiderAvatarPreset(
      id: 'rider_5',
      title: 'Captain Rohit',
      subtitle: '5.0 ★ Master • TVS Apache',
      imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=300&auto=format&fit=crop&q=80',
    ),
    RiderAvatarPreset(
      id: 'rider_6',
      title: 'Captain Ananya',
      subtitle: 'Swift Transit • Ola S1 Pro',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&auto=format&fit=crop&q=80',
    ),
  ];

  /// Provides a default high-res captain avatar deterministically by driverId
  static String getDefaultAvatarForDriver(int? driverId) {
    if (driverId == null || driverId <= 0) {
      return presets[0].imageUrl;
    }
    final index = (driverId % presets.length).abs();
    return presets[index].imageUrl;
  }
}
