class TransactionSummary {
  final int totalAchats;
  final int totalUtilisations;
  final int totalTransferts;

  TransactionSummary({
    required this.totalAchats,
    required this.totalUtilisations,
    required this.totalTransferts,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalAchats: json['TotalAchats'],
      totalUtilisations: json['TotalUtilisations'],
      totalTransferts: json['TotalTransferts'],
    );
  }
}