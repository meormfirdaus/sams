class ModuleModel {
  final int id;
  final String code;
  final String name;
  final String location;
  final String lecturer;
  final String category;
  final bool booked;
  final String? bookedClassDate;

  ModuleModel({
    required this.id,
    required this.code,
    required this.name,
    required this.location,
    required this.lecturer,
    required this.category,
    required this.booked,
    required this.bookedClassDate,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      lecturer: json['lecturer'] ?? '',
      category: json['category'] ?? '',
      booked: json['is_booked'] ?? false,
      bookedClassDate: json['booked_class_date'],
    );
  }
}