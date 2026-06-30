import 'package:flutter/material.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';

class AddDeviceBottomSheet extends StatefulWidget {
  const AddDeviceBottomSheet({super.key});

  @override
  State<AddDeviceBottomSheet> createState() => _AddDeviceBottomSheetState();
}

class _AddDeviceBottomSheetState extends State<AddDeviceBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Device", // Or use localization if available
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context, ''),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Adding new devices requires the device to be turned on, and serial devices require a complete connection between the computer and the device.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionBtn(
            context,
            "Serial port",
            Icons.cable, // Using a generic icon if specific svg isn't easily available, or I can use the existing SVG
            'com',
          ),
          const SizedBox(height: 16),
          _buildOptionBtn(
            context,
            "Network",
            Icons.language,
            'wifi',
          ),
          const SizedBox(height: 16),
          _buildOptionBtn(
            context,
            "Bluetooth",
            Icons.bluetooth,
            'bt',
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(BuildContext context, String title, IconData icon, String type) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, type);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D558E), // Match the blue from image
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: const Color(0xFF0D558E), size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
