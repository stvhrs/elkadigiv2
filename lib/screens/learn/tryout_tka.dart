import 'dart:developer';

import 'package:elka/model/bank_soal.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/quiz_button.dart';
import 'package:elka/screens/learn/subab/timeline.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:elka/widgets/shadowBox.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TryoutTka extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log("build tka");

    var snapshot = context.watch<NavigationProvider>();
    return Column(
      children:
          snapshot.bankSoal
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                  child: Column(
                    children: [
                      QuizButton(
                        title: item.title,
                        link: item.quizLink,
                        color: Theme.of(context).primaryColor,
                      ),
                      Divider(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
