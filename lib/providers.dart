
import 'package:flutter/material.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_song/song_core.dart';
import 'package:harcapp_core_song_widget/settings.dart';

import 'get_line_nums.dart';

class ChordShiftProvider extends ChangeNotifier{

  void notify() => notifyListeners();

}

class ShowChordsProvider extends ChangeNotifier{

  SongBookSettTempl settings;
  ShowChordsProvider(this.settings);

  bool get showChords => settings.showChords;
  set showChords(bool value){
    settings.showChords = value;
    notifyListeners();
  }
}

class ChordsDrawTypeProvider extends ChangeNotifier{

  SongBookSettTempl settings;
  ChordsDrawTypeProvider(this.settings);

  bool get chordsDrawType => settings.chordsDrawType;
  set chordsDrawType(bool value){
    settings.chordsDrawType = value;
    notifyListeners();
  }
}

class ChordsDrawShowProvider extends ChangeNotifier{

  SongBookSettTempl settings;
  ChordsDrawShowProvider(this.settings);

  bool get chordsDrawShow => settings.chordsDrawShow;
  set chordsDrawShow(bool value){
    settings.chordsDrawShow = value;
    notifyListeners();
  }
}

class TextSizeProvider extends ChangeNotifier{

  static const double defFontSize = 18.0;

  late double _value;
  late double _wantedValue;
  late double _screenWidth;

  double get value => _value;
  set value(double val){
    _value = val;
    notifyListeners();
  }

  double get screenWidth => _screenWidth;

  TextSizeProvider(double screenWidth, SongCore song){
    _screenWidth = screenWidth;
    _value = calculate(screenWidth, song);
    _wantedValue = _value;
  }

  bool up(double screenWidth, String text, String chords, String lineNum){
    double scaleFactor = TextSizeProvider.fits(
        screenWidth,
        text,
        chords,
        lineNum,
        _value + 0.5);

    bool changedSize = true;
    if(scaleFactor == 1){
      if(_value >= 24) changedSize = false;
      else _value += 0.5;
    }else
      changedSize = false;

    _wantedValue = _value;
    notifyListeners();
    return changedSize;
  }

  bool down(){

    bool changedSize = true;
    if(_value-0.5 >= Dimen.TEXT_SIZE_LIMIT)
      _value -= 0.5;
    else
      changedSize = false;

    _wantedValue = _value;
    notifyListeners();
    return changedSize;
  }

  double calculate(double screenWidth, SongCore song, {double initSize: defFontSize}){
    double scale = fits(screenWidth, song.text, song.chords, getLineNums(song.text), initSize);
    return scale*initSize;
  }

  double recalculate(double screenWidth, SongCore song, {double? fontSize}){
    _value = calculate(screenWidth, song, initSize: fontSize??_wantedValue);
    notifyListeners();
    return _value;
  }

  static double fits(double? screenWidth, String text, String? chords, String nums, double fontSize){

    TextStyle style = TextStyle(fontSize: fontSize, fontFamily: 'Roboto');

    var wordWrapText = TextPainter(text: TextSpan(style: style, text: text),
      textDirection: TextDirection.ltr,
    );
    wordWrapText.layout();

    late var wordWrapChords;
    if(chords!=null) {
      wordWrapChords = TextPainter(text: TextSpan(style: style, text: chords),
        textDirection: TextDirection.ltr,
      );
      wordWrapChords.layout();
    }
    var wordWrapNums = TextPainter(text: TextSpan(style: style.copyWith(fontSize: Dimen.TEXT_SIZE_TINY), text: nums),
      textDirection: TextDirection.ltr,
    );
    wordWrapNums.layout();

    double textWidth = wordWrapText.width;
    double chordsWidth = chords==null?0:wordWrapChords.width;
    double numsWidth = wordWrapNums.width;

    if(chords!=null)
      screenWidth = screenWidth! - Dimen.DEF_MARG - 4*Dimen.DEF_MARG - 2*4;
    else
      screenWidth = screenWidth! - Dimen.DEF_MARG - 2*Dimen.DEF_MARG - 2*2;

    if(screenWidth < textWidth + chordsWidth + numsWidth)
      return screenWidth/(textWidth + chordsWidth + numsWidth);
    else return 1;
  }


}

class AutoscrollProvider extends ChangeNotifier{

  bool? _isScrolling;
  late bool restart;
  late SongBookSettTempl settings;

  void Function()? onAutoscrollStart;
  void Function()? onAutoscrollEnd;

  AutoscrollProvider(
      SongBookSettTempl settings,
      {
        void Function()? onAutoscrollStart,
        void Function()? onAutoscrollEnd
      }){
    _isScrolling = false;
    restart = false;
    this.settings = settings;

    this.onAutoscrollStart = onAutoscrollStart;
    this.onAutoscrollEnd = onAutoscrollEnd;
  }

  bool? get isScrolling => _isScrolling;
  set isScrolling(bool? value){
    if(restart){
      restart = false;
      return;
    }
    _isScrolling = value;
    if(_isScrolling!) onAutoscrollStart!();
    else onAutoscrollEnd!();

    notifyListeners();
  }

  double get speed => settings.autoscrollTextSpeed;

  set speed(double value){
    settings.autoscrollTextSpeed = value;
    notifyListeners();
  }

}