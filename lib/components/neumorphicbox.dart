import 'package:flutter/material.dart';
import 'package:SNAMP/theme/themeprov.dart';
import 'package:provider/provider.dart';

class NeumorphicBox extends StatelessWidget {
  final Widget child; // Accept child in the constructor

  const NeumorphicBox({super.key, required this.child}); // Constructor

  @override
  Widget build(BuildContext context) {

    bool isDark = Provider.of<Themeprov>(context,listen:false).isDark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Colors.grey.shade500,
            blurRadius: 15,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            blurRadius: 15,
            offset: const Offset(-4, -4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: child
    );
  }
}
