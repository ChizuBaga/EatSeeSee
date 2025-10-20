import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chikankan/Model/item_model.dart'; // Import your model
import 'package:chikankan/Controller/MNB_classifier.dart'; // Import your classifier
import 'package:chikankan/locator.dart';

class ItemDetailsPage extends StatelessWidget {
  final String sellerId;
  final String itemId;
  const ItemDetailsPage({
    super.key,
    required this.sellerId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define a reference to the specific document
    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('Seller')
        .doc(sellerId)
        .collection('items')
        .doc(itemId);

    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      // 2. Use a FutureBuilder to fetch the data once
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching item: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Item not found."));
          }

          // 3. If data exists, create an Item object using our model
          final Item item = Item.fromFirestore(snapshot.data!);

          // --- 4. NEW: Perform sentiment analysis ---
          // NOTE: This assumes your classifier's model is already loaded,
          // for example, by using a singleton or service locator pattern.
          final classifier = locator<NaiveBayesClassifier>();
          int positiveCount = 0;
          double positivePercentage = 0.0;
          double negativePercentage = 0.0;
          
          if (item.comments.isNotEmpty) {
            for (final comment in item.comments) {
              // Assuming 1 is 'Good' and 0 is 'Bad'
              if (classifier.predict(comment) == 1) {
                positiveCount++;
              }
            }
            positivePercentage = (positiveCount / item.comments.length) * 100;
            negativePercentage = 100 - positivePercentage;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Display Name and Price ---
              Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text("\$${item.price.toStringAsFixed(2)}", style: Theme.of(context).textTheme.titleLarge),
              const Divider(height: 32),

              // --- 5. MODIFIED: Comments Analyzer Widget ---
              Text("Comments Analysis", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // --- Good Reviews Column ---
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${positivePercentage.toStringAsFixed(0)}%', // Large percentage
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("👍 Good Reviews"),
                          ],
                        ),
                      ),
                      // --- Bad Reviews Column ---
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${negativePercentage.toStringAsFixed(0)}%', // Large percentage
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("👎 Bad Reviews"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),

              // --- Display Raw Comments ---
              Text("Comments", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.comments.map((comment) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(comment),
                  ),
                )).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}