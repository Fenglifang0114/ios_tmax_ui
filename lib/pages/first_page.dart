//首页   测试首页
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  MainLayoutState createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  final GlobalKey<NavigatorState> _contentNavigatorKey = GlobalKey();
  String _selectedNavRoute = '/page1';
  bool _showNavigation = true;

  void _navigateContent(String routeName) {
    setState(() {
      _selectedNavRoute = routeName;
      _showNavigation = !routeName.startsWith('/settings'); // 控制导航栏显示
    });

    if (routeName == '/settings') {
      _contentNavigatorKey.currentState?.pushNamed(routeName);
    } else {
      _contentNavigatorKey.currentState?.pushReplacementNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 动态显示的左侧导航栏
          if (_showNavigation)
            Container(
              width: 200,
              color: Colors.grey[200],
              child: ListView(
                children: [
                  _NavButton(
                    route: '/page1',
                    label: 'Page 1',
                    selected: _selectedNavRoute,
                    onTap: () => _navigateContent('/page1'),
                  ),
                  _NavButton(
                    route: '/page2',
                    label: 'Page 2',
                    selected: _selectedNavRoute,
                    onTap: () => _navigateContent('/page2'),
                  ),
                  _NavButton(
                    route: '/page3',
                    label: 'Page 3',
                    selected: _selectedNavRoute,
                    onTap: () => _navigateContent('/page3'),
                  ),
                  _NavButton(
                    route: '/page4',
                    label: 'Page 4',
                    selected: _selectedNavRoute,
                    onTap: () => _navigateContent('/page4'),
                  ),
                ],
              ),
            ),

          // 右侧主区域
          Expanded(
            child: Column(
              children: [
                // 顶部设置栏（始终显示）
                Container(
                  height: 60,
                  color: Colors.blueGrey[100],
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () => _navigateContent('/settings'),
                      ),
                      Text('Settings Bar'),
                    ],
                  ),
                ),

                // 内容区域导航器
                Expanded(
                  child: Navigator(
                    key: _contentNavigatorKey,
                    initialRoute: '/page1',
                    onGenerateRoute: (settings) {
                      final pageContent = _buildPageContent(settings.name);
                      return MaterialPageRoute(
                        builder: (context) => pageContent,
                        settings: settings,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(String? route) {
    switch (route) {
      case '/settings':
        return SettingsPage(onNavigate: _navigateContent);
      case '/page1':
        return ContentPage1(title: 'Page 1 Content');
      case '/page2':
        return ContentPage2(title: 'Page 2 Content');
      case '/page3':
        return ContentPage3(title: 'Page 3 Content');
      case '/page4':
        return ContentPage4(title: 'Page 4 Content');
      case '/page5':
        return ContentPage5(title: 'Page 5 Content');
      case '/page6':
        return ContentPage6(title: 'Page 6 Content');
      case '/page7':
        return ContentPage7(title: 'Page 7 Content');
      default:
        return ContentPage(title: 'Default Content');
    }
  }
}

class _NavButton extends StatelessWidget {
  final String route;
  final String label;
  final String selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.route,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      selected: selected == route,
      selectedTileColor: Colors.blue[100],
      onTap: onTap,
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function(String) onNavigate;

  const SettingsPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Settings Page', style: TextStyle(fontSize: 20)),
        _SettingsButton(label: 'Page 5', onPressed: () => onNavigate('/page5')),
        _SettingsButton(label: 'Page 6', onPressed: () => onNavigate('/page6')),
        _SettingsButton(label: 'Page 7', onPressed: () => onNavigate('/page7')),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SettingsButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

class ContentPage extends StatelessWidget {
  final String title;

  const ContentPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage1 extends StatelessWidget {
  final String title;

  const ContentPage1({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage2 extends StatelessWidget {
  final String title;

  const ContentPage2({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage3 extends StatelessWidget {
  final String title;

  const ContentPage3({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage4 extends StatelessWidget {
  final String title;

  const ContentPage4({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage5 extends StatelessWidget {
  final String title;

  const ContentPage5({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage6 extends StatelessWidget {
  final String title;

  const ContentPage6({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ContentPage7 extends StatelessWidget {
  final String title;

  const ContentPage7({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Main Content Area', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
