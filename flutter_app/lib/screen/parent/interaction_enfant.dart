import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/models/eleve_model.dart';
import 'package:flutter_app/models/jetons_transactions_model.dart';
import 'package:flutter_app/services/parent_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_drawer.dart';


class ViewChildrenInteractionsScreen extends StatefulWidget {
  @override
  _ViewChildrenInteractionsScreenState createState() => _ViewChildrenInteractionsScreenState();
}

class _ViewChildrenInteractionsScreenState extends State<ViewChildrenInteractionsScreen> {
  final ParentService _childService = ParentService();
  late Future<List<EleveModel>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _childrenFuture = _loadChildrenData(authService);
  }


  Future<List<EleveModel>> _loadChildrenData(AuthService authService) async {
    if (authService.parent == null) {
      // Si le parent n'est pas encore chargé, attendez qu'il le soit
      await authService.fetchParentInfo();
    }

    if (authService.parent != null && authService.parent!.id != null) {
      return _childService.getChildrenForParent(authService.parent!.id!);
    } else {
      throw Exception('Impossible de charger les informations du parent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactions des Enfants'),
        backgroundColor: Colors.orange,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[100]!, Colors.orange[300]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Suivi des achats',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<EleveModel>>(
                  future: _childrenFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(child: Text(
                        'Erreur: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(
                        'Aucun enfant trouvé',
                        style: TextStyle(color: Colors.white),
                      ));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (ctx, index) {
                          final child = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ChildInteractionTile(child: child),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildInteractionTile extends StatelessWidget {
  final EleveModel child;
  final ParentService _childService = ParentService();

  ChildInteractionTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          child.user?.name ?? 'Enfant sans nom',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Points accumulés: ${child.pointsAccumules ?? 0}'),
        children: [
          FutureBuilder<List<JetonsTransactionModel>>(
            future: child.id != null
                ? _childService.getChildInteractions(child.id!)
                : Future.value([]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Erreur de chargement des transactions: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Aucune transaction trouvée'),
                );
              } else {
                return Column(
                  children: snapshot.data!.map((transaction) {
                    return ListTile(
                      title: Text(transaction.description ?? ''),
                      subtitle: Text('${transaction.montant ?? 0} jetons - ${transaction.type ?? ''}'),
                      trailing: Text(
                        transaction.date != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(transaction.date!)
                            : 'Date inconnue',
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}