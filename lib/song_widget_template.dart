import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_classes/common.dart';
import 'package:harcapp_core/comm_widgets/animated_child_slider.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/app_button.dart';
import 'package:harcapp_core/comm_widgets/chord_draw_bar.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_song/song_core.dart';
import 'package:harcapp_core_song_widget/providers.dart';
import 'package:harcapp_core_song_widget/settings.dart';
import 'package:harcapp_core_song_widget/song_rate.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'get_line_nums.dart';

class SongAutoScrollController extends StatelessWidget{

  final SongBookSettTempl settings;
  final void Function(BuildContext context)? onAutoscrollStart;
  final void Function(BuildContext context)? onAutoscrollEnd;
  final Widget Function(BuildContext context)? builder;

  const SongAutoScrollController(this.settings, {this.onAutoscrollStart, this.onAutoscrollEnd, this.builder});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AutoscrollProvider(
          settings,
          onAutoscrollStart: () => onAutoscrollStart==null?null:onAutoscrollStart!(context),
          onAutoscrollEnd: () => onAutoscrollEnd==null?null:onAutoscrollEnd!(context)
      ),
      builder: (context, child) => builder!(context),
    );
  }

}

class SongWidgetTemplate<T extends SongCore> extends StatelessWidget{

  static const IconData ICON_SEND_SONG = MdiIcons.sendCircleOutline;
  static const IconData ICON_SHARE_SONG = MdiIcons.shareVariant;

  final T song;
  final SongBookSettTempl settings;
  final double? screenWidth;

  final ValueNotifier? pageNotifier;
  final int index;

  final double topScreenPadding;

  final bool initDrawChordTypeGuitar;

  final void Function(ScrollNotification scrollInfo)? onScroll;

  final void Function()? onTitleTap;
  final void Function(String)? onAuthorTap;
  final void Function(String)? onPerformerTap;
  final void Function(String)? onComposerTap;
  final void Function(String tag)? onTagTap;

  final void Function(double position)? onYTLinkTap;
  final void Function()? onYTLinkLongPress;

  final void Function(BuildContext context, bool changedSize)? onMinusTap;
  final void Function(BuildContext context, bool changedSize)? onPlusTap;

  final void Function()? onAlbumsTap;

  final void Function(double position)? onRateTap;

  final void Function()? onDeleteTap;
  final void Function()? onDeleteLongPress;

  final void Function()? onReportTap;

  final void Function(TextSizeProvider)? onEditTap;

  final void Function()? onSendSongTap;

  final void Function()? onShareTap;

  final void Function()? onCopyTap;

  final void Function(bool? isTypeGuitar)? onChordsTypeChanged;

  final void Function(TextSizeProvider provider)? onChordsTap;
  final void Function(TextSizeProvider provider)? onChordsLongPress;

  final Widget Function(BuildContext, ScrollController?)? header;
  final Widget Function(BuildContext, ScrollController?)? footer;

  final ScrollController? scrollController;
  final Color? accentColor;

  const SongWidgetTemplate(
      this.song,
      this.settings,
      {
        this.screenWidth,
        this.pageNotifier,
        this.index = -1,

        this.topScreenPadding: 0,

        this.initDrawChordTypeGuitar = true,

        this.onScroll,

        this.onTitleTap,
        this.onAuthorTap,
        this.onPerformerTap,
        this.onComposerTap,
        this.onTagTap,

        this.onYTLinkTap,
        this.onYTLinkLongPress,

        this.onMinusTap,
        this.onPlusTap,

        this.onAlbumsTap,

        this.onRateTap,

        this.onDeleteTap,
        this.onDeleteLongPress,

        this.onReportTap,

        this.onEditTap,

        this.onSendSongTap,

        this.onShareTap,

        this.onCopyTap,

        this.onChordsTypeChanged,

        this.onChordsTap,
        this.onChordsLongPress,

        this.header,
        this.footer,

        this.scrollController,
        this.accentColor,
        Key? key
      }):super(key: key);

  bool get showChords => settings.showChords && song.hasChords;

