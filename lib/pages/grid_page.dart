import 'package:flutter/material.dart';

class GridPage extends StatefulWidget {
  const GridPage({Key? key}) : super(key: key);

  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  List listData = [
    {"title": "标题1", "author": "内容1"},
    {"title": "标题2", "author": "内容2"},
    {"title": "标题3", "author": "内容3"},
    {"title": "标题4", "author": "内容4"},
    {"title": "标题5", "author": "内容5"},
    {"title": "标题6", "author": "内容6"},
  ];

  late ScrollController _pageScrollerController;

  @override
  void initState() {
    super.initState();
    _pageScrollerController = ScrollController();
  }

  @override
  void dispose() {
    _pageScrollerController.dispose();
    super.dispose();
  }

  List<Widget> _getData() {
    List<Widget> list = [];
    for (var i = 0; i < listData.length; i++) {
      list.add(Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black26, width: 1)),
        child: Column(
          children: [
            Text(
              listData[i]["author"],
              textAlign: TextAlign.center,
            ),
            Text(
              listData[i]["title"],
              textAlign: TextAlign.center,
            ),
            Container(
              width: 300,
              height: 210,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 0.5, color: Colors.black)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 60,
                        color: Colors.blue.shade900,
                        child: const TextField(
                          enabled: false,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "999999.9999",
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 25),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 50,
                        height: 60,
                        color: Colors.blue.shade900,
                        child: const TextField(
                          enabled: false,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "kg",
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 20),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const Text("稳定"),
                              const SizedBox(width: 20),
                              Image.asset(
                                "images/gray.png",
                                width: 20,
                                height: 20,
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text("净重"),
                              const SizedBox(width: 20),
                              Image.asset(
                                "images/gray.png",
                                width: 20,
                                height: 20,
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 80),
                      Column(
                        children: [
                          const SizedBox(height: 25),
                          ElevatedButton(
                              onPressed: () {}, child: const Text("扣重")),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: () {}, child: const Text("归零")),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1000,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Expanded(
            child: ListView(controller: _pageScrollerController, children: [
          GridView.count(
            shrinkWrap: true,
            //设置滚动方向
            // scrollDirection: Axis.vertical,
            //禁止滑动
            physics: const NeverScrollableScrollPhysics(),
            //设置列数
            crossAxisCount: 3,
            //设置内边距
            padding: const EdgeInsets.all(10),
            //设置横向间距
            crossAxisSpacing: 10,
            //设置主轴间距
            mainAxisSpacing: 10,
            children: _getData(),
          ),
        ])));
  }
}
