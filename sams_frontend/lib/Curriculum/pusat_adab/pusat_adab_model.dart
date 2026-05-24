class PusatAdabModule {
  final String title;
  final String imagePath;

  const PusatAdabModule({
    required this.title,
    required this.imagePath,
  });
}

class CreditClaimSummary {
  final String studentName;
  final String moduleName;
  final String status;
  final int percentage;

  const CreditClaimSummary({
    required this.studentName,
    required this.moduleName,
    required this.status,
    required this.percentage,
  });
}
