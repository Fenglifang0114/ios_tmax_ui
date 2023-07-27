import 'dart:async';

import 'package:flutter/material.dart';
import '../data/login_data.dart';
import 'widget/theme_color.dart';
import 'dialog/register_dialog.dart';
import 'home_page.dart';
import 'widget/box_gradient.dart';
import 'widget/version.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool ischangepassword = true;
  late Timer timer;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeColor(),
      home: Scaffold(
          // AppBar：相当于iOS 的导航栏
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: AppBar(
                title: version(),
                //设置状态栏颜色渐变
                flexibleSpace: Container(
                    decoration: BoxDecoration(gradient: boxGradient())),
              )),
          body: ListView(
            children: [
              Container(
                height: _height,
                width: _width,
                decoration: BoxDecoration(gradient: boxGradient()),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 400,
                        child: Card(
                          shadowColor: Colors.grey,
                          elevation: 40,
                          margin: const EdgeInsets.all(10),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "",
                                style: TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                  width: 300,
                                  child: TextField(
                                    //绑定控制器
                                    controller: _userName,
                                    // keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: ' | Please input User Name',
                                      labelText: ' | User Name',
                                      prefixIcon: Icon(Icons.account_box),
                                    ),
                                    autofocus: false,
                                  )),
                              const SizedBox(height: 30),
                              SizedBox(
                                  width: 300,
                                  child: TextField(
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    //绑定控制器
                                    controller: _password,
                                    // keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: ' | Please input password',
                                      labelText: ' | Password',
                                      prefixIcon: Icon(Icons.lock),
                                    ),
                                    autofocus: false,
                                  )),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          myUserData.userName = _userName.text;
                                          myUserData.password = _password.text;
                                          // MyApp.getSock().send('userdata',
                                          //     jsonEncode(myUserData));
                                          //跳转页面
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  //没有传值
                                                  builder: (context) =>
                                                      const HomePage()));
                                        });
                                      },
                                      child: const Text("Login")),
                                  const SizedBox(width: 120),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          registerDialog(context)
                                              .then((onValue) {});
                                        });
                                      },
                                      child: const Text("Register")),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Checkbox(
                                      value: ischangepassword,
                                      onChanged: (value) {
                                        setState(() {
                                          ischangepassword = value!;
                                        });
                                      }),
                                  const Text("Remember password")
                                ],
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 250,
                            child: Image.asset('images/tscale.png')),
                        const SizedBox(width: 100)
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
