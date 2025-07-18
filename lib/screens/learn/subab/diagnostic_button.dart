import 'package:elka/main.dart';
import 'package:elka/model/quiz_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/quizz/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class DiagnosticButton extends StatefulWidget {
  final String title;
  final String link;

  const DiagnosticButton({super.key, required this.title, required this.link});

  @override
  State<DiagnosticButton> createState() => _QuizButtonState();
}

class _QuizButtonState extends State<DiagnosticButton> {
  bool _loading = true;
  int _cachedScore = 0;

  Color lightenColor(Color color, [double amount = 0.15]) {
    return Color.lerp(color, Colors.white, amount)!;
  }

  @override
  void initState() {
    super.initState();
    _initHiveAndLoadScore();
  }

  Future<void> _initHiveAndLoadScore() async {
    _loadCachedScore();
  }

  Future<void> _loadCachedScore() async {
    // setState(() => _loading = true);
    _cachedScore = box.get(widget.link, defaultValue: 0) as int;

    // Update provider if needed
    // final provider = Provider.of<NavigationProvider>(context, listen: false);
    // if (provider.scoreDiagnostic != _cachedScore) {
    //   provider.setScoreDiagnostic(_cachedScore.toDouble());
    // }

    // setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    _initHiveAndLoadScore();

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => QuizPage(
                  isDiagnostic: true,
                  title: widget.title,
                  link: widget.link,
                ),
          ),
        );

        // Save score if returned from quiz
      },
      child: Consumer<NavigationProvider>(
        builder: (context, snapshot, _) {
          // Use cached score if available, otherwise use provider score
          final displayScore = _cachedScore.toDouble();

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: lightenColor(snapshot.color, 0.9),
                          ),
                          SizedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 4.5,
                              strokeCap: StrokeCap.round,
                              value: displayScore / 100,
                              color: snapshot.color,
                              backgroundColor: lightenColor(
                                snapshot.color,
                                0.5,
                              ),
                            ),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            "${displayScore.floor()}",
                            style: TextStyle(
                              color: snapshot.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(53, 53, 53, 1),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Kerjakan dengan minimal nilai 75",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
