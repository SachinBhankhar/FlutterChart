/*
 * @Author: Cao Shixin
 * @Date: 2020-07-17 17:38:37
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2020-08-20 19:17:16
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chart_csx/chart/bean/chart_bean_dimensionality.dart';
import 'package:flutter_chart_csx/chart/painter/base_painter.dart';
import 'package:path_drawing/path_drawing.dart';

class ChartDimensionalityPainter extends BasePainter {
  List<ChartBeanDimensionality>
      dimensionalityDivisions; //维度划分的重要参数(决定有几个内容就是几个维度，从正上方顺时针方向绘制)
  List<DimensionalityBean> dimensionalityTags; //维度填充数据的重要内容
  double value; //当前动画值
  double lineWidth; //线宽
  bool isDotted; //背景网是否为虚线
  Color lineColor; //线条颜色
  double centerR; //圆半径
  int dimensionalityNumber; //阶层：维度图从中心到最外层有几圈

  double _centerX, _centerY, _averageAngle; //圆心

  static const Color defaultColor = Colors.deepPurple;
  static const Color defaultRectShadowColor = Colors.white;
  static const double basePadding = 16; //默认的边距

  ChartDimensionalityPainter(
    this.dimensionalityDivisions, {
    this.dimensionalityTags,
    this.value = 1,
    this.lineWidth,
    this.isDotted,
    this.lineColor,
    this.centerR,
    this.dimensionalityNumber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //初始化数据
    _init(size);
    //绘制基础网状结构
    _createBase(canvas, size);
    //绘制内部多边形彩色区域
    _createPaintShadowPath(canvas, size);
  }

  @override
  bool shouldRepaint(ChartDimensionalityPainter oldDelegate) {
    return true;
  }

  void _init(Size size) {
    _initValue();
    _initlizeData(size);
  }

  void _initValue() {
    lineColor ??= defaultColor;
    isDotted ??= false;
    lineWidth ??= 1;
    if (dimensionalityNumber == null || dimensionalityNumber == 0) {
      dimensionalityNumber = 4;
    }
  }

  void _initlizeData(Size size) {
    var startX = basePadding;
    var endX = size.width - basePadding;
    var startY = size.height - basePadding;
    var endY = basePadding;

    _centerX = startX + (endX - startX) / 2;
    _centerY = endY + (startY - endY) / 2;
    var xR = endX - _centerX;
    var yR = startY - _centerY;
    var tempCenterR = xR.compareTo(yR) > 0 ? yR : xR;
    if (centerR == null || centerR > tempCenterR) {
      centerR = tempCenterR;
    }

    _averageAngle = 2 * pi / dimensionalityDivisions.length;
  }

  void _createBase(Canvas canvas, Size size) {
    var speaceIndex = centerR / dimensionalityNumber;
    for (var i = 0; i < dimensionalityNumber; i++) {
      var tempLength = centerR - speaceIndex * i;
      var basePoints = <Point>[];
      for (var j = 0; j < dimensionalityDivisions.length; j++) {
        basePoints
            .add(_getBaseCenterLengthAnglePoint(tempLength, _averageAngle * j));
        if (i == 0) {
          var model = dimensionalityDivisions[j];
          _createTextWithPara(
              model.tip, model.tipStyle, _averageAngle * j, canvas, size);
        }
      }
      var baseLinePath = Path()..moveTo(basePoints.first.x, basePoints.first.y);
      for (var k = 1; k < basePoints.length; k++) {
        var tempPoint = basePoints[k];
        baseLinePath..lineTo(tempPoint.x, tempPoint.y);
      }
      baseLinePath
        ..lineTo(basePoints.first.x, basePoints.first.y)
        ..close();
      var basePaint = Paint()
        ..strokeWidth = lineWidth
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;
      canvas.drawPath(
          isDotted
              ? dashPath(
                  baseLinePath,
                  dashArray: CircularIntervalList<double>(<double>[5.0, 4.0]),
                )
              : baseLinePath,
          basePaint);
    }
  }

  Point _getBaseCenterLengthAnglePoint(double length, double angle) {
    return Point(
        _centerX + sin(angle) * length, _centerY - cos(angle) * length);
  }

//绘制维度文字
  void _createTextWithPara(String text, TextStyle textStyle, double angle,
      Canvas canvas, Size size) {
    var tp = TextPainter(
        textAlign: TextAlign.center,
        ellipsis: '.',
        maxLines: 1,
        text: TextSpan(
          text: text,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: size.width);
    var temPoint = _getBaseCenterLengthAnglePoint(centerR + 10, angle);
    var tempOffset = Offset(0, 0);
    var sinAngle = sin(angle), cosAngle = cos(angle);
    //double的精度处理问题，这里给一定的伸缩范围
    if ((sinAngle * 100000000).floor() == 0) {
      if (cosAngle > 0) {
        //顶角
        tempOffset =
            Offset(temPoint.x - tp.size.width / 2, temPoint.y - tp.size.height);
      } else {
        //底角
        tempOffset = Offset(temPoint.x - tp.size.width / 2, temPoint.y);
      }
    } else if (sinAngle > 0) {
      //右侧
      tempOffset = Offset(temPoint.x, temPoint.y - tp.size.height / 2);
    } else {
      //左侧
      tempOffset =
          Offset(temPoint.x - tp.size.width, temPoint.y - tp.size.height / 2);
    }
    tp.paint(canvas, tempOffset);
  }

//绘制内部阴影区域
  void _createPaintShadowPath(Canvas canvas, Size size) {
    var begainDy = basePadding;
    for (var i = 0; i < dimensionalityTags.length; i++) {
      var tempBean = dimensionalityTags[i];

      var basePoints = <Point>[];
      for (var j = 0; j < dimensionalityDivisions.length; j++) {
        var length = 0.0;
        if (j < tempBean.tagContents.length) {
          length = centerR * tempBean.tagContents[j];
        }
        basePoints
            .add(_getBaseCenterLengthAnglePoint(length, _averageAngle * j));
      }
      var shadowPath = Path()..moveTo(basePoints.first.x, basePoints.first.y);
      for (var k = 1; k < basePoints.length; k++) {
        var tempPoint = basePoints[k];
        shadowPath..lineTo(tempPoint.x, tempPoint.y);
      }
      shadowPath
        ..lineTo(basePoints.first.x, basePoints.first.y)
        ..close();
      var shadowPaint = Paint()
        ..strokeWidth = 1
        ..color = tempBean.tagColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(shadowPath, shadowPaint);

      var tp = TextPainter(
          textAlign: TextAlign.center,
          ellipsis: '.',
          maxLines: 1,
          text: TextSpan(
            text: tempBean.tagTitle,
            style: tempBean.tagTitleStyle,
          ),
          textDirection: TextDirection.rtl)
        ..layout(minWidth: 0, maxWidth: size.width);
      tp.paint(canvas, Offset(size.width - tp.width - 20, begainDy));
      //绘制标记小椭圆
      var rightBegainCenterX = size.width - tp.width - 20 - 10;
      var strghtWidth = (tp.height - 4) / 6 * 10;
      var strghtHeight = tp.height - 4;
      var tipPath = Path()
        ..moveTo(
            rightBegainCenterX, begainDy + tp.height / 2 - strghtHeight / 2)
        ..addArc(
            Rect.fromCircle(
                center: Offset(rightBegainCenterX, begainDy + tp.height / 2),
                radius: strghtHeight / 2),
            -pi / 2,
            pi)
        ..lineTo(rightBegainCenterX - strghtWidth,
            begainDy + tp.height / 2 + strghtHeight / 2)
        ..addArc(
            Rect.fromCircle(
                center: Offset(
                    rightBegainCenterX - strghtWidth, begainDy + tp.height / 2),
                radius: strghtHeight / 2),
            pi / 2,
            pi)
        ..lineTo(
            rightBegainCenterX, begainDy + tp.height / 2 - strghtHeight / 2)
        ..close();
      canvas.drawPath(tipPath, shadowPaint);

      begainDy += (tp.height + 7);
    }
  }
}
