import 'package:flutter/material.dart';

Widget appCard(BuildContext context, String titleName, IconData iconInfo,
    bool isValid, String explanation) {
  return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isValid
          ? Theme.of(context).colorScheme.surfaceTint
          : Theme.of(context).colorScheme.background,
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            Container(
              child: (Row(
                children: [
                  Container(
                    width: 3.0,
                    height: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return lineGradient(context).createShader(bounds);
                    },
                    child: Icon(
                      size: 30,
                      iconInfo,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  )
                ],
              )),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    // flex: 5, // 上下分割比例
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        titleName,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    // flex: 5, // 上下分割比例
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        explanation,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '',
                  overflow: TextOverflow.visible,
                ),
              ),
            )
          ],
        ),
      ));
}

LinearGradient lineGradient(BuildContext context) {
  return LinearGradient(
    colors: [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.shadow
      // Color.fromARGB(255, 21, 129, 238),
      // Color.fromARGB(255, 115, 238, 207),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

Widget customFunctionCard(
    BuildContext context, String titleName, IconData iconInfo, bool isValid) {
  return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isValid
          ? Theme.of(context).colorScheme.surfaceTint
          : Theme.of(context).colorScheme.background,
      child: SizedBox(
          height: 80,
          child: Row(
            children: [
              Container(
                width: 3.0,
                height: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 25,
              ),
              ShaderMask(
                shaderCallback: (bounds) {
                  return lineGradient(context).createShader(bounds);
                },
                child: Icon(
                  size: 30,
                  iconInfo,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  titleName,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          )));
}
