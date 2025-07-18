import 'dart:math';

import 'package:flutter/material.dart';

class SubabPdf extends StatefulWidget {
  // final FullQuizModel data;
  final String subject;

  final Color color;

  const SubabPdf({super.key, required this.subject, required this.color});

  @override
  State<SubabPdf> createState() => _CbtSubabState();
}

class _CbtSubabState extends State<SubabPdf> {
  final random = Random();

  // List kelipatan 5 dari 5 sampai 100
  List<int> kelipatan5 = List.generate(20, (i) => (i + 1) * 5);

  // Ambil angka random dari list
  int nilai = 0;
  Color lightenColor(Color color, [double amount = 0.15]) {
    // Use Color.lerp to mix the color with white
    return Color.lerp(color, Colors.white, amount)!;
  }

  Color getWarnaDariNilai(int nilai) {
    if (nilai <= 50) {
      return Colors.red;
    } else if (nilai <= 79) {
      return Colors.orange;
    } else {
      return const Color.fromARGB(255, 75, 175, 75);
    }
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    nilai = kelipatan5[random.nextInt(kelipatan5.length)];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Image.asset(
            "asset/formatif.png",
            width: MediaQuery.of(context).size.width * 0.1,
          ),
        ),
        SizedBox(width: 10),

        Expanded(
          child: Text(
            widget.subject,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(53, 53, 53, 1),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    // Download icon
  }
}
