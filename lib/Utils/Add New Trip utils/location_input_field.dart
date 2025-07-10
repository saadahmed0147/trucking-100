import 'package:flutter/material.dart';

Widget buildSearchBox({
  required String hint,
  required TextEditingController controller,
  required bool isPickup,
  required Function(String) onChanged,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    ),
  );
}

Widget buildPredictionList({
  required List<dynamic> predictions,
  required bool isPickup,
  required Function(String placeId, String description) onTapPrediction,
}) {
  if (predictions.isEmpty) return const SizedBox.shrink();

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListView.builder(
      itemCount: predictions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        return ListTile(
          title: Text(
            prediction['description'],
            style: const TextStyle(fontSize: 15),
          ),
          leading: const Icon(
            Icons.location_on_rounded,
            color: Colors.deepOrange,
          ),
          onTap: () => onTapPrediction(
            prediction['place_id'],
            prediction['description'],
          ),
        );
      },
    ),
  );
}
