import 'dart:io';

import 'package:flutter/material.dart';

bool isDesktop() {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

enum Category {
  geography("images/geography.png", "Geography"),
  history("images/history.png", "History"),
  literature("images/literature.png", "Literature"),
  movie("images/movie.png", "Movie"),
  music("images/music.png", "Music"),
  science("images/science.png", "Science"),
  sport("images/sports.png", "Sport");

  final String img;
  final String label;

  const Category(this.img, this.label);
}

class Question {
  final Category category;
  final String question;
  final String hint1;
  final String hint2;
  final String answer;

  const Question({
    required this.category,
    required this.question,
    required this.hint1,
    required this.hint2,
    required this.answer,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Poker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _questions = <Question>[];
  int _selectedIndex = 0;
  final _destinations = <Map<String, dynamic>>[
    {"label": "Questions", "icon": Icons.help},
    {"label": "New Question", "icon": Icons.add},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_selectedIndex]["label"]),
      ),
      body: Row(
        children: [
          if (isDesktop())
            NavigationRail(
              elevation: 1,
              labelType: NavigationRailLabelType.all,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestSelected,
              destinations: _destinations.map((d) {
                return NavigationRailDestination(
                    icon: Icon(d["icon"]), label: Text(d["label"]));
              }).toList(),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                QuestionsPage(questions: _questions),
                NewQuestionPage(addNewQuestion: _addNewQuestion),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop()
          ? NavigationBar(
              elevation: 1,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestSelected,
              destinations: _destinations.map((d) {
                return NavigationDestination(
                    icon: Icon(d["icon"]), label: d["label"]);
              }).toList(),
            )
          : null,
    );
  }

  void _onDestSelected(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  void _addNewQuestion(Question newQuestion) {
    setState(() {
      _questions.add(newQuestion);
      _selectedIndex = 0;
    });
  }
}

class NewQuestionPage extends StatefulWidget {
  final Function(Question) addNewQuestion;

  const NewQuestionPage({super.key, required this.addNewQuestion});

  @override
  State<NewQuestionPage> createState() => _NewQuestionPageState();
}

class _NewQuestionPageState extends State<NewQuestionPage> {
  final _categoryList = <DropdownMenuItem<Category>>[
    const DropdownMenuItem(value: null, child: Text("--Select a category--")),
    DropdownMenuItem(
        value: Category.geography, child: Text(Category.geography.label)),
    DropdownMenuItem(
        value: Category.history, child: Text(Category.history.label)),
    DropdownMenuItem(
        value: Category.literature, child: Text(Category.literature.label)),
    DropdownMenuItem(value: Category.movie, child: Text(Category.movie.label)),
    DropdownMenuItem(value: Category.music, child: Text(Category.music.label)),
    DropdownMenuItem(
        value: Category.science, child: Text(Category.science.label)),
    DropdownMenuItem(value: Category.sport, child: Text(Category.sport.label)),
  ];

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _hint1Controller = TextEditingController();
  final _hint2Controller = TextEditingController();

  Category? _selectedCategory;

  String _errorMessage = "";

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hint1Controller.dispose();
    _hint2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8.0), children: [
      const Text("Category:"),
      DropdownButton(
          value: _selectedCategory,
          items: _categoryList,
          onChanged: (selectedCategory) {
            setState(() {
              _selectedCategory = selectedCategory;
            });
          }),
      const Text("Question:"),
      TextField(
        controller: _questionController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), hintText: "Write a question"),
      ),
      const Text("Answer:"),
      TextField(
        controller: _answerController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), hintText: "Write an answer"),
      ),
      const Text("Hint 1:"),
      TextField(
        controller: _hint1Controller,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), hintText: "Write a first hint"),
      ),
      const Text("Hint 2:"),
      TextField(
        controller: _hint2Controller,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), hintText: "Write a second hint"),
      ),
      Text(
        _errorMessage,
        style: const TextStyle(color: Color(0xFFB71C1C)),
      ),
      ElevatedButton(
          onPressed: _saveQuestion, child: const Text("Save question"))
    ]);
  }

  void _saveQuestion() {
    String nQuestion = _questionController.text.trim();
    String nAnswer = _answerController.text.trim();
    String nHint1 = _hint1Controller.text.trim();
    String nHint2 = _hint2Controller.text.trim();

    String errMsg =
        _validateForm(_selectedCategory, nQuestion, nAnswer, nHint1, nHint2);

    if (errMsg.isNotEmpty) {
      setState(() {
        _errorMessage = errMsg;
      });
    } else {
      widget.addNewQuestion(Question(
          category: _selectedCategory!,
          question: nQuestion,
          hint1: nHint1,
          hint2: nHint2,
          answer: nAnswer));
      _clearForm();
    }
  }

  String _validateForm(
      Category? category, String question, answer, hint1, hint2) {
    if (category == null) {
      return "Select a category";
    }
    if (question.isEmpty) {
      return "Write a question";
    }
    if (answer.isEmpty) {
      return "Write a answer";
    }
    if (hint1.isEmpty) {
      return "Write a first hint";
    }
    if (hint2.isEmpty) {
      return "Write a second hint";
    }
    return "";
  }

  void _clearForm() {
    _selectedCategory = null;
    _questionController.text = "";
    _answerController.text = "";
    _hint1Controller.text = "";
    _hint2Controller.text = "";
    _errorMessage = "";
  }
}

