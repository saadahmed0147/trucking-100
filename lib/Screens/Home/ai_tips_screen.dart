import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/api_keys.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiTipsScreen extends StatefulWidget {
  const AiTipsScreen({super.key});

  @override
  State<AiTipsScreen> createState() => _AiTipsScreenState();
}

class _AiTipsScreenState extends State<AiTipsScreen> {
  String? tips;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTipsFromCache();
  }

  Future<void> loadTipsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTips = prefs.getString('cachedTips');

    if (cachedTips != null) {
      setState(() {
        tips = cachedTips;
        loading = false;
      });
    } else {
      fetchLatestTripAndGenerateTips();
    }
  }

  Future<void> fetchLatestTripAndGenerateTips() async {
    setState(() => loading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        tips = "🚫 User not logged in.";
        loading = false;
      });
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref("trips");
      final snapshot = await ref
          .orderByChild("userEmail")
          .equalTo(user.email)
          .get();

      if (!snapshot.exists) {
        setState(() {
          tips =
              "🚚 No active trip found.\n\nStart a new trip to receive personalized AI travel insights for your current route.";
          loading = false;
        });
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      final activeTrips = data.values
          .map((e) => Map<String, dynamic>.from(e))
          .where(
            (trip) =>
                trip['userEmail'] == user.email &&
                (trip['status']?.toString().toLowerCase() == 'active'),
          )
          .toList();

      if (activeTrips.isEmpty) {
        setState(() {
          tips =
              "🚚 No active trip found.\n\nStart a new trip to receive personalized AI travel insights for your current route.";
          loading = false;
        });
        return;
      }

      activeTrips.sort(
        (a, b) => DateTime.parse(
          b['createdAt'],
        ).compareTo(DateTime.parse(a['createdAt'])),
      );
      final latestActiveTrip = activeTrips.first;

      final result = await generateTripInsights(latestActiveTrip);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedTips', result);

      setState(() {
        tips = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        tips = "❌ Something went wrong. Please try again later.";
        loading = false;
      });
      print("Error fetching tips: $e");
    }
  }

  Future<String> generateTripInsights(Map<String, dynamic> trip) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: ApiKeys.geminiApiKey,
    );

    final prompt =
        '''
You are an expert assistant for truck drivers. A user is planning a trip from ${trip['pickup']} to ${trip['destination']}.

Details:
- Distance: ${trip['distanceMiles']} miles
- Estimated fuel: ${trip['estimatedFuel']} gallons
- Estimated cost: \$${trip['fuelCost']}
- Duration: ${trip['duration']}

Provide useful travel tips, including:
- Estimated number of fuel stations on the route
- Recommended stops or rest areas
- Warnings (e.g. weigh stations, tolls)
- Fuel saving tips or any other relevant advice
''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? "No tips generated.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tabsBgColor,
      // floatingActionButton: FloatingActionButton(
      //   foregroundColor: AppColors.whiteColor,
      //   backgroundColor: AppColors.lightBlueColor,
      //   onPressed: () {
      //     fetchLatestTripAndGenerateTips();
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AI Trip Assistant",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.splashBgColor,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.lightBlueColor,
                      onRefresh: () async {
                        await fetchLatestTripAndGenerateTips();
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: tips != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: tips!
                                      .split('\n')
                                      .where(
                                        (line) =>
                                            line.trim().isNotEmpty &&
                                            !line.trim().startsWith('```'),
                                      )
                                      .map((line) {
                                        IconData icon = Icons.arrow_right;
                                        if (line.contains('fuel station') ||
                                            line.contains('⛽')) {
                                          icon = Icons.local_gas_station;
                                        } else if (line.contains('stop') ||
                                            line.contains('rest')) {
                                          icon = Icons.hotel;
                                        } else if (line.contains('warning') ||
                                            line.contains('⚠️')) {
                                          icon = Icons.warning_amber_rounded;
                                        } else if (line.contains('tip') ||
                                            line.contains('💡')) {
                                          icon = Icons.lightbulb;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                icon,
                                                color: AppColors.lightBlueColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  line
                                                      .trim()
                                                      .replaceAll(
                                                        RegExp(r'^[-•✔️]'),
                                                        '',
                                                      )
                                                      .trim(),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                                )
                              : const Text("No tips available."),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
