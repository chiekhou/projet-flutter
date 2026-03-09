# KerFest 🎪

Application mobile de gestion de kermesse scolaire, développée dans le cadre d'un projet d'école.
Elle permet d'organiser et de vivre une kermesse de A à Z : gestion des stands, tombola, jetons, classement des élèves et communication en temps réel.

> 🎥 **[Voir la démo](https://drive.google.com/file/d/1zQr-wsSTK5zvm1jUtuYiy3kMMjJuiL6u/view?usp=sharing)** 

---

## Présentation

KerFest est une application full-stack qui connecte tous les acteurs d'une kermesse scolaire sur une seule plateforme :

- Les **parents** achètent des jetons, les distribuent à leurs enfants et suivent leurs activités
- Les **élèves** dépensent leurs jetons dans les stands, participent aux tombolas et consultent leurs gains
- Les **organisateurs** pilotent les kermesses, gèrent les tombolas, consultent les transactions et le classement
- Les **teneurs de stand** gèrent leurs stocks et encaissent les jetons en temps réel

---

## Fonctionnalités

### 👨‍👧 Parent
- Achat de jetons via paiement en ligne (Stripe)
- Distribution de jetons à ses enfants
- Consultation du solde de chaque enfant
- Inscription et gestion des comptes enfants
- Historique des interactions des enfants

### 🎒 Élève
- Visualisation de son solde de jetons
- Dépense de jetons dans les stands (nourriture, boissons, activités)
- Achat de tickets de tombola
- Consultation de ses tickets et de ses gains

### 🎯 Organisateur
- Création et gestion des kermesses
- Gestion des tombolas : lots, tirage au sort définitif et unique, liste des gagnants
- Vue sur tous les stands : stocks, jetons collectés, points attribués
- Tableau des transactions global
- Classement des élèves par points accumulés

### 🏪 Teneur de stand
- Gestion des stocks en temps réel
- Encaissement en jetons
- Attribution de points aux élèves (stands activité)
- Chat en temps réel avec les autres teneurs et l'organisateur

---

## Architecture

```
projet-flutter/
├── flutter_app/          # Application mobile Flutter (iOS & Android)
│   └── lib/
│       ├── models/       # Modèles de données
│       ├── services/     # Appels API REST
│       ├── screen/       # Écrans par rôle
│       ├── widgets/      # Composants réutilisables
│       └── theme/        # Design system (couleurs, gradients, cartes)
│
└── internal/             # Backend Go
    ├── apis/
    │   └── controller/   # Contrôleurs REST par domaine
    ├── models/           # Modèles GORM
    └── initializers/     # Configuration DB & env
```

---

## Stack technique

### Frontend — Flutter
| Technologie | Usage |
|---|---|
| Flutter 3 / Dart | Framework mobile cross-platform |
| Provider | Gestion d'état |
| flutter_stripe | Paiements en ligne |
| flutter_secure_storage | Stockage sécurisé du token JWT |
| shared_preferences | Persistance locale (auto-login) |
| web_socket_channel | Chat en temps réel |
| http | Appels API REST |

### Backend — Go
| Technologie | Usage |
|---|---|
| Go 1.22 | Langage backend |
| Gin | Framework HTTP REST |
| GORM | ORM base de données |
| PostgreSQL | Base de données |
| JWT | Authentification |
| Stripe | Paiements |
| Gorilla WebSocket | Chat temps réel |
| Swagger | Documentation API |

---

## Rôles utilisateurs

| Rôle | Description |
|---|---|
| `PARENT` | Achète et distribue des jetons à ses enfants |
| `ELEVE` | Participe à la kermesse avec les jetons reçus |
| `ORGANISATEUR` | Administre la kermesse et les tombolas |
| `TENEUR_STAND` | Gère un stand et encaisse les jetons |
| `ADMIN` | Accès complet à la plateforme |

---

## Modèle de données principal

- **User** — compte commun à tous les rôles (solde jetons, rôle)
- **Parent** — lié à un User, possède des Élèves
- **Eleve** — lié à un User et un Parent (points accumulés)
- **Kermesse** — événement racine
- **Stand** — stand d'une kermesse (type : nourriture / boisson / activité)
- **Stock** — produits d'un stand avec prix en jetons et quantité
- **Tombola** — tombola d'une kermesse avec des Lots et des Tickets
- **Ticket** — acheté par un utilisateur pour participer à une tombola
- **Gagnant** — résultat du tirage au sort (1 gagnant par lot, tirage définitif)
- **JetonTransaction** — historique de toutes les transactions de jetons

---

## Auteur

TRAORE Chiekhou

Projet réalisé dans le cadre d'une formation en développement d'applications.