  @override
  Widget build(BuildContext context) {

    double _screenWidth = screenWidth??MediaQuery.of(context).size.width;

    GlobalKey contentCardsKey = GlobalKey();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TextSizeProvider(_screenWidth, song)),
        ChangeNotifierProvider(create: (context) => ChordShiftProvider()),
      ],
      builder: (context, child) => Stack(
        children: [

          NotificationListener<ScrollNotification>(
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [

                SliverList(
                  delegate: SliverChildListDelegate([

                    if(song.isOwn)
                      Padding(
                        padding: EdgeInsets.all(Dimen.DEF_MARG),
                        child: Text(
                          'Piosenka nieoficjalna',
                          style: AppTextStyle(
                              color: accentColor??accent_(context),
                              fontWeight: weight.halfBold
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    if(header!=null) header!(context, scrollController),

                    TitleCard<T>(this),

                  ]),
                ),

                Consumer3<ShowChordsProvider, ChordsDrawShowProvider, ChordsDrawTypeProvider>(
                  builder: (context, prov1, chordsDrawShowProv, prov3, child) => showChords&&chordsDrawShowProv.chordsDrawShow?SliverPersistentHeader(
                    delegate: _SliverPersistentHeaderDelegate(
                        child: ChordsBarWidget(this),
                        height: ChordWidget.height(settings.chordsDrawType?6:4) + 2.0
                    ),
                    floating: true,
                    pinned: true,
                  ):SliverList(delegate: SliverChildListDelegate([])),
                ),

                SliverList(
                  delegate: SliverChildListDelegate([

                    ButtonWidget<T>(this, contentCardsKey),

                    ContentWidget<T>(this, scrollController, globalKey: contentCardsKey),

                    if(song.releaseDate != null)
                      Padding(
                        padding: EdgeInsets.only(top: 2*Dimen.DEF_MARG, bottom: 2*Dimen.DEF_MARG, right: Dimen.DEF_MARG),
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            Icon(MdiIcons.draw, color: hintEnab_(context), size: Dimen.TEXT_SIZE_NORMAL + 2),
                            SizedBox(width: 6.0),
                            Text(
                                dateToString(song.releaseDate!, showMonth: song.showRelDateMonth, showDay: song.showRelDateMonth && song.showRelDateDay),
                                style: AppTextStyle(color: hintEnab_(context), fontWeight: weight.halfBold)),
                          ],
                        ),
                      ),

                    if(footer!=null) footer!(context, scrollController),

                    if(song.addPers.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(Dimen.DEF_MARG),
                        child: Row(
                          children: [

                            Icon(MdiIcons.accountEdit, size: Dimen.TEXT_SIZE_SMALL+2, color: hintEnab_(context)),

                            SizedBox(width: Dimen.DEF_MARG),

                            Text(
                                song.addPersString,
                                style: AppTextStyle(color: hintEnab_(context), fontSize: Dimen.TEXT_SIZE_TINY, fontWeight: weight.halfBold)
                            ),

                          ],
                        )
                      ),
                  ]),
                ),

              ],
            ),
            onNotification: (ScrollNotification scrollInfo) {
              if(onScroll != null) onScroll!(scrollInfo);
              return true;
            },
          ),

        ],
      ),
    );

  }

  static void _startAutoscroll(BuildContext context, ScrollController? scrollController, {bool restart: false})async{

    if(scrollController == null){
      debugPrint('No scrollController attached.');
      return;
    }

    SongBookSettTempl settings = Provider.of<AutoscrollProvider>(context, listen: false).settings;

    double scrollLeft = scrollController.position.maxScrollExtent - scrollController.offset;
    double duration = scrollLeft*(1.1-settings.autoscrollTextSpeed)*500;

    if(restart)
      Provider.of<AutoscrollProvider>(context, listen: false).restart = true;
    else
      Provider.of<AutoscrollProvider>(context, listen: false).isScrolling = true;

    await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: duration.round()),
        curve: Curves.linear);

    Provider.of<AutoscrollProvider>(context, listen: false).isScrolling = false;
  }

}

class TitleCard<T extends SongCore> extends StatelessWidget{

