// lib/locator.dart

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Create a global instance of GetIt
final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register FirebaseFirestore as a lazy singleton.
  // It will be created only when it's first requested.
  locator.registerLazySingleton(() => FirebaseFirestore.instance);

  // You can also register your other services here
  // locator.registerLazySingleton(() => FirestoreService());
  // locator.registerLazySingleton(() => NaiveBayesClassifier());
}