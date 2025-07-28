import 'dart:developer';

import 'package:elka/main.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/appbar.dart';
import 'package:elka/screens/emodul/emodul.dart';
import 'package:elka/screens/learn/learn_button.dart';
import 'package:elka/screens/learn/tryout_tka.dart';
import 'package:elka/service/firebase_service.dart';

import 'package:flutter/material.dart';
import "package:provider/provider.dart";

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    init(false);
  }

  init(bool refresh) async {
    log("init learn");
    var data = await FirebaseService().getSubjectsByKelasId(
      context.read<NavigationProvider>().currentUser!.kelasId,
      forceRefresh: refresh,
    );
    if (mounted) context.read<NavigationProvider>().setSubjects(data);
    await context.read<NavigationProvider>().loadBankSoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          await init(true);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            left: 8,
                            bottom: 16,
                            top: 24,
                          ),

                          child: Text(
                            "Belajar dengan E-Modul",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 75, 75, 75),
                            ),
                          ),
                        ),
                        Consumer<NavigationProvider>(
                          builder: (context, data, c) {
                            return GridView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              primary: false,
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 3 / 4.7,
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 20,
                                  ),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.subjects!.length,
                              itemBuilder:
                                  (context, index) => LearnButton(
                                    context
                                        .read<NavigationProvider>()
                                        .subjects![index],
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            left: 8,
                            bottom: 16,
                            top: 24,
                          ),

                          child: Text(
                            "Tryout TKA",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(255, 75, 75, 75),
                            ),
                          ),
                        ),
                        TryoutTka(),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(height: 1200, width: 400, child: Emodul()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
