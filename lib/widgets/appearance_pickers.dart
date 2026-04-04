import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../theme.dart';

class AppearancePickers extends StatelessWidget {
  final String selectedColor;
  final String selectedIcon;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onIconSelected;

  const AppearancePickers({
    super.key,
    required this.selectedColor,
    required this.selectedIcon,
    required this.onColorSelected,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAMPAIGN COLOR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: kCampaignColorOptions.length,
          itemBuilder: (context, i) {
            final hex = kCampaignColorOptions[i];
            final color = Color(int.parse(hex, radix: 16) | 0xFF000000);
            final isSelected = hex == selectedColor;
            return GestureDetector(
              onTap: () => onColorSelected(hex),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected ? kBlack : kSoftBorderColor,
                    width: isSelected ? kBorderWidth : kSoftBorderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: kSoftShadowColor,
                      offset: Offset(kShadowOffset, kShadowOffset),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        const Text(
          'CAMPAIGN ICON',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: kCampaignIconOptions.length,
          itemBuilder: (context, i) {
            final (name, iconData) = kCampaignIconOptions[i];
            final isSelected = name == selectedIcon;
            final accentColor =
                Color(int.parse(selectedColor, radix: 16) | 0xFF000000);
            return GestureDetector(
              onTap: () => onIconSelected(name),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : kWhite,
                  border: Border.all(
                    color: isSelected ? kBlack : kSoftBorderColor,
                    width: isSelected ? kBorderWidth : kSoftBorderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: kSoftShadowColor,
                      offset: Offset(kShadowOffset, kShadowOffset),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  iconData,
                  size: 20,
                  color: isSelected ? Colors.white : kTextSecondary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
