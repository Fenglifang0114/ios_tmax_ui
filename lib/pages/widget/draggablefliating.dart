import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/printer.dart';

import '../../data/offset.dart';
import '../../data/pagesize.dart';
import '../../data/text.dart';
import '../../eventbus/eventbus.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final List<Widget> children;
  final Offset initialOffset;
  final VoidCallback onPressed;
  final GlobalKey parentKey;
  final int index;

  // ignore: use_key_in_widget_constructors
  const DraggableFloatingActionButton({
    super.key,
    required this.children,
    required this.initialOffset,
    required this.onPressed,
    required this.parentKey,
    required this.index,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  late GlobalKey _key = GlobalKey();
  bool _isDragging = false;
  late Offset _offset;
  late Offset _minOffset;
  late Offset _maxOffset;
  late Offset _location;
  late Offset _originOffset;

  @override
  void initState() {
    super.initState();
    //_offset   当前位置坐标
    _offset = widget.initialOffset;
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
    eventBus.on<EventPageSize>().listen((event) {
      if (mounted) {
        setState(() {
          myPageSize = event.obj;
          WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
        });
      }
    });
    eventBus.on<EventPrinter>().listen((event) {
      if (mounted) {
        setState(() {
          myPrinter = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setBoundary(_) {
    final RenderBox parentRenderBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox renderBox =
        _key.currentContext?.findRenderObject() as RenderBox;

    try {
      final Size parentSize = parentRenderBox.size;
      final Size size = renderBox.size;

      setState(() {
        //_minOffset 原点
        // if (myPrinter.printer == 'PT566') {
        //   _minOffset = const Offset(10, 20);
        //   _originOffset = const Offset(10, 0);
        // } else {
        //   _minOffset = const Offset(0, 0);
        //   _originOffset = const Offset(0, 0);
        // }
        _minOffset = const Offset(0, 0);
        _originOffset = const Offset(0, 0);
        myOffsetData.width = size.width;
        myOffsetData.height = size.height;
        //_maxOffset X/Y轴最大坐标
        if (myPrinter.printer == 'PT566') {
          _maxOffset = Offset(parentSize.width - size.width - _originOffset.dx,
              parentSize.height - size.height - _originOffset.dy);
        } else {
          _maxOffset = Offset(parentSize.width - size.width - _originOffset.dx,
              parentSize.height - size.height - _originOffset.dy);
        }
        // eventBus.fire(EventOffset(myOffsetData));
      });
    } catch (e) {
      if (kDebugMode) {
        print('catch: $e');
      }
    }
  }

//20230330
  void updatePosition(Offset newOffset) {
    setState(() {
      _offset = newOffset;
    });
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    //pointerMoveEvent.delta.dx（y）  X/Y轴偏移量
    //newOffsetX（y） 移动后的位置坐标
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;
    // if (myPrinter.printer == 'PT566') {
    //   newOffsetY = _offset.dy + pointerMoveEvent.delta.dy + myOffsetData.height;
    // }

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  // 新增代码，更新 _keyMap，确保每个 DragabbleFloatingActionButton 的 key 唯一

  @override
  Widget build(BuildContext context) {
    // _key = GlobalKey();
    myOffsetData.x = (_offset.dx.toInt()).roundToDouble();
    myOffsetData.y = ((_offset.dy).toInt()).roundToDouble();
    myOffsetData.key = widget.key!;
    // myOffsetDataList.offsetDataList.add(myOffsetData);
    eventBus.fire(EventOffset(myOffsetData));

    return Positioned(
      //移动后的X轴坐标
      left: (_offset.dx.toInt()).roundToDouble(),
      //移动后的Y轴坐标
      top: (_offset.dy.toInt()).roundToDouble(),
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);
          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          // if (myPrinter.printer != 'PT566') {
          //   myOffsetData.height = 0;
          // }
          myOffsetData.x = (_offset.dx.toInt()).roundToDouble();
          myOffsetData.y = ((_offset.dy).toInt()).roundToDouble();
          myOffsetData.key = widget.key!;
          // myOffsetDataList.offsetDataList.add(myOffsetData);
          eventBus.fire(EventOffset(myOffsetData));
          myTextData.xPos = myOffsetData.x.toInt();
          myTextData.yPos = myOffsetData.y.toInt();
          eventBus.fire(EventText(myTextData));
          if (_isDragging) {
            setState(() {
              _isDragging = false;
            });
          } else {
            widget.onPressed();
          }
        },
        onPointerHover: (PointerHoverEvent pointerHoverEvent) {},
        child: Stack(
          key: _key,
          children: [...widget.children],
        ),
      ),
    );
  }
}






// class OffsetWithIndex {
//   final int index;
//   final Offset offset;
//   OffsetWithIndex(this.index, this.offset);
//   OffsetWithIndex copyWith({required int index, required Offset offset}) {
//     return OffsetWithIndex(
//       index,
//       offset,
//     );
//   }
// }

//---------------------------------------20230328  18:00

// class DraggableFloatingActionButton extends StatefulWidget {
//   final List<Widget> children;
//   final Offset initialOffset;
//   final VoidCallback onPressed;

//   const DraggableFloatingActionButton({
//     Key? key,
//     required this.children,
//     required this.initialOffset,
//     required this.onPressed,
//     required GlobalKey<State<StatefulWidget>> parentKey,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
// }

// class _DraggableFloatingActionButtonState
//     extends State<DraggableFloatingActionButton> {
//   final GlobalKey _key = GlobalKey();
//   bool _isDragging = false;
//   late Offset _offset;
//   late Offset _minOffset;
//   late Offset _maxOffset;

//   @override
//   void initState() {
//     super.initState();
//     //_offset   当前位置坐标
//     _offset = widget.initialOffset;
//   }

//   void _setBoundary(BuildContext context) {
//     final RenderBox parentRenderBox = context.findRenderObject() as RenderBox;

//     setState(() {
//       //_minOffset 原点
//       _minOffset = const Offset(0, 0);
//       myOffsetData.width = _key.currentContext!.size!.width;
//       myOffsetData.height = _key.currentContext!.size!.height;
//       //_maxOffset X/Y轴最大坐标
//       _maxOffset = Offset(parentRenderBox.size.width - myOffsetData.width,
//           parentRenderBox.size.height - myOffsetData.height);
//     });
//   }

//   void _updatePosition(Offset delta) {
//     //pointerMoveEvent.delta.dx（y）  X/Y轴偏移量
//     //newOffsetX（y） 移动后的位置坐标
//     double newOffsetX = _offset.dx + delta.dx;
//     double newOffsetY = _offset.dy + delta.dy;
//     if (newOffsetX < _minOffset.dx) {
//       newOffsetX = _minOffset.dx;
//     } else if (newOffsetX > _maxOffset.dx) {
//       newOffsetX = _maxOffset.dx;
//     }
//     if (newOffsetY < _minOffset.dy) {
//       newOffsetY = _minOffset.dy;
//     } else if (newOffsetY > _maxOffset.dy) {
//       newOffsetY = _maxOffset.dy;
//     }
//     setState(() {
//       _offset = Offset(newOffsetX, newOffsetY);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (_maxOffset == null ||
//             _maxOffset != Offset(constraints.maxWidth, constraints.maxHeight)) {
//           WidgetsBinding.instance
//               .addPostFrameCallback((_) => _setBoundary(context));
//         }
//         return Positioned(
//           //移动后的X轴坐标
//           left:
//               (_offset.dx.toInt() - (_offset.dx % 10).toInt()).roundToDouble(),
//           //移动后的Y轴坐标
//           top: (_offset.dy.toInt() - (_offset.dy % 10).toInt()).roundToDouble(),
//           child: SizedBox(
//             width: myOffsetData.width,
//             height: myOffsetData.height,
//             child: GestureDetector(
//               onTap: widget.onPressed,
//               onPanStart: (DragStartDetails details) {
//                 setState(() {
//                   _isDragging = true;
//                 });
//               },
//               onPanUpdate: (DragUpdateDetails details) {
//                 _updatePosition(details.delta);
//               },
//               onPanEnd: (DragEndDetails details) {
//                 myOffsetData.x =
//                     (_offset.dx.toInt() - (_offset.dx % 10).toInt())
//                         .roundToDouble();
//                 myOffsetData.y =
//                     (_offset.dy.toInt() - (_offset.dy % 10).toInt())
//                         .roundToDouble();
//                 eventBus.fire(EventOffset(myOffsetData));

//                 myTextData.xPos = myOffsetData.x.toInt();

//                 myTextData.yPos = myOffsetData.y.toInt();
//                 setState(() {
//                   _isDragging = false;
//                 });
//               },
//               child: _isDragging
//                   //控件正在被拖拽
//                   ? Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: const [
//                           BoxShadow(
//                             blurRadius: 10,
//                             color: Colors.black12,
//                           ),
//                         ],
//                       ),
//                       child: const Center(
//                         child: Icon(Icons.clear, size: 30),
//                       ),
//                     )
//                   //控件未被拖拽
//                   : Stack(
//                       children: [
//                         for (final child in widget.children)
//                           Positioned.fill(child: child),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.8),
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: const [
//                                 BoxShadow(
//                                   blurRadius: 10,
//                                   color: Colors.black12,
//                                 ),
//                               ],
//                             ),
//                             child: const Center(
//                               child: Icon(Icons.drag_handle, size: 30),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
