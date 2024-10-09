extension StandTypeExtension on dynamic {
  String toStandTypeString() {
    if (this is int) {
      switch (this as int) {
        case 0:
          return 'NOURRITURE';
        case 1:
          return 'BOISSON';
        case 2:
          return 'ACTIVITE';
        default:
          return 'INCONNU';
      }
    } else if (this is String) {
      return this as String;
    }
    return 'INCONNU';
  }
}