import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm_app/contollers/ApiController.dart';
import 'package:alarm_app/models/WeatherModel.dart';
import 'package:alarm_app/utils/DateTimeUtils.dart';
import 'package:alarm_app/utils/LocationUtils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class AlarmEditScreen extends StatefulWidget {
  const AlarmEditScreen({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  Position? position;
  final ApiController controller = ApiController();
  WeatherModel weatherModel = WeatherModel();

  @override
  void initState() {
    super.initState();

    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            TextButton(
              onPressed: saveAlarm,
              child: loading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Save',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.blueAccent),
                    ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Current weather info",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  controller.isFetchingWeather.value
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: const CircularProgressIndicator(),
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(weatherModel.name ?? "NA"),
                                      Text(weatherModel.country ?? "NA"),
                                      Text(weatherModel.region ?? "NA"),
                                    ],
                                  ),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(weatherModel.timezoneId ?? "NA"),
                                      Text(weatherModel.localtime ?? "NA"),
                                      // Text(weatherModel.region??"NA"),
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),

                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Center(
                      child: Text(
                        DateTimeUtils.getDay(selectedDateTime),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Colors.blueAccent.withOpacity(0.8)),
                      ),
                    ),
                  ),
                  Center(
                    child: RawMaterialButton(
                      onPressed: () async {
                        selectedDateTime = await DateTimeUtils.pickTime(
                            selectedDateTime, context);
                        setState(() {});
                      },
                      fillColor: Colors.grey[200],
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Text(
                          TimeOfDay.fromDateTime(selectedDateTime)
                              .format(context),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Loop alarm audio',
                  //       style: Theme.of(context).textTheme.titleMedium,
                  //     ),
                  //     Switch(
                  //       value: loopAudio,
                  //       onChanged: (value) => setState(() => loopAudio = value),
                  //     ),
                  //   ],
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Vibrate',
                  //       style: Theme.of(context).textTheme.titleMedium,
                  //     ),
                  //     Switch(
                  //       value: vibrate,
                  //       onChanged: (value) => setState(() => vibrate = value),
                  //     ),
                  //   ],
                  // ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Custom volume',
                  //       style: Theme.of(context).textTheme.titleMedium,
                  //     ),
                  //     Switch(
                  //       value: volume != null,
                  //       onChanged: (value) =>
                  //           setState(() => volume = value ? 0.5 : null),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(
                    height: 30,
                    child: volume != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                volume! > 0.7
                                    ? Icons.volume_up_rounded
                                    : volume! > 0.1
                                        ? Icons.volume_down_rounded
                                        : Icons.volume_mute_rounded,
                              ),
                              Expanded(
                                child: Slider(
                                  value: volume!,
                                  onChanged: (value) {
                                    setState(() => volume = value);
                                  },
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                  if (!creating)
                    TextButton(
                      onPressed: deleteAlarm,
                      child: Text(
                        'Delete Alarm',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.red),
                      ),
                    ),
                  const SizedBox(),
                ],
              )),
        ),
      ),
    );
  }

  getCurrentLocation() async {
    controller.setIsFetchingWeather(true);

    try {
      position = await LocationUtils.getLoaction();
    } catch (_) {
      controller.setIsFetchingWeather(false);
    }

    if (null != position) {
      weatherModel = await ApiController()
          .getCurrentWeather(position!.latitude, position!.longitude);
      controller.setIsFetchingWeather(false);
    }
    print(position?.latitude.toString());
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: 'Alarm example',
      notificationBody: 'Your alarm ($id) is ringing',
      enableNotificationOnKill: Platform.isIOS,
    );
    return alarmSettings;
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }
}