  final SongWidgetTemplate<T> parent;
  const TitleCard(this.parent);

  T get song => parent.song;
  ValueNotifier? get pageNotifier => parent.pageNotifier;
  int get index => parent.index;

  @override
  Widget build(BuildContext context) {

    Widget widgetTitle = SimpleButton(
      radius: AppCard.BIG_RADIUS,
      child: AutoSizeText(
        song.title,
        style: AppTextStyle(fontSize: 24.0, color: textEnab_(context), fontWeight: weight.bold),
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
      padding: EdgeInsets.all(Dimen.ICON_MARG),
      margin: EdgeInsets.zero,
      onTap: parent.onTitleTap,
    );

    Widget widgetAuthor = Row(
        mainAxisSize: MainAxisSize.min,
        children:[

          SizedBox(width: Dimen.DEF_MARG, height: Dimen.TEXT_SIZE_SMALL + 3*Dimen.DEF_MARG),

          Text(
            'Autor sł.: ',
            style: AppTextStyle(
              fontSize: Dimen.TEXT_SIZE_SMALL,
              color: hintEnab_(context),
            ),
            textAlign: TextAlign.left,
          ),
          if(song.authors.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: song.authors.map((author) => ContribPersonWidget(
                      author,
                      onTap: () => parent.onAuthorTap?.call(author),
                    )).toList(),
                  )
              ),
            )
        ]
    );

    Widget widgetComposer = Row(
      mainAxisSize: MainAxisSize.min,
      children:[

        SizedBox(width: Dimen.DEF_MARG, height: Dimen.TEXT_SIZE_SMALL + 3*Dimen.DEF_MARG),

        Text(
          'Kompoz.: ',
          style: AppTextStyle(
            fontSize: Dimen.TEXT_SIZE_SMALL,
            color: hintEnab_(context),
          ),
          textAlign: TextAlign.left,
        ),

        if(song.composers.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: song.composers.map((composer) => ContribPersonWidget(
                  composer,
                  onTap: () => parent.onComposerTap?.call(composer),
                )).toList(),
              )
            ),
          )
      ]
    );

    Widget widgetPerformer = Row(
        mainAxisSize: MainAxisSize.min,
        children:[

          SizedBox(width: Dimen.DEF_MARG, height: Dimen.TEXT_SIZE_SMALL + 3*Dimen.DEF_MARG),

          Text(
            'Wykona.: ',
            style: AppTextStyle(
              fontSize: Dimen.TEXT_SIZE_SMALL,
              color: hintEnab_(context),
            ),
            textAlign: TextAlign.left,
          ),

          if(song.performers.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: song.performers.map((performer) => ContribPersonWidget(
                          performer,
                          onTap: () => parent.onPerformerTap?.call(performer),
                        )).toList(),
                  )
              ),
            )
        ]
    );

    Widget widgetTags = Container(
        height: Dimen.TEXT_SIZE_SMALL + 3*Dimen.DEF_MARG,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: song.tags.length,
          itemBuilder: (BuildContext context, int index) => SimpleButton(
            padding: EdgeInsets.all(Dimen.DEF_MARG),
            radius: AppCard.BIG_RADIUS,
            child: Text(
              song.tags[index],
              style: AppTextStyle(fontSize: Dimen.TEXT_SIZE_SMALL, color: textEnab_(context), fontWeight: weight.halfBold),
            ),
            onTap: parent.onTagTap==null?null:() => parent.onTagTap!(song.tags[index]),
          ),
        )
    );

    Widget appCard = AppCard(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.all(Dimen.DEF_MARG),
        elevation: AppCard.bigElevation,
        radius: AppCard.BIG_RADIUS,
        child:

        Stack(
          children: <Widget>[

            Padding(
              padding: EdgeInsets.all(Dimen.ICON_MARG - Dimen.DEF_MARG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  widgetTitle,
                  
                  widgetAuthor,

                  widgetComposer,

                  widgetPerformer,

                  widgetTags,

                ],
              ),
            ),
          ],
        )


    );

    if(pageNotifier == null) return appCard;
    else return AnimatedBuilder(
        animation: pageNotifier!,
        builder: (context, _) => Transform.translate(
            offset: Offset(-MediaQuery.of(context).size.width/3*(pageNotifier!.value - index), 0),
            child: appCard
        ),
      );
  }

}

