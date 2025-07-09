import 'package:flutter/material.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class RecentTripList extends StatelessWidget {
  final List<Map<String, String>> trips;

  const RecentTripList({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "No trips found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,

      itemBuilder: (context, index) {
        final trip = trips[index];
        final isActive = trip['status'] == 'Active';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBlueColor, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Left side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Destination: ${trip['destination']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Current: ${trip['current']}",
                      style: const TextStyle(
                        fontSize: 14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Right side status
              Text(
                trip['status'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? Colors.green : AppColors.darkBlueColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
