import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          // Votre contenu de la page d'accueil
          SizedBox(height: 20),
          Center(
            child: Text('Page Accueil - À compléter'),
          ),
        ],
      ),
    );
  }
}