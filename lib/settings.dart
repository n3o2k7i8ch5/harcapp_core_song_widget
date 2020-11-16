abstract class SongBookSettings{

  bool get alwaysOnScreen;
  set alwaysOnScreen(bool value);

  bool get scrollText => false;
  set scrollText(bool value) => null;

  bool get autoscrollText => false;
  set autoscrollText(bool value) => null;

  double get autoscrollTextSpeed => 0;
  set autoscrollTextSpeed(double value) => null;

  bool get showChords => true;
  set showChords(bool value) => null;

  bool get chordsDrawShow => true;
  set chordsDrawShow(bool value) => null;

  bool get pinChordsDraw => false;
  set pinChordsDraw(bool value) => null;

  bool get chordsDrawType => true;
  set chordsDrawType(bool value) => null;

}