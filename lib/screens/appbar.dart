import 'dart:developer';

import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/model/model.dart';
import 'package:elka/model/user.dart';
import 'package:elka/profile/profile_screen.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(120.0); // Set the preferred height

  CustomAppbar({super.key});
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(132),
      child: Container(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(53, 53, 53, 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),

              height: 124,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "asset/ornament.png",
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: InkWell(
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.amber,
                              child: CachedNetworkImage(
                                imageUrl:
                                    FirebaseAuth.instance.currentUser == null
                                        ? ""
                                        : FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .photoURL!,
                                width: 35,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context
                                  .read<NavigationProvider>()
                                  .currentUser!
                                  .name,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Futura",

                                fontSize: 12,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pin_drop_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                  applyTextScaling: true,
                                ),
                                Text(
                                  " " +
                                      Helper.capitalizeWords(
                                        context
                                            .read<NavigationProvider>()
                                            .selectedSchool!
                                            .sekolah,
                                      ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Futura",

                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: CustomDropdown<String>(
                      expandedHeaderPadding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                      closedHeaderPadding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                      decoration: CustomDropdownDecoration(
                        closedBorder: Border.all(
                          width: 1,
                          color: Color.fromRGBO(231, 231, 231, 1),
                        ),

                        expandedBorderRadius: BorderRadius.circular(20),
                        closedBorderRadius: BorderRadius.circular(25),
                        listItemStyle: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Futura",
                          color: Color.fromARGB(255, 75, 75, 75),
                        ),
                        headerStyle: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Futura",
                          color: Color.fromARGB(255, 75, 75, 75),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Image.asset("asset/siswa.png", width: 24),
                        ),
                        expandedSuffixIcon: const Icon(
                          IconsaxPlusLinear.arrow_up_1,
                          color: Color.fromRGBO(97, 97, 97, 1),
                        ),
                        closedSuffixIcon: const Icon(
                          IconsaxPlusLinear.arrow_down,
                          color: Color.fromRGBO(97, 97, 97, 1),
                        ),
                      ),
                      excludeSelected: false,

                      items: list,
                      initialItem:
                          list[listid.indexOf(
                            context
                                .watch<NavigationProvider>()
                                .currentUser!
                                .kelasId,
                          )],
                      onChanged: (value) async {
                        if (value != null) {
                          log(value);
                          log(list[9]);

                          await context
                              .read<NavigationProvider>()
                              .setSelectedKelas(
                                listid[list.indexOf(value.trim())],
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
