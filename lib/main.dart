import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Quiz Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🚀 Welcome to Quiz Game 🚀',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NameEntryScreen()),
                );
              },
              child: Text(
                'Play',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScoreBoardScreen()),
                );
              },
              child: Text(
                'Scoreboard',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ScoreBoardScreen extends StatefulWidget {
  final String? playerName;
  final int? score;

  ScoreBoardScreen({this.playerName, this.score});

  @override
  _ScoreBoardScreenState createState() => _ScoreBoardScreenState();
}

class _ScoreBoardScreenState extends State<ScoreBoardScreen> {
  late List<Map<String, dynamic>> _scores  = [];

  @override
  void initState() {
    super.initState();
    loadScores();
    print("temp");
    print(_scores);
  }

  Future<void> loadScores() async {
    final jsonString = await rootBundle.loadString('../docs/scoreboard.json');
    final jsonMap = json.decode(jsonString);
    setState(() {
      _scores = jsonMap['scoreboard'].cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scoreboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.playerName != null
                  ? 'Congratulations, ${widget.playerName}!'
                  : 'Top Scores:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scores.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${_scores[index]['name']} - ${_scores[index]['score']}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NameEntryScreen(),
                  ),
                );
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}


class NameEntryScreen extends StatefulWidget {
  @override
  _NameEntryScreenState createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Name'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What\'s Your Name?',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String playerName = _nameController.text;
                if (playerName.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(playerName: playerName),
                    ),
                  );
                }
              },
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String playerName;

  QuizPage({required this.playerName});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
    List<Map<String, dynamic>> _quizData = [];
  int _currentIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _timerSeconds = 10;
  bool _showCorrect = false;
  bool _showWrong = false;

  @override
  void initState() {
    super.initState();
    loadQuizData();
    startTimer();
  }

  Future<void> loadQuizData() async {
    final jsonString = await rootBundle.loadString('../docs/questions.json');
    final jsonMap = json.decode(jsonString);
    setState(() {
      _quizData = jsonMap['questions'].cast<Map<String, dynamic>>();
    });
  }

  /*
  void checkAnswer(String selectedAnswer) {
    if (_quizData[_currentIndex]['correct_answer'] == selectedAnswer) {
      setState(() {
        _score++;
      });
    }
    moveToNextQuestion();
  }*/

int? _selectedOptionIndex;

void checkAnswer(String selectedAnswer) {
  bool isCorrect = (_quizData[_currentIndex]['correct_answer'] == selectedAnswer);

  setState(() {
    _selectedOptionIndex = _quizData[_currentIndex]['options'].keys.toList().indexOf(selectedAnswer);
    _score += isCorrect ? 1 : 0;
  });

  Future.delayed(Duration(seconds: 1), () {
    setState(() {
      _selectedOptionIndex = null;
      moveToNextQuestion();
    });
  });
  resetTimer();
}



  

  void moveToNextQuestion() {
    setState(() {
      if (_currentIndex < _quizData.length - 1) {
        _currentIndex++;
      } else {
        // Quiz ends, show the result
        showQuizResult();
      }
    });
    _timer?.cancel(); // Cancel timer when moving to the next question
    _timerSeconds = 10; // Reset timer for the next question
    startTimer(); // Start timer for the next question
  }

void showQuizResult() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ScoreBoardScreen(
        playerName: widget.playerName,
        score: _score,
      ),
    ),
  );
}

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          moveToNextQuestion(); 
        }
      });
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _timerSeconds = 10;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Game'),
        elevation: 0,
      ),
      body: _quizData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Score: $_score/${_quizData.length}',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      _quizData[_currentIndex]['question'],
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    '$_timerSeconds',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 2.5, // Adjust this value as needed
                    children: (_quizData[_currentIndex]['options'] as Map<String, dynamic>)
                    .entries
                    .map((option) {
                      final optionKey = option.key;
                      final isCorrect = _quizData[_currentIndex]['correct_answer'] == optionKey;
                      final isSelected = _selectedOptionIndex != null && _selectedOptionIndex == _quizData[_currentIndex]['options'].keys.toList().indexOf(optionKey);
                      Color buttonColor;
                      if (isSelected) {
                        print("yes");
                        if(isCorrect) {
                          print("this should occur");
                          buttonColor = Colors.green.withOpacity(0.7);
                        } else {
                          buttonColor = Colors.red.withOpacity(0.7);
                        }
                      } else {
                        buttonColor = Colors.transparent;
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_showCorrect && !_showWrong) {
                              checkAnswer(optionKey);
                              print("$isCorrect value");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          child: Text(option.value),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }

}

  /*

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Game'),
        elevation: 0, // Removed app bar shadow
      ),
      body: _quizData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Updated Score display
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Score: $_score/${_quizData.length}',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple, // Adjusted text color
                      ),
                    ),
                  ),
                  // Updated Question display
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      _quizData[_currentIndex]['question'],
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Adjusted text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Updated Timer display
                  Text(
                    '$_timerSeconds',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange, // Adjusted text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  // Updated Options display with animations and styles
                  ...(_quizData[_currentIndex]['options'] as Map<String, dynamic>)
                      .entries
                      .map((option) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: (_showCorrect &&
                                  _quizData[_currentIndex]['correct_answer'] ==
                                      option.key)
                              ? Colors.green.withOpacity(0.7)
                              : (_showWrong &&
                                      _quizData[_currentIndex]
                                              ['correct_answer'] !=
                                          option.key)
                                  ? Colors.red.withOpacity(0.7)
                                  : Colors.transparent,
                          border: Border.all(
                            color: Colors.deepPurple, // Adjusted border color
                            width: 2.0,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_showCorrect && !_showWrong) {
                              checkAnswer(option.key);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, // Transparent button background
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87, // Adjusted text color
                            ),
                          ),
                          child: Text(option.value),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}*/
