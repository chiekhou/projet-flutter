class JetonsTransactionModel {
  final int? id;
  final int montant;
  final String description;
  final String type;
  final String? paiementId;
  final DateTime? date;
  final int userId;
  final int? standId;
  final dynamic stand;


  JetonsTransactionModel({
    this.id,
    this.stand,
    required this.montant,
    required this.description,
    required this.type,
    required this.date,
    required this.paiementId,
    required this.userId,
    this.standId,

  });

  factory JetonsTransactionModel.fromJson(Map<String, dynamic> json) {
    print('Parsing Jetons: $json');
    final jetonTransaction = JetonsTransactionModel(
        id: json['id'] as int?,
        montant: json['Montant'] as int,
        description: json['Description'] as String,
        type: json['Type'] as String,
        date: json['Date'] != null ? DateTime.parse(json['Date'] as String) : null,
        paiementId: json['PaiementID'] as String?,
        userId: json['UserID'] as int,
        standId: json['StandID'] as int?,
       stand: json['Stand'],
    );
    print('Parsed Jetons: $jetonTransaction');
    return jetonTransaction;
  }

  Map<String, dynamic> toJson() {
    return {
      'Montant': montant,
      'Description': description,
      'Type': type,
      'Date': date?.toIso8601String(),
      'PaiementID' : paiementId,
      'UserID' : userId,
      'StandID': standId,
      'Stand': stand
    };
  }
}