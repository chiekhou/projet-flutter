import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/eleve_model.dart';
import '../../services/auth_service.dart';
import '../../services/parent_service.dart';


class DistributeTokensScreen extends StatefulWidget {
  @override
  _DistributeTokensScreenState createState() => _DistributeTokensScreenState();
}

class _DistributeTokensScreenState extends State<DistributeTokensScreen> {
  final ParentService _parentService = ParentService();
  late Future<List<EleveModel>> _childrenFuture;
  Map<int, int> _tokensToDistribute = {};

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _childrenFuture = _loadChildrenData(authService);
  }

  Future<List<EleveModel>> _loadChildrenData(AuthService authService) async {
    if (authService.parent == null || authService.parent!.id == null) {
      throw Exception('Parent information not available');
    }
    return _parentService.getChildrenForParent(authService.parent!.id!);
  }

  void _updateTokensToDistribute(int childId, int amount) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final parentBalance = authService.user?.soldeJetons ?? 0;

    setState(() {
      _tokensToDistribute[childId] = (_tokensToDistribute[childId] ?? 0) + amount;
      if (_tokensToDistribute[childId]! < 0) _tokensToDistribute[childId] = 0;
      if (_tokensToDistribute[childId]! > parentBalance) _tokensToDistribute[childId] = parentBalance;
    });
  }

  Future<void> _distributeTokens() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.user == null || authService.user!.id == null) {
      throw Exception('Parent information not available');
    }

    try {
      for (var entry in _tokensToDistribute.entries) {
        if (entry.value > 0) {
          await _parentService.attributeJetonsToChild(
            parentId: authService.user!.id!,
            childId: entry.key,
            amount: entry.value,
          );
        }
      }

      // Rafraîchir les informations du parent, y compris le solde de jetons
      await authService.refreshUserInfo();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jetons distribués avec succès!')),
      );

      // Réinitialiser la distribution
      setState(() {
        _tokensToDistribute.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la distribution des jetons: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final parentBalance = authService.user?.soldeJetons ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Distribuer des Jetons'),
          backgroundColor: Colors.orange
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Solde de jetons: $parentBalance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EleveModel>>(
              future: _childrenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucun enfant trouvé'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) {
                      final child = snapshot.data![index];
                      return ListTile(
                        title: Text(child.user?.name ?? 'Enfant sans nom'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _updateTokensToDistribute(child.id!, -1),
                            ),
                            Text('${_tokensToDistribute[child.id] ?? 0}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _updateTokensToDistribute(child.id!, 1),
                            ),
                          ],
                        ),
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: _distributeTokens,
      ),


    );
  }
}
