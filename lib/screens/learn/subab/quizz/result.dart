import 'package:elka/helper.dart';
import 'package:elka/model/quiz_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizResult extends StatefulWidget {
  final int correctAnswer;
  final int wrongAnser;
  final int waktu;

  final String judul;
  final double points;
  final FullQuizModel data;
  const QuizResult({
    super.key,
    required this.correctAnswer,
    required this.wrongAnser,
    required this.waktu,
    required this.data,
    required this.judul,
    required this.points,
  });

  @override
  State<QuizResult> createState() => _ResultState();
}

class _ResultState extends State<QuizResult> {
  @override
  @override
  Widget build(BuildContext context) {
    var prov = context.read<NavigationProvider>();

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Helper.lightenColor(prov.color, 0.1)),
        ),

        Scaffold(
          backgroundColor: Colors.transparent, // Background color
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(top: 48, bottom: 16),
                  child: Center(
                    child: Text(
                      widget.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromRGBO(249, 249, 249, 1),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  padding: EdgeInsets.only(bottom: 16),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(249, 249, 249, 1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              "asset/top.png",
                              color: prov.color,
                            ),
                          ),
                          Positioned(child: Image.asset("asset/hore.png")),
                          Positioned(
                            bottom: 10,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              height: MediaQuery.of(context).size.width * 0.28,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                    FirebaseAuth
                                        .instance
                                        .currentUser!
                                        .photoURL!,
                                  ),
                                ),
                                color: prov.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Header section with confetti and owl image
                      const SizedBox(height: 12),
                      Text(
                        widget.data.quiz,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: Color.fromARGB(255, 75, 75, 75),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: prov.color,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "${widget.points.floor()} Points",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 36,
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.correctAnswer.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(60, 132, 97, 1),
                                ),
                              ),
                              const Text(
                                'Benar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                widget.wrongAnser.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(183, 52, 44, 1),
                                ),
                              ),
                              const Text(
                                'Salah',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "${widget.waktu}m",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(212, 182, 25, 1),
                                ),
                              ),
                              const Text(
                                'Waktu',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // "Ke beranda" button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: prov.color,

                            // primary: Color(0xFF00ACC1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 40,
                            ),
                            width: double.infinity,
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(249, 249, 249, 1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // "Lihat laporan" link
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }
}
