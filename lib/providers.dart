
import 'package:flutter/material.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_song/song_core.dart';
import 'package:harcapp_core_song_widget/settings.dart';

import 'get_line_nums.dart';

class ShowChordsProvider extends ChangeNotifier{

  SongBookSettings settings;
  ShowChordsProvider(this.settings);

  bool get showChords => settings.showChords;
  set showChords(bool value){
    settings.showChords = value;
    notifyListeners();
  }
}

class ChordsDrawTypeProvider extends ChangeNotifier{

  SongBookSettings settings;
  ChordsDrawTypeProvider(this.settings);

  bool get chordsDrawType => settings.chordsDrawType;
  set chordsDrawType(bool value){
    settings.chordsDrawType = value;
    notifyListeners();
  }
}

class ChordsDrawPinnedProvider extends ChangeNotifier{

  SongBookSettings settings;
  ChordsDrawPinnedProvider(this.settings);

  bool get pinChordsDraw => settings.pinChordsDraw;
  set pinChordsDraw(bool value){
    settings.pinChordsDraw = value;
    notifyListeners();
  }
}

class ChordsDrawShowProvider extends ChangeNotifier{

  SongBookSettings settings;
  ChordsDrawShowProvider(this.settings);

  bool get chordsDrawShow => settings.chordsDrawShow;
  set chordsDrawShow(bool value){
    settings.chordsDrawShow = value;
    notifyListeners();
  }
}

class TextSizeProvider extends ChangeNotifier{

  static const double defFontSize = 18.0;

  double fixedScreenWidth;

  double _value;

  double get value => _value;
  set value(double val){
    _value = val;
    notifyListeners();
  }

  TextSizeProvider(double screenWidth, SongCore song){
    _value = calculate(screenWidth, song);
  }

  double calculate(double screenWidth, SongCore song){
    double initSize = defFontSize;
    double scale = fits(screenWidth, song.text, song.chords, getLineNums(song.text), initSize);
    return scale*initSize;
  }

  double recalculate(double screenWidth, SongCore song){
    _value = calculate(screenWidth, song);
    notifyListeners();
  }

  static double fits(double screenWidth, String text, String chords, String nums, double fontSize){

    TextStyle style = TextStyle(fontSize: fontSize, fontFamily: 'Roboto');

    var wordWrapText = TextPainter(text: TextSpan(style: style, text: text),
      textDirection: TextDirection.ltr,
    );
    wordWrapText.layout();

    var wordWrapChords;
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
      screenWidth = screenWidth - Dimen.DEF_MARG - 4*Dimen.DEF_MARG - 2*4;
    else
      screenWidth = screenWidth - Dimen.DEF_MARG - 2*Dimen.DEF_MARG - 2*2;

    if(screenWidth < textWidth + chordsWidth + numsWidth)
      return screenWidth/(textWidth + chordsWidth + numsWidth);
    else return 1;
  }


}