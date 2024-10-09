import 'package:flutter/material.dart';
import 'package:flutter_app/screen/stocks/stock_details.dart';
import 'package:flutter_app/services/stock_services.dart';
import '../../models/stock_model.dart';
import '../../widgets/app_drawer.dart';


class StockListScreen extends StatefulWidget {
  const StockListScreen({Key? key}) : super(key: key);

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final StockServices _stockService = StockServices();
  late Future<List<Stock>> _stocksFuture;

  @override
  void initState() {
    super.initState();
    _stocksFuture = _stockService.getStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de stocks'),
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
        child: FutureBuilder<List<Stock>>(
          future: _stocksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun stock disponible'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length + 1,  // +1 pour la carte statique
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Stocks disponibles',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Gérez votre stock',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final stock = snapshot.data![index - 1];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.celebration, color: Colors.white),
                        ),
                        title: Text(
                          stock.nomProduit,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Quantité: ${stock.quantity.toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockDetailsScreen(stock: stock),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}