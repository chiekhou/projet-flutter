class User {
  final int id;
  final String? name;
  final String? email;
  final String? role;
  final int? soldeJetons;
  String? _password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.soldeJetons,
    String? password,
  }) {
    if (password != null) {
      _password = password;
    }
  }

  // Getter pour vérifier si un mot de passe est défini
  bool get hasPassword => _password != null && _password!.isNotEmpty;

  // Méthode pour définir le mot de passe
  void setPassword(String password) {
    _password = password;
  }

  // Méthode pour effacer le mot de passe
  void clearPassword() {
    _password = null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : null,
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      role: json['roles']?.toString(),
      soldeJetons: json['solde_jetons'] is int ? json['solde_jetons'] : null,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'roles': role,
      'solde_jetons': soldeJetons,
    };
  }

  // Méthode pour créer une copie de l'utilisateur avec un nouveau mot de passe
  User copyWithPassword(String newPassword) {
    return User(
      id: this.id,
      name: this.name,
      email: this.email,
      role: this.role,
      soldeJetons: this.soldeJetons,
      password: newPassword,
    );
  }
}