import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/model/model.dart';
import 'package:elka/model/user.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

class BabAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(132.0); // Set the preferred height

  BabAppbar({super.key});
  @override
  Widget build(BuildContext context) {
    var prov = context.watch<NavigationProvider>();

    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: Container(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Color.fromRGBO(53, 53, 53, 1)),

              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      prov.color,
                      BlendMode.srcATop,
                    ),
                    child: Image.asset(
                      "asset/ornament.png",
                      fit: BoxFit.contain,

                      alignment: Alignment.topRight,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 1,
              right: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: prov.selectedSubject!.imageUrl,
                    width: MediaQuery.of(context).size.width * 0.2,
                    fit: BoxFit.cover,

                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 16),

                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },

                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: prov.color,
                          size: 24,
                        ),
                      ),
                    ),
                    Spacer(),

                    Text(
                      prov.selectedSubject!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      list[listid.indexOf(prov.currentUser!.kelasId)],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),

                    SizedBox(height: 16),
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
