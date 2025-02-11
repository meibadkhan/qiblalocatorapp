
import 'package:flutter/material.dart';


class LocationErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback callback;

  const LocationErrorWidget({Key? key, required this.error, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.location_off, size: 100, color: Colors.red),
            Text(error, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: callback, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator.adaptive());
}
