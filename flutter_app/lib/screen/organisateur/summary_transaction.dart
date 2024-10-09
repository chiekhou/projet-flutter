import 'package:flutter/material.dart';
import 'package:flutter_app/models/transaction_summary_model.dart';
import 'package:flutter_app/services/jetons_service.dart';
import 'package:flutter_app/widgets/app_drawer.dart'; // Assurez-vous que ce chemin est correct

class TransactionSummaryPage extends StatefulWidget {
  const TransactionSummaryPage({Key? key}) : super(key: key);

  @override
  _TransactionSummaryPageState createState() => _TransactionSummaryPageState();
}

class _TransactionSummaryPageState extends State<TransactionSummaryPage> {
  late Future<TransactionSummary> _summaryFuture;
  final JetonsService _jetonsService = JetonsService();

  @override
  void initState() {
    super.initState();
    _summaryFuture = _jetonsService.getTransactionSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recette globales'),
        backgroundColor: Colors.orange,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[300]!, Colors.orange[700]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<TransactionSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              } else if (snapshot.hasData) {
                final summary = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé des Transactions',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSummaryCard('Total des achats', summary.totalAchats),
                          const SizedBox(height: 8),
                          _buildSummaryCard('Total des utilisations', summary.totalUtilisations),
                          const SizedBox(height: 8),
                          _buildSummaryCard('Total des transferts', summary.totalTransferts),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white)));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(
              '$value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}