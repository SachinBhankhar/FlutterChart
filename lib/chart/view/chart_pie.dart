/*
 * @Author: Cao Shixin
 * @Date: 2020-03-29 10:26:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2020-12-29 10:45:15
 * @Description: 饼状图绘制区域
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_chart_csx/chart/bean/chart_bean.dart';
import 'package:flutter_chart_csx/chart/bean/chart_bean_pie.dart';
import 'package:flutter_chart_csx/chart/enum/chart_pie_enum.dart';
import 'package:flutter_chart_csx/chart/painter/chart_pie_painter.dart';

class ChartPie extends StatefulWidget {
  final Duration duration;
  final Size size;
  final List<ChartPieBean> chartBeans;
  //绘制的背景色
  final Color? backgroundColor;
  //是否执行动画
  final bool isAnimation;
  //半径,中心圆半径
  final double? globalR, centerR;
  //中心圆颜色
  final Color? centerColor;
  //各个占比之间的分割线宽度，默认为0即不显示分割
  final double divisionWidth;
  //辅助性文案显示的样式
  final AssistTextShowType assistTextShowType;
  //开始画圆的位置
  final ArrowBegainLocation arrowBegainLocation;
  final BaseBean? baseBean;
  //辅助性文案的背景框背景颜色
  final Color? assistBGColor;
  //辅助性百分比显示的小数位数,（饼状图还是真实的比例）
  final int decimalDigits;
  //中心组件
  final Widget? centerWidget;

  const ChartPie({
    Key? key,
    required this.size,
    required this.chartBeans,
    this.duration = const Duration(milliseconds: 0),
    this.backgroundColor,
    this.isAnimation = true,
    this.globalR,
    this.centerR,
    this.centerColor,
    this.divisionWidth = 0,
    this.assistTextShowType = AssistTextShowType.None,
    this.arrowBegainLocation = ArrowBegainLocation.Top,
    this.baseBean,
    this.assistBGColor,
    this.decimalDigits = 0,
    this.centerWidget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChartPieState();
}

class ChartPieState extends State<ChartPie>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _value = 0;
  double begin = 0.0, end = 360;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimation) {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      Tween(begin: begin, end: end).animate(_controller!)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {}
        })
        ..addListener(() {
          _value = _controller!.value;
          setState(() {});
        });
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var painter = ChartPiePainter(
      widget.chartBeans,
      value: _value,
      globalR: widget.globalR,
      centerR: widget.centerR,
      centerColor: widget.centerColor,
      divisionWidth: widget.divisionWidth,
      assistTextShowType: widget.assistTextShowType,
      arrowBegainLocation: widget.arrowBegainLocation,
      assistBGColor: widget.assistBGColor,
      decimalDigits: widget.decimalDigits,
    );
    painter.baseBean = widget.baseBean;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CustomPaint(
            size: widget.size,
            foregroundPainter: widget.backgroundColor != null ? painter : null,
            child: widget.backgroundColor != null
                ? Container(
                    width: widget.size.width,
                    height: widget.size.height,
                    color: widget.backgroundColor,
                  )
                : null,
            painter: widget.backgroundColor == null ? painter : null),
        widget.centerWidget ?? Container(),
      ],
    );
  }
}
