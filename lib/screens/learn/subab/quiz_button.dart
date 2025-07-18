import 'package:elka/main.dart';
import 'package:elka/model/quiz_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/quizz/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class QuizButton extends StatefulWidget {
  final String title;
  final String link;
  final Color color;
  const QuizButton({
    super.key,
    required this.title,
    required this.link,
    required this.color,
  });

  @override
  State<QuizButton> createState() => _QuizButtonState();
}

class _QuizButtonState extends State<QuizButton> {
  Color lightenColor(Color color, [double amount = 0.15]) {
    return Color.lerp(color, Colors.white, amount)!;
  }

  Future<int> _loadCachedScore() async {
    try {
      return box.get(widget.link, defaultValue: 0) as int;
    } catch (e) {
      debugPrint('Error loading score: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _loadCachedScore(),
      builder: (context, snapshot) {
        return Consumer<NavigationProvider>(
          builder: (context, navProvider, _) {
            // Handle different Future states
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator(widget.color);
            }

            if (snapshot.hasError) {
              return _buildErrorState(widget.color);
            }

            final displayScore = snapshot.data?.toDouble() ?? 0.0;

            return _buildQuizButton(navProvider, displayScore);
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox();
  }

  Widget _buildErrorState(Color color) {
    return Center(child: Icon(Icons.error_outline, color: color, size: 20));
  }

  Widget _buildQuizButton(NavigationProvider navProvider, double displayScore) {
    return Padding(
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
                  backgroundColor: lightenColor(widget.color, 0.9),
                ),
                SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                    value: displayScore / 100,
                    color: widget.color,
                    backgroundColor: lightenColor(widget.color, 0.5),
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  "${displayScore.floor()}",
                  style: TextStyle(
                    color: widget.color,
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
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 75, 75, 75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => QuizPage(
                          title: widget.title,
                          link: widget.link,
                          timerInMinutes: 120,
                        ),
                  ),
                );
                // Refresh the score after returning from quiz
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                child: const Text(
                  "Mulai",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
