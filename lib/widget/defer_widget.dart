//延迟加载，避免在应用启动时加载所有模块，而是在需要时加载模块。
//这可以提高应用的启动速度，并且可以减少应用的内存占用。

import 'dart:async';
import 'package:flutter/material.dart';

typedef LibraryLoader = Future<void> Function();
typedef DeferredWidgetBuilder = Widget Function();

/// 将子组件包装在延迟加载的模块加载器中。
///
/// 子组件被创建，并且只要创建组件的闭包保持不变，
/// 就会在状态中维护该组件的单一实例。
class DeferredWidget extends StatefulWidget {
  DeferredWidget(
    this.libraryLoader,
    this.createWidget, {
    super.key,
    Widget? placeholder,
  }) : placeholder = placeholder ?? Container();

  final LibraryLoader libraryLoader;
  final DeferredWidgetBuilder createWidget;
  final Widget placeholder;
  static final Map<LibraryLoader, Future<void>> _moduleLoaders = {};
  static final Set<LibraryLoader> _loadedModules = {};

  static Future<void> preload(LibraryLoader loader) {
    if (!_moduleLoaders.containsKey(loader)) {
      _moduleLoaders[loader] = loader().then((dynamic _) {
        _loadedModules.add(loader);
      });
    }
    return _moduleLoaders[loader]!;
  }

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  _DeferredWidgetState();

  Widget? _loadedChild;
  DeferredWidgetBuilder? _loadedCreator;

  @override
  void initState() {
    /// If module was already loaded immediately create widget instead of
    /// waiting for future or zone turn.
    if (DeferredWidget._loadedModules.contains(widget.libraryLoader)) {
      _onLibraryLoaded();
    } else {
      DeferredWidget.preload(widget.libraryLoader)
          .then((dynamic _) => _onLibraryLoaded());
    }
    super.initState();
  }

  void _onLibraryLoaded() {
    setState(() {
      _loadedCreator = widget.createWidget;
      _loadedChild = _loadedCreator!();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// If closure to create widget changed, create new instance, otherwise
    /// treat as const Widget.
    if (_loadedCreator != widget.createWidget && _loadedCreator != null) {
      _loadedCreator = widget.createWidget;
      _loadedChild = _loadedCreator!();
    }
    return _loadedChild ?? widget.placeholder;
  }
}

/// Displays a progress indicator and text description explaining that
/// the widget is a deferred component and is currently being installed.
class DeferredLoadingPlaceholder extends StatelessWidget {
  const DeferredLoadingPlaceholder({
    super.key,
    this.name = 'This widget',
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[700],
            border: Border.all(
              width: 20,
              color: Colors.grey[700]!,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$name is installing.',
                style: Theme.of(context).textTheme.headlineMedium),
            Container(height: 10),
            Text(
                '$name is a deferred component which are downloaded and installed at runtime.',
                style: Theme.of(context).textTheme.bodyLarge),
            Container(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
