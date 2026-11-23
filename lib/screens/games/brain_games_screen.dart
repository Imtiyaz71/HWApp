import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BrainGamesScreen extends StatefulWidget {
  final String? userClass;
  const BrainGamesScreen({super.key, this.userClass});

  @override
  State<BrainGamesScreen> createState() => _BrainGamesScreenState();
}

class _BrainGamesScreenState extends State<BrainGamesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Brain & Knowledge Arena'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.flash_on), text: 'Speed Math'),
            Tab(icon: Icon(Icons.child_care), text: 'Kids Fun (Play/KG)'),
            Tab(icon: Icon(Icons.spellcheck), text: 'Word Puzzle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SpeedMathGame(),
          KidsPlayGame(),
          WordScrambleGame(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. SPEED MATH SPRINT
// ---------------------------------------------------------------------------
class SpeedMathGame extends StatefulWidget {
  const SpeedMathGame({super.key});

  @override
  State<SpeedMathGame> createState() => _SpeedMathGameState();
}

class _SpeedMathGameState extends State<SpeedMathGame> {
  int _score = 0;
  int _highScore = 0;
  int _streak = 0;
  int _timeLeft = 30;
  Timer? _timer;
  bool _isPlaying = false;

  late int _num1;
  late int _num2;
  late String _operator;
  late int _correctAnswer;
  late List<int> _options;

  final Random _random = Random();

  void _startGame() {
    setState(() {
      _score = 0;
      _streak = 0;
      _timeLeft = 30;
      _isPlaying = true;
    });
    _nextQuestion();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    if (_score > _highScore) {
      _highScore = _score;
    }
    setState(() => _isPlaying = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Time\'s Up!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score: $_score', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Best Streak: $_streak🔥', style: const TextStyle(fontSize: 16)),
            Text('High Score: $_highScore', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    final ops = ['+', '-', '×'];
    _operator = ops[_random.nextInt(ops.length)];
    if (_operator == '+') {
      _num1 = _random.nextInt(30) + 1;
      _num2 = _random.nextInt(30) + 1;
      _correctAnswer = _num1 + _num2;
    } else if (_operator == '-') {
      _num1 = _random.nextInt(40) + 10;
      _num2 = _random.nextInt(_num1) + 1;
      _correctAnswer = _num1 - _num2;
    } else {
      _num1 = _random.nextInt(12) + 2;
      _num2 = _random.nextInt(10) + 2;
      _correctAnswer = _num1 * _num2;
    }

    final opts = <int>{_correctAnswer};
    while (opts.length < 4) {
      final offset = _random.nextInt(11) - 5;
      final fake = _correctAnswer + (offset == 0 ? 3 : offset);
      if (fake >= 0) opts.add(fake);
    }
    _options = opts.toList()..shuffle();
  }

  void _checkAnswer(int ans) {
    if (!_isPlaying) return;
    if (ans == _correctAnswer) {
      setState(() {
        _score += 10 + (_streak * 2);
        _streak++;
      });
      _nextQuestion();
    } else {
      setState(() {
        _streak = 0;
        if (_timeLeft > 2) _timeLeft -= 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong! -2 seconds!'), duration: Duration(milliseconds: 500)),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Speed Math Sprint', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Answer as many math questions as you can in 30 seconds!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              if (_highScore > 0)
                Chip(
                  label: Text('🏆 High Score: $_highScore', style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.amber.shade100,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Challenge'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _startGame,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                avatar: const Icon(Icons.score, color: Colors.white, size: 18),
                label: Text('Score: $_score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.primary,
              ),
              Chip(
                avatar: const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                label: Text('Streak: $_streak🔥', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Chip(
                avatar: const Icon(Icons.timer, color: Colors.white, size: 18),
                label: Text('$_timeLeft s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: _timeLeft <= 5 ? Colors.red : Colors.green,
              ),
            ],
          ),
          const Spacer(),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Text(
                '$_num1 $_operator $_num2 = ?',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const Spacer(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: _options.map((opt) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onPressed: () => _checkAnswer(opt),
                child: Text('$opt', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. KIDS FUN PLAY (Play, Nursery, KG)
// ---------------------------------------------------------------------------
class KidsPlayGame extends StatefulWidget {
  const KidsPlayGame({super.key});

  @override
  State<KidsPlayGame> createState() => _KidsPlayGameState();
}

class _KidsPlayGameState extends State<KidsPlayGame> {
  final List<Map<String, dynamic>> _kidsQuestions = [
    {
      'question': 'How many 🍎 apples are there?',
      'items': '🍎 🍎 🍎',
      'correct': 3,
      'options': [2, 3, 4, 5],
    },
    {
      'question': 'Which one is a ⭐ STAR?',
      'items': '🟢  ⬛  ⭐  🔺',
      'correct': '⭐',
      'options': ['🟢', '⬛', '⭐', '🔺'],
    },
    {
      'question': 'How many 🐱 cats are there?',
      'items': '🐱 🐱',
      'correct': 2,
      'options': [1, 2, 3, 4],
    },
    {
      'question': 'Find the Bangla letter "অ" (Shoro-O)',
      'items': 'আ  ই  অ  উ',
      'correct': 'অ',
      'options': ['আ', 'ই', 'অ', 'উ'],
    },
    {
      'question': 'What color is this heart? 💙',
      'items': '💙',
      'correct': 'Blue',
      'options': ['Red', 'Green', 'Blue', 'Yellow'],
    },
  ];

  int _currentIndex = 0;
  int _stars = 0;

  void _checkAnswer(dynamic ans) {
    final current = _kidsQuestions[_currentIndex];
    if (ans == current['correct']) {
      setState(() => _stars++);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🌟 Excellent! সাবাশ! 🌟', textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉 Correct Answer!', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('You earned a Golden Star! ⭐'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = (_currentIndex + 1) % _kidsQuestions.length;
                });
              },
              child: const Text('Next Puzzle ➡️'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try again! তুমি পারবে! 😊')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _kidsQuestions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Puzzle ${_currentIndex + 1}/${_kidsQuestions.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Chip(
                backgroundColor: Colors.amber.shade100,
                label: Text('⭐ Stars: $_stars', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(q['question'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 20),
                  Text(q['items'], style: const TextStyle(fontSize: 48)),
                ],
              ),
            ),
          ),
          const Spacer(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: (q['options'] as List).map((opt) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal.shade800,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.teal.shade300, width: 2),
                  ),
                ),
                onPressed: () => _checkAnswer(opt),
                child: Text('$opt', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. WORD SCRAMBLE / VOCABULARY PUZZLE
// ---------------------------------------------------------------------------
class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({super.key});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final List<Map<String, String>> _words = [
    {'scrambled': 'SHOOLC', 'word': 'SCHOOL', 'hint': 'Where students study'},
    {'scrambled': 'AHMET', 'word': 'MATH', 'hint': 'Subject with numbers'},
    {'scrambled': 'CEHETAR', 'word': 'TEACHER', 'hint': 'Person who guides students'},
    {'scrambled': 'BKOO', 'word': 'BOOK', 'hint': 'Something you read'},
    {'scrambled': 'ENCPIL', 'word': 'PENCIL', 'hint': 'Tool for writing'},
  ];

  int _currentIndex = 0;
  String _currentGuess = '';
  int _score = 0;

  void _tapLetter(String letter) {
    setState(() => _currentGuess += letter);
  }

  void _clearGuess() {
    setState(() => _currentGuess = '');
  }

  void _checkWord() {
    final correct = _words[_currentIndex]['word']!;
    if (_currentGuess == correct) {
      setState(() {
        _score += 20;
        _currentIndex = (_currentIndex + 1) % _words.length;
        _currentGuess = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Correct Word! +20 Points!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not quite right. Try again!'), backgroundColor: Colors.red),
      );
      _clearGuess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _words[_currentIndex];
    final letters = item['scrambled']!.split('');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Word ${_currentIndex + 1}/${_words.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Chip(
                label: Text('Score: $_score', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                backgroundColor: Colors.purple.shade50,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Hint: ${item['hint']}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.shade200, width: 2),
            ),
            child: Text(
              _currentGuess.isEmpty ? 'TAP LETTERS BELOW' : _currentGuess,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: _currentGuess.isEmpty ? Colors.grey : Colors.purple.shade700,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: letters.map((l) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _tapLetter(l),
                child: Text(l, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.backspace_outlined),
                  label: const Text('Clear'),
                  onPressed: _clearGuess,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  onPressed: _checkWord,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
