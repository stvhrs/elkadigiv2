import 'dart:developer';

import 'package:elka/model/user.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/emodul/emodul.dart';
import 'package:elka/screens/learn/learn_page.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

/// Flutter code sample for [BottomNavigationBar].

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    if (!kIsWeb) {}
    init();
    super.initState();
  }

  bool _loading = true;
  init() async {
    try {
      var prov = context.read<NavigationProvider>();
      var data = await FirebaseService().fetchUser(
        FirebaseAuth.instance.currentUser!.uid,
      );
      prov.setCurrentUser(data!);
      var data2 = await FirebaseService().fetchSchool(
        prov.currentUser!.userType == UserType.SISWA ? "student" : "school",
        prov.currentUser!.id,
      );
      prov.setSelectedSchool(data2);
      var data4 = await FirebaseService().getSlidersByKabupatenId(
        data2!.kodeKabKota,
      );
      // var datax = await FirebaseService().fetchAllEmodulsByKelas(
      //   context.read<NavigationProvider>().currentUser!.kelasId,
      // );

      // if (mounted) {
      //   context.read<NavigationProvider>().setEmoduls(datax);
      // }
      prov.setSliderItems(data4);
      var books = await FirebaseService().fetchBooks(prov.currentUser!.kelasId);
      prov.setBooks(books);
      await prov.loadBankSoal();
      var booksUniversal = await FirebaseService().fetchBooksUniversal();
      prov.setBooksUniversal(booksUniversal);
    } catch (e) {
      log(e.toString());
    } finally {
      log("finllay");
      _loading = false;
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Consumer<NavigationProvider>(
          builder: (context, data, c) {
            return _loading
                ? Scaffold(body: Center(child: CircularProgressIndicator()))
                : ScaffoldMessenger(
                  key: _scaffoldKey,
                  child: Scaffold(
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.miniCenterDocked,
                    body:LearnPage(),
                   
                      
                    
                  ),
                );
          },
        ),
      ],
    );
  }
}
