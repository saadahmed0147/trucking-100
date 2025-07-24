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
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    loadTipsFromCache();
  }

  Future<void> loadTipsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTips = prefs.getString('cachedTips');
    final lastCacheTime = prefs.getInt('lastCacheTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Cache valid for 30 minutes (1800000 milliseconds)
    if (cachedTips != null && (currentTime - lastCacheTime) < 1800000) {
      setState(() {
        tips = cachedTips;
        loading = false;
      });

      // Background refresh if cache is older than 15 minutes
      if ((currentTime - lastCacheTime) > 900000) {
        fetchLatestTripAndGenerateTips(isRefresh: true, silent: true);
      }
    } else {
      fetchLatestTripAndGenerateTips();
    }
  }

  Future<void> fetchLatestTripAndGenerateTips({
    bool isRefresh = false,
    bool silent = false,
  }) async {
    if (!silent) {
      if (isRefresh) {
        setState(() => isRefreshing = true);
      } else {
        setState(() => loading = true);
      }
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!silent) {
        setState(() {
          tips = "🚫 User not logged in.";
          loading = false;
          isRefreshing = false;
        });
      }
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref("trips");
      final snapshot = await ref
          .orderByChild("userEmail")
          .equalTo(user.email)
          .limitToLast(10) // Limit query for faster response
          .get();

      if (!snapshot.exists) {
        if (!silent) {
          setState(() {
            tips =
                "🚚 No active trip found.\n\nStart a new trip to receive personalized AI travel insights for your current route.";
            loading = false;
            isRefreshing = false;
          });
        }
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
        if (!silent) {
          setState(() {
            tips =
                "🚚 No active trip found.\n\nStart a new trip to receive personalized AI travel insights for your current route.";
            loading = false;
            isRefreshing = false;
          });
        }
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
      await prefs.setInt(
        'lastCacheTime',
        DateTime.now().millisecondsSinceEpoch,
      );

      setState(() {
        tips = result;
        loading = false;
        isRefreshing = false;
      });
    } catch (e) {
      if (!silent) {
        setState(() {
          tips = "❌ Something went wrong. Please try again later.";
          loading = false;
          isRefreshing = false;
        });
      }
      print("Error fetching tips: $e");
    }
  }

  Future<String> generateTripInsights(Map<String, dynamic> trip) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash', // Using faster flash model instead of pro
      apiKey: ApiKeys.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3, // Lower temperature for more focused responses
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 500, // Limit output for faster response
      ),
    );

    final prompt =
        '''
Trip: ${trip['pickup']} to ${trip['destination']}
Distance: ${trip['distanceMiles']} miles, Fuel: ${trip['estimatedFuel']} gallons, Cost: \$${trip['fuelCost']}, Duration: ${trip['duration']}

Provide 4-5 quick trucking tips:
- Fuel stations count estimate
- Rest stops recommendation
- Tolls/weigh stations warnings
- Fuel efficiency tips
- Route-specific advice

Keep it concise and practical.
''';

    final content = [Content.text(prompt)];

    // Add timeout for faster response
    try {
      final response = await model
          .generateContent(content)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception("Request timed out. Please try again.");
            },
          );
      return response.text ?? "No tips generated.";
    } catch (e) {
      if (e.toString().contains("timed out")) {
        return "⏱️ Response took too long. Please check your connection and try again.";
      }
      rethrow;
    }
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
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
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
                        await fetchLatestTripAndGenerateTips(isRefresh: true);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Stack(
                            children: [
                              Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: tips!
                                            .split('\n')
                                            .where(
                                              (line) =>
                                                  line.trim().isNotEmpty &&
                                                  !line.trim().startsWith(
                                                    '```',
                                                  ),
                                            )
                                            .map((line) {
                                              IconData icon = Icons.arrow_right;
                                              if (line.contains(
                                                    'fuel station',
                                                  ) ||
                                                  line.contains('⛽')) {
                                                icon = Icons.local_gas_station;
                                              } else if (line.contains(
                                                    'stop',
                                                  ) ||
                                                  line.contains('rest')) {
                                                icon = Icons.hotel;
                                              } else if (line.contains(
                                                    'warning',
                                                  ) ||
                                                  line.contains('⚠️')) {
                                                icon =
                                                    Icons.warning_amber_rounded;
                                              } else if (line.contains('tip') ||
                                                  line.contains('💡')) {
                                                icon = Icons.lightbulb;
                                              }

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                    ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      icon,
                                                      color: AppColors
                                                          .lightBlueColor,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        line
                                                            .trim()
                                                            .replaceAll(
                                                              RegExp(
                                                                r'^[-•✔️]',
                                                              ),
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
                            ],
                          ),
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
