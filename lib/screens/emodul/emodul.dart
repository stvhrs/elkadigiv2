import 'dart:developer';

import 'package:elka/input/bookform.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/appbar.dart';
import 'package:elka/screens/book/book_item.dart';
import 'package:elka/screens/emodul/emodul_item.dart';
import 'package:elka/screens/emodul/slider.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Emodul extends StatefulWidget {
  const Emodul({super.key});

  @override
  State<Emodul> createState() => _EmodulState();
}

class _EmodulState extends State<Emodul> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init([bool rdtb = false]) async {
    try {
      var data = await FirebaseService().fetchBooks(
        context.read<NavigationProvider>().currentUser!.kelasId,
        forceRefresh: rdtb,
      );
      var data2 = await FirebaseService().fetchBooksUniversal(
        forceRefresh: rdtb,
      );

      if (mounted) {
        context.read<NavigationProvider>().setBooksUniversal(data2);

        context.read<NavigationProvider>().setBooks(data);
      }
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FirebaseAuth.instance.currentUser!.uid !=
                  "0AdM3JnI6dUtdlti59uk2wfaHk83"
              ? SizedBox()
              : FloatingActionButton(
                backgroundColor: Colors.green,
                child:
                    FirebaseAuth.instance.currentUser!.uid !=
                            "0AdM3JnI6dUtdlti59uk2wfaHk83"
                        ? SizedBox()
                        : Icon(Icons.add, color: Colors.white),

                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => BookForm()));
                },
              ),
      appBar: CustomAppbar(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async => await _init(true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  BannerSlider(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 45,
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(3.5),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Color.fromRGBO(209, 209, 209, 1),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashFactory:
                      NoSplash.splashFactory, // Disable splash effect
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  labelColor: Colors.white, // Text color for selected tab
                  unselectedLabelColor: Color.fromRGBO(
                    150,
                    150,
                    150,
                    1,
                  ), // Text color for unselected tabs
                  isScrollable: false, // Ensures tabs have equal width
                  indicator: BoxDecoration(
                    color: Color.fromRGBO(
                      53,
                      53,
                      53,
                      1,
                    ), // Background color for the selected tab
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  controller: _tabController,
                  tabs: [
                    Tab(child: Text("BSE", style: TextStyle(fontSize: 12))),
                    Tab(child: Text("Umum", style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ),

            SliverFillRemaining(fillOverscroll: true,hasScrollBody: true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Consumer<NavigationProvider>(
                      builder: (context, snapshot, _) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 3 / 4.5,
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: snapshot.books.length ?? 0,
                          itemBuilder: (context, index) {
                            return BookItem(snapshot.books![index]);
                          },
                        );
                      },
                    ),
                    Consumer<NavigationProvider>(
                      builder: (context, snapshot, _) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 3 / 5,
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: snapshot.booksUniversal.length ?? 0,
                          itemBuilder: (context, index) {
                            return BookItem(snapshot.booksUniversal![index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
