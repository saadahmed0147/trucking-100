import 'package:flutter/material.dart';
import 'package:fuel_route/main.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String number;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.number,
    this.icon = Icons.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final padding = mq.width * 0.03;
    final titleFontSize = mq.width * 0.035;
    final numberFontSize = mq.width * 0.055;
    final iconSize = mq.width * 0.06;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row: Texts + Icon
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: iconSize, color: Colors.lightBlueAccent),
            ],
          ),

          /// Bottom number
          Text(
            number,
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
