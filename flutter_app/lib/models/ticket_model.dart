class Ticket {
  final int? id;
  final String numero;
  final bool estGagnant;
  final int prixJetons;
  final int tombolaId;
  final int userId;

  Ticket({
    this.id,
    required this.numero,
    required this.estGagnant,
    required this.prixJetons,
    required this.tombolaId,
    required this.userId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    print('Parsing Ticket: $json');
    return Ticket(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      numero: json['Numero']?? '',
      estGagnant: json['EstGagnant']?? false,
      prixJetons: json['PrixEnJetons'] is int ? json['PrixEnJetons'] : int.parse(json['PrixEnJetons'].toString()),
      tombolaId: json['TombolaID'] is int ? json['TombolaID'] : int.parse(json['TombolaID'].toString()),
      userId: json['UserID'] is int ? json['UserID'] : int.parse(json['UserID'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'est_gagnant' : estGagnant,
      'prix_en_jetons': prixJetons,
      'TombalaID': tombolaId,
      'UserID': userId,
    };
  }
}