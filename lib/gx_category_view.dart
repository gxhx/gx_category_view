library gx_category_view;

import 'dart:ui';
import 'package:flutter/material.dart';

class GXCategoryView extends StatefulWidget {
  // titles
  final List<String> items;
  // pageViews
  final List<Widget> itemWidgets;
  // backgroundColor
  final Color? backgroundColor;
  // container padding
  final EdgeInsetsGeometry padding;
  // container height not contain indicatorHeight
  final double height;
  // callback
  final ValueChanged<int>? onPageChanged;
  // text property

  final EdgeInsetsGeometry titlePadding;
  final Color titleColor;
  final Color selectedTitleColor;
  final double fontSize;
  final double selectedFontSize;
  final FontWeight fontWeight;
  final FontWeight selectedFontWeight;

  // indicator property
  final Color indicatorColor;
  final double indicatorHeight;
  final double indicatorWidth;
  final double indicatorRadius;

  const GXCategoryView(
      {Key? key,
      this.items = const [],
      this.itemWidgets = const [],
      this.backgroundColor,
      this.padding = const EdgeInsets.only(left: 20, right: 20),
      this.height = 40,
      this.onPageChanged,
      this.titlePadding = const EdgeInsets.only(left: 4, right: 4),
      this.titleColor = Colors.black,
      this.selectedTitleColor = Colors.black,
      this.fontSize = 16.0,
      this.selectedFontSize = 16.0,
      this.fontWeight = FontWeight.w400,
      this.selectedFontWeight = FontWeight.w500,
      this.indicatorColor = Colors.blue,
      this.indicatorHeight = 4,
      this.indicatorWidth = 30,
      this.indicatorRadius = 2})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GXCategoryViewState();
  }
}

class _GXCategoryViewState extends State<GXCategoryView> with WidgetsBindingObserver {
  _GXCategoryViewState();

  double left = 0;
  double currentItemWidth = 0;
  late List<GlobalKey>? keys;
  final GlobalKey _superViewkey = GlobalKey();
  final PageController pageController = PageController();
  final _GXCategoryController controller = _GXCategoryController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    pageController.dispose();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    keys = widget.items.map((e) => GlobalKey()).toList();
    WidgetsBinding.instance?.addPersistentFrameCallback((timeStamp) {
      _afterLayout();
    });

    // index Listener
    controller.addListener(() {
      _getPosition(controller.index ?? 0);
    });

    // scroll Listener
    scrollController.addListener(() {
      // _getPosition(controller.index ?? 0);
    });
    super.initState();
  }

  _afterLayout() {
    _getPosition(controller.index ?? 0);
  }

  //
  _doScroll() {
    final size = MediaQuery.of(context).size;
    var rightItemPosition = left +
        widget.indicatorWidth / 2 +
        currentItemWidth / 2 +
        widget.titlePadding.horizontal +
        widget.padding.horizontal;
    var leftItemPosition = left +
        widget.indicatorWidth / 2 -
        currentItemWidth / 2 -
        widget.titlePadding.horizontal -
        widget.padding.horizontal;

    if (rightItemPosition > size.width) {
      scrollController.animateTo(rightItemPosition - size.width,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
    } else if (leftItemPosition < 0) {
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
    }
  }

  _getPosition(int index) {
    //calculate position
    RenderBox renderBox = keys?[index].currentContext?.findRenderObject() as RenderBox;

    var offset = renderBox.localToGlobal(
      Offset.zero,
    );
    var width = renderBox.paintBounds.width;
    setState(() {
      left = offset.dx + (width / 2 - widget.indicatorWidth / 2);
      currentItemWidth = width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        children: [
          SingleChildScrollView(
            padding: widget.padding,
            scrollDirection: Axis.horizontal,
            primary: false,
            controller: scrollController,
            child: Row(
                key: _superViewkey,
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.items
                    .map(
                      (e) => SizedBox(
                          height: widget.height,
                          child: TextButton(
                              key: keys?[widget.items.indexOf(e)],
                              onPressed: () {
                                if (controller.index == widget.items.indexOf(e)) {
                                  return;
                                }
                                controller.jumpTo(widget.items.indexOf(e));
                                if (widget.itemWidgets.length > widget.items.indexOf(e)) {
                                  pageController.jumpToPage(widget.items.indexOf(e));
                                }
                                if (widget.onPageChanged != null) {
                                  widget.onPageChanged!(widget.items.indexOf(e));
                                }
                                _getPosition(widget.items.indexOf(e));
                                _doScroll();
                              },
                              child: Text(e),
                              style: _buttonStyle(widget.items.indexOf(e)))),
                    )
                    .toList()),
          ),
          SizedBox(
            height: widget.indicatorHeight,
            child: Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  left: left,
                  child: Container(
                    height: widget.indicatorHeight,
                    width: widget.indicatorWidth,
                    decoration: BoxDecoration(
                      color: widget.indicatorColor,
                      borderRadius: BorderRadius.circular(widget.indicatorRadius),
                    ),
                  ),
                )
              ],
            ),
          ),
          widget.itemWidgets.isEmpty
              ? Container()
              : Expanded(
                  child: PageView(
                  controller: pageController,
                  children: widget.itemWidgets,
                  onPageChanged: (index) {
                    controller.jumpTo(index);
                    if (widget.onPageChanged != null) {
                      widget.onPageChanged!(index);
                    }
                  },
                ))
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(int index) {
    double fontSize;
    Color titleColor;
    FontWeight fontWeight;

    if (controller.index == index) {
      titleColor = widget.selectedTitleColor;
      fontSize = widget.selectedFontSize;
      fontWeight = widget.selectedFontWeight;
    } else {
      titleColor = widget.titleColor;
      fontSize = widget.fontSize;
      fontWeight = widget.fontWeight;
    }

    return ButtonStyle(
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
      foregroundColor: MaterialStateProperty.all(titleColor),
      backgroundColor: MaterialStateProperty.all(widget.backgroundColor),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      elevation: MaterialStateProperty.all(0),
      padding: MaterialStateProperty.all(widget.titlePadding),
    );
  }
}

class _GXCategoryController extends ChangeNotifier {
  int? index = 0;
  _GXCategoryController({this.index = 0});

  jumpTo(int _index) {
    index = _index;
    notifyListeners();
  }
}
