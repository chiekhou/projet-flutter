class Stock {
  final int? id;
  final String nomProduit;
  final int quantity;
  final int prixJetons;
  final int? standId;

  Stock({
    this.id,
    required this.nomProduit,
    required this.quantity,
    required this.prixJetons,
    this.standId,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    print('Parsing Stock: $json');
    return Stock(
      id: json['id'],
      nomProduit: json['NomProduit'],
      quantity: json['Quantite'],
      prixJetons: json['PrixEnJetons'],
      standId: json['StandID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NomProduit': nomProduit,
      'Quantite': quantity,
      'PrixEnJetons': prixJetons,
      'StandID': standId,
    };
  }
}