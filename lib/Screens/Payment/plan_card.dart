import 'package:flutter/material.dart';
import 'package:fuel_route/Utils/app_colors.dart';

class PlanCardBox extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String priceSuffix;
  final String? badgeText;
  final bool isHighlighted;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCardBox({
    super.key,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.priceSuffix,
    this.badgeText,
    this.isHighlighted = false,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: isSelected ? Colors.lightBlue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.lightBlueColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: AppColors.lightBlueColor),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: AppColors.darkBlueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkBlueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: price,
                    style: const TextStyle(
                      color: AppColors.darkBlueColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: priceSuffix,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: AppColors.darkBlueColor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.darkBlueColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
