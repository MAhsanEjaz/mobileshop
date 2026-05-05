import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/utils.dart';

class QuizAppView extends StatefulWidget {
  const QuizAppView({super.key});

  @override
  State<QuizAppView> createState() => _QuizAppViewState();
}

class _QuizAppViewState extends State<QuizAppView> {
  List<Map<String, String>> quizData = [
    {
      "title": "What is the capital of Pakistan?",
      "A": "Karachi",
      "B": "Lahore",
      "C": "Islamabad",
      "D": "Quetta",
      "correct": "Islamabad",
    },
    {
      "title": "Which language is used in Flutter?",
      "A": "Java",
      "B": "Kotlin",
      "C": "Swift",
      "D": "Dart",
      "correct": "Dart",
    },
    {
      "title": "Who developed Flutter?",
      "A": "Apple",
      "B": "Google",
      "C": "Microsoft",
      "D": "Meta",
      "correct": "Google",
    },
    {
      "title": "Which planet is known as the Red Planet?",
      "A": "Earth",
      "B": "Venus",
      "C": "Mars",
      "D": "Jupiter",
      "correct": "Mars",
    },
    {
      "title": "What does CPU stand for?",
      "A": "Central Process Unit",
      "B": "Central Processing Unit",
      "C": "Computer Personal Unit",
      "D": "Central Power Unit",
      "correct": "Central Processing Unit",
    },
    {
      "title": "Which year did Flutter release?",
      "A": "2015",
      "B": "2016",
      "C": "2017",
      "D": "2018",
      "correct": "2017",
    },
    {
      "title": "Which company owns Android?",
      "A": "Apple",
      "B": "Microsoft",
      "C": "Google",
      "D": "Samsung",
      "correct": "Google",
    },
    {
      "title": "What is the full form of API?",
      "A": "Application Programming Interface",
      "B": "Applied Program Internet",
      "C": "Advanced Programming Index",
      "D": "Application Process Integration",
      "correct": "Application Programming Interface",
    },
    {
      "title": "Which widget is used for layouts in Flutter?",
      "A": "Column",
      "B": "Text",
      "C": "Image",
      "D": "Icon",
      "correct": "Column",
    },
    {
      "title": "Which data structure uses FIFO?",
      "A": "Stack",
      "B": "Queue",
      "C": "Tree",
      "D": "Graph",
      "correct": "Queue",
    },
    {
      "title": "What is 2 + 2?",
      "A": "3",
      "B": "4",
      "C": "5",
      "D": "6",
      "correct": "4",
    },
    {
      "title": "Which protocol is used for web pages?",
      "A": "FTP",
      "B": "SMTP",
      "C": "HTTP",
      "D": "TCP",
      "correct": "HTTP",
    },
    {
      "title": "Which keyword is used for inheritance in Dart?",
      "A": "extends",
      "B": "implements",
      "C": "inherits",
      "D": "with",
      "correct": "extends",
    },
    {
      "title": "Which widget is immutable in Flutter?",
      "A": "StatefulWidget",
      "B": "InheritedWidget",
      "C": "StatelessWidget",
      "D": "StreamBuilder",
      "correct": "StatelessWidget",
    },
    {
      "title": "Which database is NoSQL?",
      "A": "MySQL",
      "B": "PostgreSQL",
      "C": "MongoDB",
      "D": "SQLite",
      "correct": "MongoDB",
    },
  ];
  double currentPage = 0;

  PageController pageController = PageController();

  nextPage() {
    currentPage += 1;
    pageController.nextPage(duration: Duration(microseconds: 5000), curve: Curves.linear);
    setState(() {});
  }


  Timer? _timer;
  int remainingSeconds = 60;
  bool isTimeUp = false;


  void startTimer() {
    _timer?.cancel();

    remainingSeconds = 60;
    isTimeUp = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        timer.cancel();
        isTimeUp = true;
        setState(() {});
      } else {
        remainingSeconds--;
        setState(() {});
      }
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                itemCount: quizData.length,
                itemBuilder: (context, index) {
                  return quizUi(quizData[index], index);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 85,
                    width: 85,
                    child: InkWell(
                      onTap: () {
                        nextPage();
                      },
                      child: CircularProgressIndicator(strokeCap: StrokeCap.round,color: appColor,
                        value: currentPage / quizData.length,
                        backgroundColor: Colors.black26,
                        strokeWidth: 14,
                      ),
                    ),
                  ),
                  Center(child: Icon(CupertinoIcons.arrow_right))

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quizUi(Map<String, dynamic> quizData, int index) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              "Time left: ${remainingSeconds}s",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: remainingSeconds <= 10 ? Colors.red : Colors.black,
              ),
            ),
          ),
        ),


        Text(quizData["title"], style: TextStyle(fontWeight: FontWeight.bold)),
        singleOptionTitle(quizData["A"], index, quizData["correct"]),
        singleOptionTitle(quizData["B"], index, quizData["correct"]),
        singleOptionTitle(quizData["C"], index, quizData["correct"]),
        singleOptionTitle(quizData["D"], index, quizData["correct"]),
      ],
    );
  }

  Map<int, String> quizTap = {};

  singleOptionTitle(String? title, int index, String? correct) {
    final selected = quizTap[index];

    Color cardColor = Colors.white;

    if (selected != null) {
      if (title == correct) {
        cardColor = Colors.green.shade50;
      } else if (title == selected) {
        cardColor = Colors.red.shade50;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: cardColor,
        child: InkWell(
          onTap: () {
            quizTap[index] = title!;
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),
                    color: selected == title ? Colors.pink : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 20),
                Text(title!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
