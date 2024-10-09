import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/jetons_service.dart';
import 'package:flutter_app/services/payment_service.dart';
import 'package:flutter_app/services/stand_service.dart' ;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;


import 'package:provider/provider.dart';

import '../../models/stand_model.dart';
import '../../models/stock_model.dart';
import '../../services/auth_service.dart';


class StandDetailScreen extends StatefulWidget {
  final Stand initialStand;


  StandDetailScreen({required this.initialStand, required Stand stand});

  @override
  _StandDetailScreenState createState() => _StandDetailScreenState();
}

class _StandDetailScreenState extends State<StandDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Stand stand;
  bool _isLoading = false;
  late Future<void> _initFuture;
  final StandService _standService = StandService();
  final JetonsService _paymentWithJetons = JetonsService();
  final PaymentService _paymentWithCard = PaymentService();
  Map<int, int> selectedQuantities = {}; // stockId -> quantity
  int? userId;

  @override
  void initState() {
    super.initState();
    stand = widget.initialStand;
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.fetchUserDetails();

    setState(() {
      userId = authService.userId;
    });

    if (userId != null) {
      // L'userId est prêt à être utilisé ici
      print('User ID: $userId');
    } else {
      print('Error: User ID is null after fetching user details');
    }
    // Charger les stocks
    try {
      final updatedStand = await _standService.getStand(stand.id);
      setState(() {
        stand = updatedStand;
        for (var stock in stand.stocks ?? []) {
          selectedQuantities[stock.id] = 0;
        }
      });
    } catch (e) {
      print('Erreur lors du chargement des détails du stand: $e');
    }

    print('Initialisation terminée. User ID: $userId, Stocks: ${stand.stocks}');
  }

  void _showSnackBar(String message) {
    print('Attempting to show SnackBar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 10), // Augmentez la durée si nécessaire
      ),
    );
    print('SnackBar displayed');
  }

  Future<void> _buyTokens(int tokenAmount, double priceInEuros) async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final amountInCents = (priceInEuros * 100).toInt();

      print('Début de la transaction');
      print('UserId: $userId');
      print('Montant en cents: $amountInCents');
      // Créer l'intention de paiement
      final paymentIntentResult = await _paymentWithCard.buyJetons(
        userId: userId,
        amount: amountInCents,
        tokenAmount: tokenAmount,
      );
      print('Résultat de buyJetons: $paymentIntentResult');

      // Vérifier que nous avons reçu le client_secret
      if (paymentIntentResult['client_secret'] == null) {
        throw Exception('Pas de client_secret reçu du serveur');
      }

      // Configurer la feuille de paiement
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentResult['client_secret'],
          merchantDisplayName: 'Votre nom de marchand',
        ),
      );

      // Afficher la feuille de paiement
      await stripe.Stripe.instance.presentPaymentSheet();

      // Si nous arrivons ici, le paiement a réussi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            'Paiement réussi! $tokenAmount jetons achetés pour $priceInEuros€')),
      );

      // Mettre à jour le solde de l'utilisateur
      await authService.refreshUserInfo();
    } catch (e, stackTrace) {
      print('Erreur lors du paiement: $e');
      print('Stack trace: $stackTrace');
    if (e is stripe.StripeException) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur Stripe: ${e.error.localizedMessage}')),
    );
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur inattendue: $e')),
    );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buyProduct(Stock stock) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final quantity = selectedQuantities[stock.id] ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une quantité')),
      );
      return;
    }
      await _buyWithJetons(stock, quantity);
    await authService.refreshUserInfo();

  }

  Future<void> _buyWithJetons(Stock stock, int quantity) async {
    try {
      final result = await _paymentWithJetons.payWithJetons(
        userId: userId!,
        standId: stand.id!,
        quantity: quantity,
      );

      final updatedStand = await _standService.getStand(stand.id);
      setState(() {
        stand = updatedStand;
        selectedQuantities[stock.id!] = 0;
      });

      _showSnackBar('Achat réussi! Nouveau solde: ${result['newBalance']} jetons');
    } catch (e) {
      _showSnackBar('Erreur lors de l\'achat avec jetons: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(stand.typeString),
        backgroundColor: Colors.blue,
      ),
      body: Builder(
          builder: (BuildContext context) {
            return FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildContent();

          }
          return Center(
              child: Text('État inattendu: ${snapshot.connectionState}'));

        },
            );
          },

      ),

    );
  }

  Widget _buildContent() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (stand.stocks == null || stand.stocks!.isEmpty) {
      return Center(child: Text('Aucun produit disponible pour ce stand.'));
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[100]!, Colors.blue[300]!],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stand.stocks != null && stand.stocks!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Produits disponibles:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ...stand.stocks!.map((stock) => _buildStockItem(stock)).toList(),
                      ],
                    ),
                  ),
                ),

              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child:   // Section pour acheter des jetons
               Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acheter des Jetons',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('Solde actuel: ${authService.user?.soldeJetons ?? 0} jetons'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        child: Text('Acheter 10 jetons pour 5€'),
                        onPressed: _isLoading ? null : () => _buyTokens(10, 5.0),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        child: Text('Acheter 20 jetons pour 9€'),
                        onPressed: _isLoading ? null : () => _buyTokens(20, 9.0),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        child: Text('Acheter 50 jetons pour 20€'),
                        onPressed: _isLoading ? null : () => _buyTokens(50, 20.0),
                      ),
                    ],
                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(Stock stock) {
  //  print("Stand stocks: ${stand.stocks}");
  //  print("Building stocks item for: ${stocks.nomProduit}");
    String buttonText = stand.type == StandType.ACTIVITES ? 'Acheter avec Jetons' : 'Acheter';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('${stock.nomProduit} - ${stock.prixJetons} jetons'),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text('Quantité disponible: ${stock.quantity}'),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (selectedQuantities[stock.id]! > 0) {
                      selectedQuantities[stock.id ?? 0] =
                          selectedQuantities[stock.id]! - 1;
                    }
                  });
                },
              ),
              Text('${selectedQuantities[stock.id]}'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (selectedQuantities[stock.id]! < stock.quantity!) {
                      selectedQuantities[stock.id ?? 0] =
                          selectedQuantities[stock.id]! + 1;
                    }
                  });
                },
              ),
              ElevatedButton(
                child: Text('Acheter'),
                onPressed: () => _buyProduct(stock),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
