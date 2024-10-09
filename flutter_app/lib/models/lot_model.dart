class Lot {
  final int? id;
  final String nom;
  final String description;
  final double valeur;
  final int? tombolaId;

  Lot({
    this.id,
    required this.nom,
    required this.description,
    required this.valeur,
    this.tombolaId,
  });

  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nom: json['Nom']?? '',
      description: json['Description'] ?? '',
      tombolaId: json['TombolaID'] is int ? json['TombolaID'] : int.parse(json['TombolaID'].toString()),
        valeur: json['Valeur'] is double ? json['Valeur'] : double.parse(json['Valeur'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'Valeur': valeur,
      'TombolaID': tombolaId,
    };
  }
}