class ContribPersonWidget extends StatelessWidget{

  final String text;
  final void Function()? onTap;

  const ContribPersonWidget(this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return SimpleButton(
      padding: EdgeInsets.all(Dimen.DEF_MARG),
      radius: AppCard.BIG_RADIUS,
      child: Text(
        text,
        style: AppTextStyle(
          fontWeight: weight.halfBold,
          fontSize: Dimen.TEXT_SIZE_SMALL,
          color: textEnab_(context),
        ),
        textAlign: TextAlign.left,
      ),
      onTap: onTap,
    );
  }

}

class ButtonWidget<T extends SongCore> extends StatefulWidget{

  final SongWidgetTemplate<T> fragmentState;
  final GlobalKey contentCardsKey;
  const ButtonWidget(this.fragmentState, this.contentCardsKey);

  @override
  State<StatefulWidget> createState() => ButtonWidgetState<T>();

}

class ButtonWidgetState<T extends SongCore> extends State<ButtonWidget>{

  SongWidgetTemplate get fragmentState => widget.fragmentState;
  GlobalKey get contentCardsKey => widget.contentCardsKey;

  late bool showTop;

  @override
  void initState() {
    showTop = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: Dimen.ICON_FOOTPRINT,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.dotsHorizontal, color: iconEnab_(context)),
            onPressed: () => setState(() => showTop = !showTop),
          ),

          Expanded(
            child: AnimatedChildSlider(
              direction: Axis.vertical,
              duration: Duration(milliseconds: 150),
              alignment: Alignment.centerRight,
              isCenter: false,
              index: showTop?0:1,
              children: <Widget>[
                TopWidget<T>(fragmentState as SongWidgetTemplate<T>, contentCardsKey),
                BottomWidget<T>(fragmentState as SongWidgetTemplate<T>)
              ],
            ),
          )

        ],
      ),
    );
  }

}

class TopWidget<T extends SongCore> extends StatelessWidget{

  final SongWidgetTemplate<T> parent;
  final GlobalKey contentCardsKey;

  T get song => parent.song;

  double get topScreenPadding => parent.topScreenPadding;

  const TopWidget(this.parent, this.contentCardsKey);


  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      reverse: true,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [

          if(song.youtubeLink != null && song.youtubeLink!.length!=0)
            AppButton(
                icon: Icon(
                    MdiIcons.playOutline,
                    color: iconEnab_(context)
                ),
                onLongPress: parent.onYTLinkLongPress,
                onTap: parent.onYTLinkTap==null?null:(){
                  final RenderBox renderBox = contentCardsKey.currentContext!.findRenderObject() as RenderBox;
                  final position = renderBox.localToGlobal(Offset.zero).dy;// - parent.widget.topScreenPadding;
                  parent.onYTLinkTap!(position);
                }
            ),

          IconButton(icon: Icon(MdiIcons.minusCircleOutline, color: iconEnab_(context)),
              onPressed: parent.onMinusTap==null?null:(){

                TextSizeProvider prov = Provider.of<TextSizeProvider>(context, listen: false);

                bool changedSize = true;
                if(prov.value-0.5 >= Dimen.TEXT_SIZE_LIMIT)
                  prov.value -= 0.5;
                else
                  changedSize = false;

                parent.onMinusTap!(context, changedSize);

              }),
          IconButton(icon: Icon(MdiIcons.plusCircleOutline, color: iconEnab_(context)),
              onPressed: parent.onPlusTap==null?null:(){

                TextSizeProvider prov = Provider.of<TextSizeProvider>(context, listen: false);

                double scaleFactor = TextSizeProvider.fits(
                    prov.screenWidth,
                    song.text,
                    parent.showChords?song.chords:null,
                    getLineNums(song.text),
                    prov.value + 0.5);

                bool changedSize = true;
                if(scaleFactor == 1){
                  if(prov.value >= 24) changedSize = false;
                  else prov.value += 0.5;
                }else
                  changedSize = false;

                parent.onPlusTap!(context, changedSize);
              }
          ),

          IconButton(
            icon: Icon(MdiIcons.bookmarkCheckOutline, color: iconEnab_(context)),
            onPressed: parent.onAlbumsTap,
          ),

          IconButton(
              icon: RateIcon.build(context, song.rate),
              onPressed: parent.onRateTap==null?null:
                  (){
                final RenderBox renderBox = contentCardsKey.currentContext!.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero).dy;// - parent.widget.topScreenPadding;
                parent.onRateTap!(position);
              }
          )
        ],
      ),
    );
  }

}

