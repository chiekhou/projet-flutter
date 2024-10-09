import 'package:flutter/cupertino.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CardInputWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: CardField(
        onCardChanged: (card) {
          print(card);
        },
      ),
    );
  }
}