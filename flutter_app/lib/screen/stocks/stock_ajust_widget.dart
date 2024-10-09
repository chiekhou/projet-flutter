import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/stock_model.dart';
import '../../services/stock_services.dart';

class StockAdjustmentWidget extends StatefulWidget {
  final Stock stock;
  final Function(Stock) onStockUpdated;

  const StockAdjustmentWidget({
    Key? key,
    required this.stock,
    required this.onStockUpdated,
  }) : super(key: key);

  @override
  _StockAdjustmentWidgetState createState() => _StockAdjustmentWidgetState();
}

class _StockAdjustmentWidgetState extends State<StockAdjustmentWidget> {
  final TextEditingController _quantityController = TextEditingController();
  final StockServices stockService = StockServices();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _quantityController,
          decoration: const InputDecoration(
            labelText: 'Quantité à approvisionner',
            hintText: 'Entrez la quantité à ajouter',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final quantity = int.tryParse(_quantityController.text);
            if (quantity != null) {
              try {
                final updatedStock = await stockService.adjustStock(
                    widget.stock.id!, quantity);
                widget.onStockUpdated(updatedStock);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(
                      'Stock ajusté avec succès. Nouvelle quantité: ${updatedStock
                          .quantity}')),
                );
                _quantityController.clear();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(
                      'Erreur lors de l\'ajustement du stock: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Veuillez entrer une quantité valide')),
              );
            }
          },
          child: const Text('Ajuster le stock'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}