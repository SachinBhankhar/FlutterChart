/*
 * @Author: Cao Shixin
 * @Date: 2020-03-29 10:26:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2020-05-27 14:53:20
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'package:example/chart_bar_circle.dart';
import 'package:example/chart_bar_round.dart';
import 'package:example/chart_curve.dart';
import 'package:example/chart_line.dart';
import 'package:example/chart_pie.dart';
import 'package:example/double_chart_line.dart';
import 'package:example/focus_chart_line.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final Map<String, WidgetBuilder> _routes = {
  //FN专注力样式图
  FocusChartLinePage.routeName: (_) => FocusChartLinePage(),
  //柱状顶部半圆型
  ChartBarCirclePage.routeName: (_) => ChartBarCirclePage(),
  //柱状图顶部自定义弧角
  ChartBarRoundPage.routeName: (_) => ChartBarRoundPage(),
  //平滑曲线带填充颜色
  ChartCurvePage.routeName: (_) => ChartCurvePage(),
  //折线带填充颜色
  ChartLinePage.routeName: (_) => ChartLinePage(),
  //双折线
  DoubleChartlinePage.routeName: (_) => DoubleChartlinePage(),
  //饼状图
  ChartPiePage.routeName: (_) => ChartPiePage(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '绘图图表测试',
      theme: ThemeData(primaryColor: Colors.blue),
      routes: _routes,
      home: Scaffold(
        appBar: AppBar(
          title: Text('绘图图表测试'),
        ),
        body: MyAppPage(),
      ),
    );
  }
}

class MyAppPage extends StatefulWidget {
  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  List<CellModel> _demoTitleArr = [];

  @override
  void initState() {
    super.initState();
    _demoTitleArr = [
      CellModel(title: 'FN专注力样式图', routeName: FocusChartLinePage.routeName),
      CellModel(title: '柱状顶部半圆型', routeName: ChartBarCirclePage.routeName),
      CellModel(title: '柱状图顶部自定义弧角', routeName: ChartBarRoundPage.routeName),
      CellModel(title: '平滑曲线带填充颜色', routeName: ChartCurvePage.routeName),
      CellModel(title: '折线带填充颜色', routeName: ChartLinePage.routeName),
      CellModel(title: '双折线', routeName: DoubleChartlinePage.routeName),
      CellModel(title: '饼状图', routeName: ChartPiePage.routeName)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(_demoTitleArr[index].routeName);
          },
          child: ListTile(
            title: Center(
              child: Text(_demoTitleArr[index].title),
            ),
          ),
        );
      },
      itemCount: _demoTitleArr.length,
    );
  }
}

class CellModel {
  //显示标题
  String title;
  //路由地址名
  String routeName;

  CellModel({this.title, this.routeName});
}
