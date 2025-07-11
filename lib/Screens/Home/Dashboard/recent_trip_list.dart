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

    // Sort trips by latest (assuming 'date' or 'createdAt' field exists)
    List<Map<String, String>> sortedTrips = List.from(trips);
    sortedTrips.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['date'] ?? a['createdAt'] ?? '') ??
          DateTime(2000);
      final bDate =
          DateTime.tryParse(b['date'] ?? b['createdAt'] ?? '') ??
          DateTime(2000);
      return bDate.compareTo(aDate); // latest first
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedTrips.length,
      itemBuilder: (context, index) {
        final trip = sortedTrips[index];
        final isActive = trip['status'] == 'ACTIVE';

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
