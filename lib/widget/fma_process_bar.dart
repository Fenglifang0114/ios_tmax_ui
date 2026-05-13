//配方过程中的进度条

// 自定义进度条组件
import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final double targetValue; // 新增目标值参数

  final double maxWidth; // 新增最大宽度参数
  final double maxHeight; // 新增最大高度参数

  const CustomProgressBar({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.targetValue, // 新增目标值参数
    required this.maxWidth, // 新增最大宽度参数
    required this.maxHeight, // 新增最大高度参数
  });

  @override
  Widget build(BuildContext context) {
    double height;
    maxHeight > 50 ? height = maxHeight - 10 : height = maxHeight;
// 定义各区间宽度比例
    const double belowMinRatio = 0.5;
    const double minMaxRatio = 0.3;
    const double aboveMaxRatio = 0.2;

    double calculatePosition(double val) {
      if (val < minValue) {
        // 最小值以下部分
        return (val / minValue) * maxWidth * belowMinRatio;
      } else if (val <= maxValue) {
        // 最小值和最大值之间部分
        if (maxValue - minValue == 0) {
          return maxWidth * belowMinRatio;
        }
        return maxWidth * belowMinRatio +
            ((val - minValue) / (maxValue - minValue)) * maxWidth * minMaxRatio;
      } else {
        // 最大值以上部分
        if (maxValue - minValue == 0) {
          return maxWidth * (belowMinRatio + minMaxRatio);
        }
        return maxWidth * (belowMinRatio + minMaxRatio) +
            ((val - maxValue) / (maxValue - minValue)) *
                maxWidth *
                aboveMaxRatio;
      }
    }

    Color getColor(double val) {
      if (val < minValue) {
        return Color(0xFFFFB44A);
      } else if (val <= maxValue) {
        return Theme.of(context).colorScheme.onTertiaryFixedVariant;
      } else {
        return Theme.of(context).colorScheme.error;
      }
    }

    double valuePosition = calculatePosition(value);
    double targetPosition = calculatePosition(targetValue);
    double minPosition = calculatePosition(minValue);
    double maxPosition = calculatePosition(maxValue);

    return Stack(
      children: [
        // 背景灰色进度条
        Container(
          alignment: Alignment.centerLeft,
          height: height,
          width: maxWidth, // 使用最大宽度
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        // 根据当前值绘制进度条
        Container(
          alignment: Alignment.centerLeft,
          height: height,
          width: valuePosition,
          color: getColor(value),
        ),
        // 绘制当前值的线
        Positioned(
          left: valuePosition,
          child: Container(
            width: 2,
            height: height,
            color: getColor(value),
          ),
        ),
        // 绘制目标值的蓝色线
        Positioned(
          left: targetPosition,
          child: Container(
            width: 2,
            height: height,
            color: const Color.fromARGB(255, 4, 144, 18),
          ),
        ),
        // 绘制最小值的白色线
        Positioned(
          left: minPosition,
          child: Container(
            width: 2,
            height: height,
            color: const Color.fromARGB(255, 240, 248, 5),
          ),
        ),
        // 绘制最大值的白色线
        Positioned(
          left: maxPosition,
          child: Container(
            width: 2,
            height: height,
            color: Color.fromARGB(255, 221, 11, 11),
          ),
        ),
      ],
    );
  }
}

//配方进度条
// 自定义进度条组件
class CustomFmaProgressBar extends StatelessWidget {
  final int currentValue;
  final int max;
  final double maxWidth;
  final double maxHeight;

  const CustomFmaProgressBar({
    super.key,
    required this.currentValue,
    required this.max,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    double height;
    maxHeight > 50 ? height = maxHeight - 10 : height = maxHeight;
    //限制最高高度50
    height = maxHeight > 50 ? 50 : maxHeight;
    double segmentWidth = maxWidth / max;

    return Stack(
      children: [
        // 背景灰色进度条
        Container(
          alignment: Alignment.centerLeft,
          height: height,
          width: maxWidth,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        // 根据当前份数绘制进度条
        Container(
          alignment: Alignment.centerLeft,
          height: height,
          width: segmentWidth * currentValue,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
