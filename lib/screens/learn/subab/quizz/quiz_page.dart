import 'dart:async';
import 'dart:math';
import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/model/quiz_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/quizz/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class QuizPage extends StatefulWidget {
  final String link;
  final String title;
  final int timerInMinutes;
  final bool isDiagnostic;
  const QuizPage({
    super.key,
    required this.link,
    this.timerInMinutes = 30,
    this.isDiagnostic = false,
    required this.title,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  FullQuizModel? data;
  int _questionNumber = 1;
  List optionsLetters = ["A.", "B.", "C.", "D.", "E."];
  Duration remainingTime = const Duration(minutes: 30);
  Timer? timer;
  List<int> listQuestionNumber = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _cachedScore = 0;
  late TabController _tabController;

  Future<void> _saveScore(double score) async {
    final roundedScore = score.floor();
    await box.put(widget.link, roundedScore);
    setState(() => _cachedScore = roundedScore);
  }

  @override
  void initState() {
    super.initState();
    remainingTime = Duration(minutes: widget.timerInMinutes);

    _fetchQuizData();
    if (mounted) startTimer();
  }

  Future<void> _fetchQuizData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _dio.get(widget.link);

      if (response.statusCode == 200) {
        final quizData = FullQuizModel.fromJson(response.data);
        _tabController = TabController(
          length:
              quizData
                  .questions
                  .length, // Temporary length, will be updated after data fetch
          vsync: this,
        );

        setState(() {
          data = quizData;
          listQuestionNumber = List<int>.generate(
            data!.questions.length,
            (i) => i,
          );
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load quiz: ${response.statusCode}');
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = _handleDioError(e);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      return 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond.';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds <= 1) {
        timer.cancel();
        goToResult();
      } else {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  void goToResult() {
    if (data == null || data!.questions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No quiz data available')));
      return;
    }

    final result = data!.calculateResult(
      data!.questions
          .map(
            (e) =>
                e.selectedWiidgetOption == null
                    ? 0
                    : e.selectedWiidgetOption!.index,
          )
          .toList(),
    );

    print('Score: ${result.score}%');
    print('Passed: ${result.isPassed}');
    print('Correct: ${result.correctCount}/${result.totalQuestions}');
    final elapsedMinutes = max(
      0,
      widget.timerInMinutes - remainingTime.inMinutes,
    );

    try {
      if (widget.isDiagnostic) {
        context.read<NavigationProvider>().setScoreDiagnostic(result.score);
      } else {
        context.read<NavigationProvider>().setScoreDiagnostic(
          context.read<NavigationProvider>().scoreDiagnostic,
        );
      }

      _saveScore(result.score);
    } catch (e) {
      debugPrint('Error saving score: $e');
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => QuizResult(
              correctAnswer: result.correctCount,
              wrongAnser: result.totalQuestions - result.correctCount,
              waktu: elapsedMinutes,

              data: data!,
              judul: widget.title,
              points: result.score,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var prov = context.read<NavigationProvider>();

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading quiz', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text(_errorMessage, textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _fetchQuizData, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(25),
          color: const Color.fromRGBO(249, 249, 249, 1),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_questionNumber > 1) {
                      _tabController.animateTo(_tabController.index - 1);
                      setState(() {
                        _questionNumber--;
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Color.fromRGBO(53, 53, 53, 1),
                    ),
                    fixedSize: WidgetStateProperty.all(
                      Size(MediaQuery.sizeOf(context).width * 0.40, 45),
                    ),
                    elevation: WidgetStateProperty.all(4),
                  ),
                  child: Text(
                    _questionNumber == 1 ? "Kembali" : 'Sebelumnya',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(prov.color),
                    fixedSize: WidgetStateProperty.all(
                      Size(MediaQuery.sizeOf(context).width * 0.40, 45),
                    ),
                    elevation: WidgetStateProperty.all(4),
                  ),
                  onPressed: () {
                    if (_questionNumber < data!.questions.length) {
                      _tabController.animateTo(_tabController.index + 1);
                      setState(() {
                        _questionNumber++;
                      });
                    } else if (_questionNumber == data!.questions.length) {
                      goToResult();
                    }
                  },
                  child: Text(
                    _questionNumber < data!.questions.length
                        ? 'Selanjutnya'
                        : 'Lihat Hasil',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,

        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.of(context).size.height * 0.4,
          ),
          child: Container(
            color: prov.color,
            padding: const EdgeInsets.only(left: 0, right: 0, top: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14, bottom: 5),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: Text(
                              data?.quiz ?? "",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            "${remainingTime.inHours.toString().padLeft(2, '0')}:${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Color.fromRGBO(53, 53, 53, 1),
                    child: TabBar(
                      indicatorAnimation: TabIndicatorAnimation.linear,
                      isScrollable: true,
                      controller: _tabController,
                      onTap: (V) {
                        _questionNumber = V + 1;
                        setState(() {});
                      },
                      indicatorColor: prov.color,
                      labelColor: Colors.transparent,
                      unselectedLabelColor: Colors.transparent,
                      tabs:
                          listQuestionNumber
                              .map(
                                (e) => Tab(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          _questionNumber == e + 1
                                              ? prov.color
                                              : data!
                                                      .questions[e]
                                                      .selectedWiidgetOption !=
                                                  null
                                              ? Helper.lightenColor(
                                                prov.color,
                                                0.5,
                                              )
                                              : Colors.grey,
                                      child: Text(
                                        (e + 1).toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color.fromRGBO(249, 249, 249, 1),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,

            children:
                data!.questions.map((myQuestion) {
                  return ListView(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 64,
                      top: 16,
                    ),
                    children: [
                      HtmlWidget(myQuestion.htmlText),
                      const SizedBox(height: 25),
                      ...myQuestion.options.map((e) {
                        var color = Colors.grey.shade200;
                        var questionOption = e;
                        String letters =
                            optionsLetters[myQuestion.options.indexOf(e)];

                        return (questionOption.text!.isEmpty &&
                                (letters == "E." || letters == "D."))
                            ? const SizedBox()
                            : GestureDetector(
                              onTap: () {
                                setState(() {
                                  myQuestion.selectedWiidgetOption =
                                      questionOption;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.3,
                                    color:
                                        myQuestion.selectedWiidgetOption ==
                                                questionOption
                                            ? Colors.green
                                            : color,
                                  ),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      letters,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: HtmlWidget(
                                        questionOption.text!.trim(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                      }),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
