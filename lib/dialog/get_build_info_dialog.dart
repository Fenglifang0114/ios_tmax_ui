import 'package:flutter/material.dart';
import 'package:t_max/functions/methods.dart';
import '../../generated/l10n.dart';
import '../data/downloadresponse.dart';
import '../eventbus/eventbus.dart';

class GetBuildInfoPage extends StatefulWidget {
  const GetBuildInfoPage({super.key});

  @override
  _GetBuildInfoPageState createState() => _GetBuildInfoPageState();
}

class _GetBuildInfoPageState extends State<GetBuildInfoPage> {
  dynamic localizedStrings;
  dynamic eventbus1;
  TextEditingController buildInfoController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    buildInfoController.text = '';
    super.initState();
    PublicFunctions.getBuildInfo();
    eventbus1 = eventBus.on<EventGetBuildInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myRespGetBuildInfo = event.obj;
          if (myRespGetBuildInfo.msgBody.isNotEmpty) {
            buildInfoController.text = myRespGetBuildInfo.msgBody;
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
      title: Container(
          width: 400,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              Text(localizedStrings.get_build_info,
                  style: const TextStyle(color: Colors.white))
            ],
          )),
      content: Container(
        height: 300,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
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
            OutlinedButton(
                child: Text(localizedStrings.button_exit),
                onPressed: () {
                  setState(() {});
                  Navigator.of(context)
                      .pop(); // to go back to screen after submitting
                })
          ],
        )
      ],
    );
  }
}
