import 'package:flutter/material.dart';
import 'package:fuel_route/Utils/app_colors.dart';
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
    final numberFontSize = mq.width * 0.053;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,

                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// Bottom number
                    Text(
                      number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: numberFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Icon(icon, size: 40, color: AppColors.darkBlueColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
