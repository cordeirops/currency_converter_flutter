import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
      ),
      child: const Center(
        child: Text(
          '© 2025 Pedro Sbaraini Cordeiro | Todos os direitos reservados',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
