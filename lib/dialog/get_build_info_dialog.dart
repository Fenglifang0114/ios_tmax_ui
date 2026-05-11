import 'package:flutter/material.dart';
import 'package:t_max/functions/methods.dart';

import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';

import '../data/screen_mgr.dart';
import '../eventbus/eventbus.dart';
import '../widget/custom_button.dart';

class GetBuildInfoPage extends StatefulWidget {
  const GetBuildInfoPage({super.key});

  @override
  GetBuildInfoPageState createState() => GetBuildInfoPageState();
}

class GetBuildInfoPageState extends State<GetBuildInfoPage> {
  dynamic eventbus1;
  TextEditingController buildInfoController = TextEditingController();

  @override
  void initState() {
    buildInfoController.text = '';
    super.initState();
    PublicFunctions.getBuildInfo(myDefScaleInfo.defScaleId!);
    eventbus1 = eventBus.on<EventGetBuildInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            buildInfoController.text = myRespDataFromScale.msgBody;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    eventbus1.cancel();
    buildInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(
          context, (localizedStrings?.gTitleGetBuildInfo ?? "gTitleGetBuildInfo"), Icons.privacy_tip, 400),
      content: Container(
        height: 300,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceTint),
              child: Column(
                children: [
                  // const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    height: 60,
                    child: TextField(
                      controller: buildInfoController,
                      readOnly: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        // hintText: "请输入机种类型，如：ztp",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    height: 60,
                    child: Text(
                      (localizedStrings?.gBuildInfoTip ?? "gBuildInfoTip"),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.exit_to_app,
              text: (localizedStrings?.gBtnExit ?? "gBtnExit"),
              onPressed: () {
                myScreenMgr.isMainScreen = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}
