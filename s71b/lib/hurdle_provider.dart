import 'dart:math';

import 'package:english_words/english_words.dart' as words;
import 'package:flutter/foundation.dart';

import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  final random = Random.secure();

  // Všetky slová s dĺžkou 5 znakov.
  List<String> totalWords = [];

  // Písmená aktuálneho riadku.
  final List<String> rowInputs = [];

  // Písmená, ktoré nie sú v cieľovom slove (červené klávesy).
  final List<String> excludedLetters = [];

  // Herný panel: 6 riadkov x 5 písmen = 30 políčok.
  List<Wordle> hurdleBoard = [];

  String targetWord = '';

  int count = 0; // počet písmen v aktuálnom riadku
  int index = 0; // pozícia v hernom paneli
  final int lettersPerRow = 5;

  final int totalAttempts = 6;
  int attempts = 0;
  bool wins = false;

  void init() {
    totalWords =
        words.all.where((element) => element.length == lettersPerRow).toList();
    generateBoard();
    generateRandomWord();
  }

  void generateBoard() {
    hurdleBoard = List.generate(
      totalAttempts * lettersPerRow,
      (index) => Wordle(letter: ''),
    );
  }

  void generateRandomWord() {
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
  }

  bool get isAValidWord =>
      totalWords.contains(rowInputs.join('').toLowerCase());

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool get noAttemptsLeft => attempts >= totalAttempts;

  bool get gameOver => wins || noAttemptsLeft;

  void inputLetter(String letter) {
    if (gameOver) return;
    if (count < lettersPerRow) {
      rowInputs.add(letter);
      hurdleBoard[index] = Wordle(letter: letter);
      count++;
      index++;
      notifyListeners();
    }
  }

  void deleteLetter() {
    if (gameOver) return;
    if (rowInputs.isNotEmpty) {
      rowInputs.removeAt(rowInputs.length - 1);
    }
    if (count > 0) {
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
    }
    notifyListeners();
  }

  void checkAnswer() {
    final input = rowInputs.join('');
    _markLettersOnBoard();
    if (targetWord == input) {
      wins = true;
    } else {
      attempts++;
      if (attempts < totalAttempts) {
        _goToNextRow();
      }
    }
    notifyListeners();
  }

  // Označí písmená iba v práve odoslanom riadku.
  void _markLettersOnBoard() {
    for (int i = index - lettersPerRow; i < index; i++) {
      final cell = hurdleBoard[i];
      if (cell.letter.isNotEmpty && targetWord.contains(cell.letter)) {
        cell.existsInTarget = true;
      } else if (cell.letter.isNotEmpty) {
        cell.doesNotExistInTarget = true;
        if (!excludedLetters.contains(cell.letter)) {
          excludedLetters.add(cell.letter);
        }
      }
    }
  }

  void _goToNextRow() {
    count = 0;
    rowInputs.clear();
  }

  void reset() {
    count = 0;
    index = 0;
    rowInputs.clear();
    hurdleBoard.clear();
    excludedLetters.clear();
    attempts = 0;
    wins = false;
    targetWord = '';
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }
}
