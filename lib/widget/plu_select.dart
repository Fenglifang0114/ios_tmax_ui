// 选择PLU数据的小部件

// 构建输入框装饰
import 'package:flutter/material.dart';
import 'package:t_max/data/plu_data_source.dart';

InputDecoration buildInputDecoration(BuildContext context) {
  return InputDecoration(
    border:
        buildOutlineInputBorder(context, Theme.of(context).colorScheme.outline),
    focusedBorder:
        buildOutlineInputBorder(context, Theme.of(context).colorScheme.primary),
    enabledBorder: buildOutlineInputBorder(
        context, Theme.of(context).colorScheme.outlineVariant),
    hintText: 'PLU',
    hintStyle: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  );
}

// 构建边框
OutlineInputBorder buildOutlineInputBorder(BuildContext context, Color color) {
  return OutlineInputBorder(
    gapPadding: 2,
    borderRadius: BorderRadius.circular(0),
    borderSide: BorderSide(color: color, width: 1),
  );
}

//get options
Iterable<PluData> buildOptions(String searchText) {
  try {
    final resultSet = <PluData>{};
    final searchLower = searchText.toLowerCase();

    // 根据是否为空选择添加所有数据或筛选数据
    if (searchText.isEmpty) {
      resultSet.addAll(myPluInfoList);
    } else {
      resultSet.addAll(myPluInfoList.where((data) =>
          data.productName?.toLowerCase().contains(searchLower) == true ||
          data.plu?.toString().contains(searchText) == true));
    }

    // 去重逻辑
    final seenRecIds = <int>{};
    final newList = resultSet
        .where((item) => item.plu != null && seenRecIds.add(item.plu!))
        .toList();

    // 排序
    newList.sort((a, b) => (a.plu ?? 0).compareTo(b.plu ?? 0));
    return newList;
  } catch (e) {
    return const Iterable<PluData>.empty();
  }
}

class SimpleVirtualScrollOptionsView extends StatefulWidget {
  final void Function(PluData) onSelected;
  final Iterable<PluData> options;
  final double maxHeight;

  const SimpleVirtualScrollOptionsView({
    super.key,
    required this.onSelected,
    required this.options,
    this.maxHeight = 300,
  });

  @override
  SimpleVirtualScrollOptionsViewState createState() =>
      SimpleVirtualScrollOptionsViewState();
}

class SimpleVirtualScrollOptionsViewState
    extends State<SimpleVirtualScrollOptionsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsList = widget.options.toList();

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.maxHeight,
            maxWidth: 400,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: optionsList.length,
                  itemBuilder: (context, index) {
                    final option = optionsList[index];
                    return SizedBox(
                      height: 40,
                      child: InkWell(
                        onTap: () => widget.onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Text(
                            '${option.plu}:${option.productName}',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildOptionsView(
  BuildContext context,
  void Function(PluData) onSelected,
  Iterable<PluData> options,
) {
  return SimpleVirtualScrollOptionsView(
    onSelected: onSelected,
    options: options,
    maxHeight: 300,
  );
}

Widget showSelPluWidget(
    double width, double height, void Function(PluData) onSelected) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.centerLeft,
    child: Autocomplete<PluData>(
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (String value) => onFieldSubmitted(),
          maxLines: 1,
          textAlignVertical: TextAlignVertical.top,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          decoration: buildInputDecoration(context),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        return buildOptions(textEditingValue.text);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return buildOptionsView(context, onSelected, options);
      },
      onSelected: (PluData selection) {
        onSelected(selection);
      },
      displayStringForOption: (PluData option) =>
          '${option.plu}:${option.productName}',
    ),
  );
}
