import 'package:flutter/material.dart';
import 'package:flutter_app/screen/stocks/stock_ajust_widget.dart';
import '../../models/stock_model.dart';

class StockDetailsScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailsScreen({Key? key, required this.stock}) : super(key: key);

  @override
  _StockDetailsScreenState createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  late Stock _currentStock;

  @override
  void initState() {
    super.initState();
    _currentStock = widget.stock;
  }

  void _updateStock(Stock updatedStock) {
    setState(() {
      _currentStock = updatedStock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du stock: ${_currentStock.nomProduit}'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[100]!, Colors.orange[300]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produit: ${_currentStock.nomProduit}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              Text('Quantité actuelle: ${_currentStock.quantity}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              const Text('Ajuster le stock:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StockAdjustmentWidget(
                stock: _currentStock,
                onStockUpdated: _updateStock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}