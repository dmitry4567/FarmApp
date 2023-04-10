import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_application_1/StatusWidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotification = FlutterLocalNotificationsPlugin();

Future checkwater() async {
  final String apiUrl = "http://192.168.43.199/water";
  final data = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 3));
  var jsonData = json.decode(data.body);
  print(jsonData);
  if (jsonData["water"] == "1") {
    showNotification();
  }
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  checkwater();
  BackgroundFetch.finish(taskId);
}

//adb logcat *:S flutter:V, TSBackgroundFetch:V

Future showNotification() async {
  var androidDetalis = new AndroidNotificationDetails("channelId", "Local Notification",
      channelDescription: "sefsef", importance: Importance.high);
  var iosDetalis = new IOSNotificationDetails();
  var generalNotificationDetalis = new NotificationDetails(android: androidDetalis, iOS: iosDetalis);
  await localNotification.show(0, "Ферма", "Нужно долить воды", generalNotificationDetalis);
}

void main() {
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  var _onPump = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Color(0xff0086CD), Color(0xff004B9C)],
    ),
  );

  var _onFito = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Color(0xffF0047F), Color(0xff82027E)],
    ),
  );

  var _onLight = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Color(0xffFEA621), Color(0xffFE330A)],
    ),
  );

  var _off = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Color(0xff5C5C5C), Color(0xff5C5C5C)],
    ),
  );

  @override
  void initState() {
    super.initState();
    initPlatformState();
    var androidInitiliaze = new AndroidInitializationSettings('ic_launcher');
    var IOSInitiliaze = new IOSInitializationSettings();
    var initliazeSettings = new InitializationSettings(android: androidInitiliaze, iOS: IOSInitiliaze);
    localNotification.initialize(initliazeSettings);
    status = Status("Соединение...", Color(0xFFF4C500));
    _update();
  }

  Future<void> initPlatformState() async {
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      print("[BackgroundFetch] Event received $taskId");
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    if (!mounted) return;
  }

  Future _rele(int rele_int) async {
    final String apiUrl = "http://192.168.43.199/rele" + rele_int.toString();
    final data = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 3));
    var jsonData = json.decode(data.body);
    print(jsonData);
  }

  Future _pumpTime(int time) async {
    final String apiUrl = "http://192.168.43.199/pumptime?time=" + time.toString();
    final data = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 3));
    //var jsonData = json.decode(data.body);
    print(data.statusCode);
  }

  Future _pumpWaterTime(int time) async {
    final String apiUrl = "http://192.168.43.199/pumpwater?time=" + time.toString();
    final data = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 3));
    //var jsonData = json.decode(data.body);
    print(data.statusCode);
  }

  Future _update() async {
    Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        try {
          const String apiUrl = "http://192.168.43.199/";
          final data = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 10));
          var jsonData = json.decode(data.body);

          print(jsonData);

          if (!connect) {
            if (jsonData["rele1"].toString() == "1") {
              statusFito = true;
            } else {
              statusFito = false;
            }
            if (jsonData["rele2"].toString() == "1") {
              statusLight = true;
            } else {
              statusLight = false;
            }
            if (jsonData["rele3"].toString() == "1") {
              statusPump = true;
            } else {
              statusPump = false;
            }
            _value = double.parse(jsonData["pump_timeout"].toString());
            _value2 = double.parse(jsonData["pump_waterTime"].toString());
          }

          if (jsonData["water"].toString() == "1") {
            water = false;
          } else {
            water = true;
          }

          status = Status("Подключено", Color(0xFF22B573));
          connect = true;

          temp = jsonData["temp"].toString();
          hum = jsonData["hum"].toString();

          setState(() {});
        } catch (e) {
          print(e);
          setState(() {
            status = Status("Ошибка подключения", Color(0xFFED1C24));
            connect = false;
          });
        }
      },
    );
  }

  static String _valueToString(double value) {
    return value.toStringAsFixed(0);
  }

  var hum = "...";
  var temp = "...";
  Widget status = Status("", Color(0xFF333333));

  bool statusPump = false;
  bool statusFito = false;
  bool statusLight = false;
  bool connect = false;
  bool water = false;

  double _value = 30.0;
  double _value2 = 1.0;

  final String h = 'assets/water.svg';
  final String t = 'assets/temp.svg';
  final String w = 'assets/wave.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: status,
      backgroundColor: Color(0xff333333),
      body: ListView(
        children: [
          SizedBox(
            height: 100,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 165,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                width: 2,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: SvgPicture.asset(
                              t,
                              width: 40,
                              height: 40,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            temp + "°C",
                            style: GoogleFonts.roboto(fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: SvgPicture.asset(h, width: 40, height: 40, color: Colors.white.withOpacity(0.5)),
                          ),
                          Text(
                            hum + "%",
                            style: GoogleFonts.roboto(fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  bottom: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        child: SvgPicture.asset(
                          w,
                          width: 15,
                          height: 15,
                          color: water ? Colors.white.withOpacity(0.5) : Colors.red,
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 3),
                        child: Text(
                          water ? "есть" : "нужно долить воды",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: water ? Colors.white.withOpacity(0.5) : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        statusFito = !statusFito;
                        _rele(1);
                      });
                    },
                    child: AnimatedContainer(
                      height: (MediaQuery.of(context).size.width - 80) / 2,
                      duration: Duration(milliseconds: 200),
                      decoration: statusFito ? _onFito : _off,
                      child: Center(
                        child: Text(
                          "Свет",
                          style: GoogleFonts.roboto(fontSize: 30, color: statusFito ? Colors.white : Colors.grey[200]),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ), //SizedBox
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        statusLight = !statusLight;
                        _rele(2);
                      });
                    },
                    child: AnimatedContainer(
                      height: (MediaQuery.of(context).size.width - 80) / 2,
                      duration: Duration(milliseconds: 200),
                      decoration: statusLight ? _onLight : _off,
                      child: Center(
                        child: Text(
                          "Свет",
                          style: GoogleFonts.roboto(fontSize: 30, color: statusLight ? Colors.white : Colors.grey[200]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          AnimatedContainer(
            margin: EdgeInsets.symmetric(horizontal: 20),
            duration: Duration(milliseconds: 200),
            decoration: statusPump ? _onPump : _off,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 18, right: 18, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Насос",
                        style: GoogleFonts.roboto(fontSize: 30, color: statusPump ? Colors.white : Colors.grey[200]),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: FlutterSwitch(
                          width: 55.0,
                          height: 25.0,
                          valueFontSize: 12.0,
                          toggleSize: 18.0,
                          value: statusPump,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white,
                          activeToggleColor: Color(0xff0050A0),
                          inactiveToggleColor: Color(0xff5C5C5C),
                          onToggle: (val) {
                            setState(
                              () {
                                statusPump = val;
                                _rele(3);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  child: Text(
                    "Таймаут",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                SfSliderTheme(
                  data: SfSliderThemeData(
                    inactiveTrackHeight: 5,
                    trackCornerRadius: 5,
                    inactiveTrackColor: statusPump ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                    activeTrackColor: statusPump ? Colors.blue : Colors.grey,
                    //activeTrackColor: Color(0xff0086CD).withOpacity(0.75),
                    thumbColor: statusPump ? Colors.white : Colors.grey[200],
                    overlayColor: Colors.transparent,
                    activeLabelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 8),
                    inactiveLabelStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8),
                    activeTickColor: Colors.white.withOpacity(0.5),
                    inactiveTickColor: Colors.white.withOpacity(0.2),
                    //activeMinorTickColor: Color.fromRGBO(244, 197, 0, 1),
                    //inactiveMinorTickColor: Color.fromRGBO(244, 197, 0, 0.5),
                  ),
                  child: SfSlider(
                    min: 30.0,
                    max: 120.0,
                    interval: 30,
                    stepSize: 30,
                    minorTicksPerInterval: 0,
                    showTicks: true,
                    showLabels: true,
                    value: _value,
                    onChangeEnd: (dynamic newValues) {
                      if (statusPump) {
                        setState(() {
                          _value = newValues;
                          print(_valueToString(_value));
                          _pumpTime(int.parse(_valueToString(_value)));
                        });
                      }
                    },
                    onChanged: (dynamic newValues) {
                      if (statusPump) {
                        setState(() {
                          _value = newValues;
                        });
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Text(
                    "Подача воды",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                SfSliderTheme(
                  data: SfSliderThemeData(
                    inactiveTrackHeight: 5,
                    trackCornerRadius: 5,
                    inactiveTrackColor: statusPump ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                    activeTrackColor: statusPump ? Colors.blue : Colors.grey,
                    //activeTrackColor: Color(0xff0086CD).withOpacity(0.75),
                    thumbColor: statusPump ? Colors.white : Colors.grey[200],
                    overlayColor: Colors.transparent,
                    activeLabelStyle: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 8),
                    inactiveLabelStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8),
                    activeTickColor: Colors.white.withOpacity(0.5),
                    inactiveTickColor: Colors.white.withOpacity(0.2),
                    //activeMinorTickColor: Color.fromRGBO(244, 197, 0, 1),
                    //inactiveMinorTickColor: Color.fromRGBO(244, 197, 0, 0.5),
                  ),
                  child: SfSlider(
                    min: 1,
                    max: 5,
                    interval: 1,
                    stepSize: 1,
                    minorTicksPerInterval: 0,
                    showTicks: true,
                    showLabels: true,
                    value: _value2,
                    onChangeEnd: (dynamic newValues) {
                      if (statusPump) {
                        setState(() {
                          _value2 = newValues;
                          print(_valueToString(_value2));
                          _pumpWaterTime(int.parse(_valueToString(_value2)));
                        });
                      }
                    },
                    onChanged: (dynamic newValues) {
                      if (statusPump) {
                        setState(() {
                          _value2 = newValues;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
