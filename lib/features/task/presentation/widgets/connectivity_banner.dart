import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final String message;
  
  const ConnectivityBanner({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.withOpacity(0.2),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
