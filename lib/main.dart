import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'VIEWS/pantry_home_view.dart';

void main() {
  runApp(
      // ProviderScope is required for Riverpod state management to work
          const ProviderScope(
                child: SmartPantryApp(),
                    ),
                      );
                      }

                      class SmartPantryApp extends StatelessWidget {
                        const SmartPantryApp({super.key});

                          @override
                            Widget build(BuildContext context) {
                                return MaterialApp(
                                      title: 'Smart Pantry',
                                            debugShowCheckedModeBanner: false,
                                                  theme: ThemeData(
                                                          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                                                                  useMaterial3: true,
                                                                        ),
                                                                              home: const PantryHomeView(),
                                                                                  );
                                                                                    }
                                                                                    }
                                                                                    