class BottomWidget<T extends SongCore> extends StatelessWidget{

  final SongWidgetTemplate<T> parent;
  const BottomWidget(this.parent);

  T get song => parent.song;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      reverse: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          if(song.isOwn)
            AppButton(
                icon: Icon(MdiIcons.trashCanOutline, color: iconEnab_(context)),
                onTap: parent.onDeleteTap!,
                onLongPress: parent.onDeleteLongPress),
          if(!song.isOwn)
            IconButton(icon: Icon(MdiIcons.alertOutline, color: iconEnab_(context)),
                onPressed: parent.onReportTap),
          IconButton(
              icon: Icon(MdiIcons.pencilOutline, color: iconEnab_(context)),
              onPressed: parent.onEditTap==null?null:
                  () => parent.onEditTap!(Provider.of<TextSizeProvider>(context, listen: false))
          ),

          IconButton(
              icon: Icon(SongWidgetTemplate.ICON_SHARE_SONG, color: iconEnab_(context)),
              onPressed: parent.onShareTap
          ),

          if(song.isOwn)
            IconButton(
                icon: Icon(
                    SongWidgetTemplate.ICON_SEND_SONG,
                    color: iconEnab_(context)),
                onPressed: parent.onSendSongTap
            ),

          IconButton(icon: Icon(MdiIcons.contentCopy, color: iconEnab_(context)),
              onPressed: parent.onCopyTap
          ),

        ],
      ),
    );
  }
}

class ContentWidget<T extends SongCore> extends StatelessWidget{

  final SongWidgetTemplate<T> parent;
  final ScrollController? scrollController;

  T get song => parent.song;
  SongBookSettTempl get settings => parent.settings;

  String get text => song.text;
  String get chords => song.chords;
  String get lineNum => getLineNums(song.text);//parent.lineNum;

  static const double lineSpacing = 1.2;

  const ContentWidget(this.parent, this.scrollController, {GlobalKey? globalKey}):super(key: globalKey);

  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {

          // To po to, żeby tekst został zresetowany po zmianie orientacji.
          //if (parent.oldOrientation != MediaQuery.of(context).orientation)
            //parent.oldOrientation = orientation;

          //return Container(height: 600, width: double.infinity, color: Colors.blue);

          return Consumer<TextSizeProvider>(
            builder: (context, prov, child) => Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[

                Expanded(
                  child: SimpleButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: prov.value, //initial font size
                                  color: textEnab_(context),
                                  height: lineSpacing,
                                ),
                              )
                          ),
                          Text(
                            lineNum,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: prov.value<Dimen.TEXT_SIZE_TINY?
                                prov.value:
                                Dimen.TEXT_SIZE_TINY,//initial font size
                                color: hintEnab_(context),
                                height: prov.value<Dimen.TEXT_SIZE_TINY?
                                lineSpacing:
                                lineSpacing*(prov.value/ Dimen.TEXT_SIZE_TINY)
                            ),
                          ),
                        ],
                      ),
                      onTap: (){
                        if(settings.scrollText) {

                          if(scrollController == null){
                            debugPrint('No scrollController attached.');
                            return;
                          }

                          double scrollDefDelta = MediaQuery.of(context).size.height / 2;
                          double scrollDelta = min(
                              scrollDefDelta,
                              scrollController!.position.maxScrollExtent - scrollController!.offset
                          );

                          int scrollDuration = (2000*scrollDelta/scrollDefDelta).round();

                          if(scrollDuration > 0)
                            scrollController!.animateTo(
                                scrollController!.offset + scrollDelta,
                                duration: Duration(milliseconds: scrollDuration),
                                curve: Curves.ease
                            );
                        }
                      },
                      onLongPress: () => SongWidgetTemplate._startAutoscroll(context, scrollController)
                  ),
                ),

                Consumer<ShowChordsProvider>(
                    builder: (context, showChordsProv, child){

                      if(!showChordsProv.showChords)
                        return Container();

                      return SimpleButton(
                          child: Text(
                            chords,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: prov.value, //initial font size
                              color: textEnab_(context),
                              height: lineSpacing,
                            ),
                          ),
                          onTap: parent.onChordsTap==null?null:(){
                            parent.onChordsTap!(prov);
                            Provider.of<ChordShiftProvider>(context, listen: false).notify();
                          },
                          onLongPress: parent.onChordsLongPress==null?null:(){
                            parent.onChordsLongPress!(prov);
                            Provider.of<ChordShiftProvider>(context, listen: false).notify();
                          }
                      );

                    }
                )

              ],
            ),
          );
        });

  }

}

