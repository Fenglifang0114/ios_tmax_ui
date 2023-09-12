import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import 'register_warn_dialog.dart';

TextEditingController computerid = TextEditingController();
TextEditingController license = TextEditingController();
TextEditingController newlicense = TextEditingController();
TextEditingController dateofExpiry = TextEditingController();

registerDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: Container(
                color: Colors.blue.shade900,
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text("注册许可管理", style: TextStyle(color: Colors.white)),
                  ],
                )),
            content: Container(
              height: 280,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // 许可ID宽度调整
                  // Column(
                  //   children: [
                  //     Row(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const Text("电脑ID："),
                  //         SizedBox(
                  //           width: 200,
                  //           height: 30,
                  //           child: TextField(
                  //             controller: computerid,
                  //             textAlignVertical: TextAlignVertical.top,
                  //             decoration: const InputDecoration(
                  //               // hintText: "请输入机种类型，如：ztp",
                  //               border: OutlineInputBorder(),
                  //             ),
                  //           ),
                  //         ),
                  //         const SizedBox(width: 40),
                  //         const SizedBox(
                  //           width: 100,
                  //           child: Text(
                  //             "到期日期：",
                  //             textAlign: TextAlign.right,
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           width: 200,
                  //           height: 30,
                  //           child: TextField(
                  //             controller: dateofExpiry,
                  //             textAlignVertical: TextAlignVertical.top,
                  //             decoration: const InputDecoration(
                  //               // hintText: "请输入机种类型，如：ztp",
                  //               border: OutlineInputBorder(),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     const SizedBox(height: 30),
                  //     Row(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text("许可ID："),
                  //           SizedBox(
                  //             width: 540,
                  //             height: 30,
                  //             child: TextField(
                  //               controller: license,
                  //               textAlignVertical: TextAlignVertical.top,
                  //               decoration: const InputDecoration(
                  //                 // hintText: "请输入机种类型，如：ztp",
                  //                 border: OutlineInputBorder(),
                  //               ),
                  //             ),
                  //           ),
                  //         ])
                  //   ],
                  // ),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("电脑ID："),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: computerid,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text("许可ID："),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: license,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 60),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(""),
                          const SizedBox(
                            width: 200,
                            height: 30,
                          ),
                          const SizedBox(height: 15),
                          const Text("到期日期："),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: dateofExpiry,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(
                    color: Color.fromARGB(255, 158, 158, 158),
                    height: 0,
                    thickness: 1,
                    indent: 0.0,
                    endIndent: 0.0,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("新许可ID："),
                          SizedBox(
                            width: 200,
                            height: 30,
                            child: TextField(
                              controller: newlicense,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                // hintText: "请输入机种类型，如：ztp",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(""),
                          Row(
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    registerWarnDialog(context)
                                        .then((onValue) {});
                                  },
                                  child: const Text("注册")),
                              const SizedBox(width: 40),
                              ElevatedButton(
                                  onPressed: () {
                                    //跳转页面
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            //没有传值
                                            builder: (context) =>
                                                const HomePage()));
                                  },
                                  child: const Text("试用"))
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      child: const Text("关闭"),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // to go back to screen after submitting
                      })
                ],
              ),
              const SizedBox(
                height: 15,
              )
            ],
          );
        }));
      });
}
