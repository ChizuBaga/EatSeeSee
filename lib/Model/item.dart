// You'll need to import the cloud_firestore package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chikankan/locator.dart';

class FirestoreService {
  final FirebaseFirestore _db = locator<FirebaseFirestore>();
  
  // Fetches the 'Comments' array from a specific item document.
  // It returns a Future that will resolve to a List of Strings.
  Future<List<String>> getItemComments(String sellerId, String itemId) async {
    try {
      // 1. Create a reference to the exact document path
      DocumentReference docRef = _db.collection('Seller').doc(sellerId).collection('items').doc(itemId);

      // 2. Get the document snapshot
      DocumentSnapshot docSnapshot = await docRef.get();

      // 3. Check if the document exists
      if (docSnapshot.exists) {
        // 4. Safely extract the 'Comments' field
        // The data is retrieved as Map<String, dynamic>
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        
        // 5. Check if the 'Comments' field exists and is a List
        if (data.containsKey('Comments') && data['Comments'] is List) {
          // 6. Cast the List<dynamic> to List<String> and return it
          return List<String>.from(data['Comments']);
        } else {
          // Field doesn't exist or is not a list, return an empty list
          print("Warning: 'Comments' field is missing or not a list.");
          return [];
        }
      } else {
        // Document does not exist
        print("Error: Document does not exist at path.");
        return [];
      }
    } catch (e) {
      // Handle any potential errors (e.g., network issues, permissions)
      print("An error occurred while fetching comments: $e");
      return []; // Return an empty list on failure
    }
  }
}