class QuestionsPage extends StatelessWidget {
  final List<Question> questions;

  const QuestionsPage({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return Scaffold(
      body: ListView.builder(
          scrollDirection: isSmallScreen ? Axis.vertical : Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          itemCount: questions.length,
          itemBuilder: (ctx, index) => QuestionWidget(
                number: index + 1,
                question: questions[index],
                onTap: () {
                  _goToQuestionDetailPage(ctx, questions[index]);
                },
              )),
    );
  }

  void _goToQuestionDetailPage(BuildContext context, Question question) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => QuestionDetailPage(question: question)));
  }
}

class QuestionDetailPage extends StatefulWidget {
  final Question question;

  const QuestionDetailPage({super.key, required this.question});

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  int attempt = 0;
  bool isFinished = false;
  String message = "";
  Color messageColor = const Color(0xFFFF6F00);
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          Text(
            widget.question.category.label,
            style: const TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
                fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    widget.question.category.img,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          Text(
            widget.question.question,
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Answer"),
                  hintText: "Write your answer"),
            ),
          ),
          if (!isFinished)
            Center(
              child: ElevatedButton(
                  child: const Text("Check answer"),
                  onPressed: () {
                    _checkAnswer();
                  }),
            ),
          Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: message.isEmpty ? 0 : 1,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: messageColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _checkAnswer() {
    final answer = controller.text.trim();
    if (widget.question.answer.toLowerCase() == answer.toLowerCase() &&
        attempt < 3) {
      setState(() {
        isFinished = true;
        message = "Correct answer!\n(${attempt + 1}/3)";
        messageColor = const Color(0xFF1B5E20);
      });
    } else {
      if (attempt == 0) {
        setState(() {
          message =
              "Wrong answer.\nHint: ${widget.question.hint1}\nAttempt: ${attempt + 1}/3";
        });
      } else if (attempt == 1) {
        setState(() {
          message =
              "Wrong answer.\nHint: ${widget.question.hint2}\nAttempt: ${attempt + 1}/3";
        });
      } else {
        setState(() {
          message =
              "Wrong answer.\nAnswer: ${widget.question.answer}\nAttempt: ${attempt + 1}/3";
          isFinished = true;
          messageColor = const Color(0xFFB71C1C);
        });
      }
      attempt++;
    }
  }
}

class QuestionWidget extends StatelessWidget {
  final int number;
  final Question question;
  final Function onTap;

  const QuestionWidget({
    super.key,
    required this.number,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.category.label,
              style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: SizedBox(
                    width: 125,
                    height: 125,
                    child: Image.asset(
                      question.category.img,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            Text(
              "$number.- ${question.question}",
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
