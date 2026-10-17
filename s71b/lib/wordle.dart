// Model jedného políčka v mriežke (jedno písmeno a jeho stav).
class Wordle {
  String letter; // samotné písmeno
  bool existsInTarget; // písmeno sa nachádza v cieľovom slove
  bool doesNotExistInTarget; // písmeno sa v cieľovom slove nenachádza

  Wordle({
    required this.letter,
    this.existsInTarget = false,
    this.doesNotExistInTarget = false,
  });
}