class ChordsBarWidget<T extends SongCore> extends StatelessWidget{

  final SongWidgetTemplate<T> parent;

  const ChordsBarWidget(this.parent);

  T get song => parent.song;
  SongBookSettTempl get settings => parent.settings;

  @override
  Widget build(BuildContext context) {

    return Consumer<ChordShiftProvider>(
      builder: (context, prov, child) => Column(
        children: [

          ChordDrawBar(
            song.chords,
            onTap: (chord, typeGuitar){

              if(parent.onChordsTypeChanged != null)
                parent.onChordsTypeChanged!(typeGuitar);
            },
            elevation: 0,
            chordColor: iconEnab_(context),
            initTypeGuitar: parent.initDrawChordTypeGuitar,
            //chordBackground: Colors.transparent,
            //background: Colors.transparent,
          ),

        ],
      )
    );

  }
}



class AutoScrollSpeedWidget<T extends SongCore> extends StatelessWidget{

  final Color? accentColor;
  final Color? accentIconColor;
  final ScrollController Function()? scrollController;

  const AutoScrollSpeedWidget({this.accentColor, this.accentIconColor, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<AutoscrollProvider>(
        builder: (context, prov, child) => prov.isScrolling!?AppCard(
          elevation: AppCard.bigElevation,
          radius: AppCard.BIG_RADIUS,
          child: Row(
            children: [

              Padding(
                padding: EdgeInsets.all(Dimen.ICON_MARG),
                child: Icon(MdiIcons.speedometer),
              ),

              Expanded(
                child: SliderTheme(
                  child: Slider(
                    value: prov.speed,
                    divisions: 5,
                    activeColor: accentColor??accent_(context),
                    inactiveColor: hintEnab_(context),
                    onChanged: (value){
                      prov.speed = value;
                      SongWidgetTemplate._startAutoscroll(context, scrollController!(), restart: true);
                    },
                    label: 'Szybkość przewijania',
                  ),
                  data: SliderTheme.of(context).copyWith(
                      valueIndicatorTextStyle: AppTextStyle(color: accentIconColor??accentIcon_(context), fontWeight: weight.halfBold),
                      valueIndicatorColor: accentColor??accent_(context)
                  ),
                ),
              ),

            ],
          ),
        ):Container()
    );

  }

}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate{

  final Widget? child;
  final height;

  const _SliverPersistentHeaderDelegate({this.child, this.height});

  @override
  double get maxExtent => height;// + Dimen.DEF_MARG.toInt();

  @override
  double get minExtent => height;// + Dimen.DEF_MARG.toInt();

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

    bool overlaps = shrinkOffset!=0 || overlapsContent;

    return Material(
      animationDuration: Duration.zero,
      color: overlaps?background_(context):Colors.transparent,
      child: child,
      elevation: overlaps?AppCard.bigElevation:0,
    );
  }

}
