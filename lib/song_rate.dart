
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/shadow_icon.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_song/song_core.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RateCard<T extends SongCore> extends StatefulWidget{

  static const double HEIGHT = RateButton.HEIGHT;

  final T song;
  final Function(int rate, bool selected) onTap;

  const RateCard(this.song, {this.onTap});

  @override
  State<StatefulWidget> createState() => RateCardState<T>();
}

class RateCardState<T extends SongCore> extends State<RateCard>{

  T get song => widget.song;
  Function(int rate, bool selected) get onTap => widget.onTap;

  @override
  Widget build(BuildContext context) {

    return Align(
        alignment: Alignment.topCenter,
        child: AppCard(
            padding: EdgeInsets.zero,
            radius: AppCard.BIG_RADIUS,
            elevation: AppCard.bigElevation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        child: RateButton.from(song, SongRate.TEXT_DISLIKE, SongRate.iconDislike(), SongRate.RATE_DISLIKE, onTap)
                    ),
                    Expanded(
                        child: RateButton.from(song, SongRate.TEXT_LIKE_1, SongRate.iconLike1(), SongRate.RATE_LIKE_1, onTap)
                    ),
                    Expanded(
                        child: RateButton.from(song, SongRate.TEXT_LIKE_2, SongRate.iconLike2(), SongRate.RATE_LIKE_2, onTap)
                    ),
                    Expanded(
                        child: RateButton.from(song, SongRate.TEXT_LIKE_3, SongRate.iconLike3(), SongRate.RATE_LIKE_3, onTap)
                    ),
                    Expanded(
                        child: RateButton.from(song, SongRate.TEXT_BOOKMARK, SongRate.iconBookmark(), SongRate.RATE_BOOKMARK, onTap)
                    ),
                  ],
                ),
              ],
            )
        )
    );
  }
}

class SongRate{

  static const int RATE_NULL = 0;
  static const int RATE_DISLIKE = 1;
  static const int RATE_LIKE_1 = 2;
  static const int RATE_LIKE_2 = 3;
  static const int RATE_LIKE_3 = 4;
  static const int RATE_BOOKMARK = -1;

  static const String TEXT_DISLIKE = 'Słabe';
  static const String TEXT_LIKE_1 = 'Niezłe';
  static const String TEXT_LIKE_2 = 'Świetne';
  static const String TEXT_LIKE_3 = 'Perełka';
  static const String TEXT_BOOKMARK = 'Do nauki';

  static const Color COL_DISLIKE = Colors.orange;
  static const Color COL_LIKE_1 = Colors.lightBlueAccent;
  static const Color COL_LIKE_2 = Colors.blueAccent;
  static const Color COL_LIKE_3 = Colors.deepPurple;
  static const Color COL_BOOKMARK = Colors.pinkAccent;

  static const IconData IC_DATA_NULL = MdiIcons.heartOutline;
  static const IconData IC_DATA_DISLIKE = MdiIcons.musicRestQuarter;
  static const IconData IC_DATA_LIKE_1 = MdiIcons.musicNoteQuarter;
  static const IconData IC_DATA_LIKE_2 = MdiIcons.musicNoteEighth;
  static const IconData IC_DATA_LIKE_3 = MdiIcons.musicNoteSixteenth;
  static const IconData IC_DATA_BOOKMARK = MdiIcons.school;

  static int _disabledAlpha = 128;

  static iconDislike({enabled: true, size: Dimen.ICON_SIZE}) => Icon(SongRate.IC_DATA_DISLIKE, color: SongRate.COL_DISLIKE.withAlpha(enabled?255:_disabledAlpha), size: size,);
  static iconLike1({enabled: true, size: Dimen.ICON_SIZE}) => Icon(SongRate.IC_DATA_LIKE_1, color: SongRate.COL_LIKE_1.withAlpha(enabled?255:_disabledAlpha), size: size);
  static iconLike2({enabled: true, size: Dimen.ICON_SIZE}) => Icon(SongRate.IC_DATA_LIKE_2, color: SongRate.COL_LIKE_2.withAlpha(enabled?255:_disabledAlpha), size: size);
  static iconLike3({enabled: true, size: Dimen.ICON_SIZE}) => Icon(SongRate.IC_DATA_LIKE_3, color: SongRate.COL_LIKE_3.withAlpha(enabled?255:_disabledAlpha), size: size);
  static iconBookmark({enabled: true, size: Dimen.ICON_SIZE}) => Icon(SongRate.IC_DATA_BOOKMARK, color: SongRate.COL_BOOKMARK.withAlpha(enabled?255:_disabledAlpha), size: size);

}

class RateButton extends StatelessWidget{

  static const double HEIGHT = 2*Dimen.ICON_SIZE /*CHILD*/ + Dimen.TEXT_SIZE_SMALL /*TEXT*/ + 2* Dimen.DEF_MARG /*PADDING*/;

  final String title;
  final Icon icon;
  final int rate;
  final Function(int rate, bool clicked) onTap;
  final bool selected;
  final Color background;
  final bool glow;

  const RateButton(this.title, this.icon, this.rate, this.selected, {this.background, this.glow:true, this.onTap});

  static RateButton from<T extends SongCore>(T song, String title, Icon icon, int rate, Function(int rate, bool clicked) onTap){
    return RateButton(title, icon, rate, song.rate == rate, onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {

    Widget iconChild;
    if(selected) {
      Widget shadowIconChild = Center(child: ShadowIcon(icon));
      iconChild =
          glow?
          AvatarGlow(
              child: shadowIconChild,
              endRadius: Dimen.ICON_SIZE, glowColor: defCardElevation(context),
              repeatPauseDuration: Duration(seconds: 1),
          ):shadowIconChild;
    }else
      iconChild = icon;

    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          child: iconChild,
          height: 2*Dimen.ICON_SIZE,
        ),
        Text(
            title,
            style: AppTextStyle(
                fontSize: Dimen.TEXT_SIZE_SMALL,
                color: selected?textEnab_(context):hintEnabled(context),
                fontWeight: selected?weight.bold:weight.normal,
                shadow: selected),
            textAlign: TextAlign.center
        )
      ],
    );

    return SimpleButton(
      radius: AppCard.BIG_RADIUS,
      padding: EdgeInsets.only(top: Dimen.DEF_MARG, bottom: Dimen.DEF_MARG),
      margin: EdgeInsets.zero,
      child: child,
      onTap: onTap==null?null:() => onTap(rate, selected),
    );
  }

}

class RateIcon{

  final int rate;
  final bool enabled;
  final double size;
  const RateIcon(this.rate, {this.enabled:true, this.size: Dimen.ICON_SIZE});

  static Icon build(BuildContext context, int rate, {bool enabled:true, double size: Dimen.ICON_SIZE}){
    switch(rate){
      case SongRate.RATE_NULL: return Icon(SongRate.IC_DATA_NULL, color: iconEnab_(context));
      case SongRate.RATE_DISLIKE: return SongRate.iconDislike(enabled: enabled, size: size);
      case SongRate.RATE_LIKE_1: return SongRate.iconLike1(enabled: enabled, size: size);
      case SongRate.RATE_LIKE_2: return SongRate.iconLike2(enabled: enabled, size: size);
      case SongRate.RATE_LIKE_3: return SongRate.iconLike3(enabled: enabled, size: size);
      case SongRate.RATE_BOOKMARK: return SongRate.iconBookmark(enabled: enabled, size: size);
      default: return Icon(SongRate.IC_DATA_NULL, color: iconEnab_(context));
    }
  }

}

