import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fuel_route/Screens/Home/home_screen.dart';
import 'package:fuel_route/Utils/animated_page_route.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/api_keys.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class CalculatorScreen extends StatefulWidget {
  final String pickup;
  final double pickupLat;
  final double pickupLng;

  final String destination;
  final double destinationLat;
  final double destinationLng;

  final String userName;
  final String userEmail;

  const CalculatorScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.userName,
    required this.userEmail,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  DateTime? selectedDate;
  final TextEditingController mpgController = TextEditingController();
  final TextEditingController loadWeightController = TextEditingController();
  final TextEditingController fuelPriceController = TextEditingController();

  double? distanceMiles;
  double? estimatedFuel;
  double? fuelCost;
  String? duration;
  bool isLoading = false;

  final String apiKey = ApiKeys.googleMapsApiKey;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    mpgController.dispose();
    fuelPriceController.dispose();
    loadWeightController.dispose();
    super.dispose();
  }

  Future<void> calculateRoute() async {
    final mpg = double.tryParse(mpgController.text);
    final fuelPrice = double.tryParse(fuelPriceController.text);

    if (mpg == null || mpg <= 0 || fuelPrice == null || fuelPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid MPG and Fuel Price")),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${widget.pickupLat},${widget.pickupLng}'
      '&destination=${widget.destinationLat},${widget.destinationLng}'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final leg = data['routes'][0]['legs'][0];
        final distanceValue = leg['distance']['value'];
        final durationText = leg['duration']['text'];

        setState(() {
          distanceMiles = distanceValue / 1609.34;
          duration = durationText;
          estimatedFuel = distanceMiles! / mpg;
          fuelCost = estimatedFuel! * fuelPrice;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No routes found.")));
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch directions.")),
      );
    }
  }

  bool isAddingTrip = false;
  bool tripAdded = false; // Track if trip is already added

  void handleAddTrip() async {
    if (isAddingTrip) return; // Prevent double tap

    if (tripAdded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Trip already added!")));
      return;
    }

    if (distanceMiles == null ||
        estimatedFuel == null ||
        fuelCost == null ||
        duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please calculate the route first.")),
      );
      return;
    }

    setState(() => isAddingTrip = true);

    final ref = FirebaseDatabase.instance.ref("trips").push();

    await ref.set({
      "pickup": widget.pickup,
      "pickupLat": widget.pickupLat,
      "pickupLng": widget.pickupLng,
      "destination": widget.destination,
      "destinationLat": widget.destinationLat,
      "destinationLng": widget.destinationLng,
      "userName": widget.userName,
      "userEmail": widget.userEmail,
      "date": selectedDate!.toIso8601String(),
      "distanceMiles": distanceMiles,
      "estimatedFuel": estimatedFuel,
      "fuelCost": fuelCost,
      "duration": duration,
      "status": "active",
      "createdAt": DateTime.now().toIso8601String(),
    });

    setState(() {
      isAddingTrip = false;
      tripAdded = true;
    });

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBlueColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Trip Added!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkBlueColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Trip from ${widget.pickup} to ${widget.destination} has been added",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // Distance
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    "Distance: ${distanceMiles!.toStringAsFixed(2)} miles",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fuel Needed
              Row(
                children: [
                  const Icon(
                    Icons.local_gas_station,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Fuel Needed: ${estimatedFuel!.toStringAsFixed(2)} gallons",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fuel Cost
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Fuel Cost: \$${fuelCost!.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Duration
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Duration: $duration",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      navigateWithAnimation(
                        context,
                        const HomeScreen(initialIndex: 1),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,
      appBar: AppBar(
        title: const Text("Smart Trip Planner"),
        backgroundColor: AppColors.splashBgColor,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  _buildCardSection(
                    title: "Trip Details",
                    children: [
                      _buildInputField(Icons.location_on, widget.pickup),
                      const SizedBox(height: 10),
                      _buildInputField(Icons.flag, widget.destination),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildInputField(
                            Icons.calendar_today,
                            selectedDate != null
                                ? "${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                : "Select Date",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCardSection(
                    title: "Truck & Fuel Info",
                    children: [
                      _buildTextField(
                        controller: mpgController,
                        label: "Truck MPG",
                        icon: Icons.local_gas_station,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: loadWeightController,
                        label: "Load Weight (lbs)",
                        icon: Icons.line_weight,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: fuelPriceController,
                        label: "Fuel Price (per gallon)",
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: calculateRoute,
                          icon: const Icon(Icons.route),
                          label: const Text("Calculate Route"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.lightBlueColor,
                        ),
                      ),
                    )
                  else if (distanceMiles != null &&
                      estimatedFuel != null &&
                      fuelCost != null &&
                      duration != null)
                    _buildResultSection(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: handleAddTrip,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Trip"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlueColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(IconData icon, String value) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        hintText: value,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.blackColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderSide: BorderSide(width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      labelText: label,
    );
  }

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Trip Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            "📍 Distance:",
            "${distanceMiles!.toStringAsFixed(2)} miles",
          ),
          _buildResultRow(
            "⛽ Fuel Needed:",
            "${estimatedFuel!.toStringAsFixed(2)} gallons",
          ),
          _buildResultRow("💰 Fuel Cost:", "\$${fuelCost!.toStringAsFixed(2)}"),
          _buildResultRow("🕒 Duration:", duration!),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
