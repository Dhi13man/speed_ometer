import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:speed_ometer/components/speedometer.dart';
import 'package:speed_ometer/tts_form.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({this.unit = 'm/s', Key? key}) : super(key: key);

  final String unit;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  SharedPreferences? _sharedPreferences;
  // For text to speed naration of current velocity
  /// Initiate service
  late FlutterTts _ttsService;

  /// Create a stream trying to speak speed
  StreamSubscription? _ttsCallback;

  /// String that the tts will read aloud, Speed + Expanded Unit
  String get speakText {
    String unit;
    switch (widget.unit) {
      case 'km/h':
        unit = 'kilometers per hour';
        break;

      case 'miles/h':
        unit = 'miles per hour';
        break;

      case 'm/s':
      default:
        unit = 'meters per second';
        break;
    }
    return '${convertedVelocity(_velocity)!.toStringAsFixed(2)} $unit';
  }

  void _startTTS() {
    if (!_isTTSFemale) {
      _ttsService.setVoice({'name': 'en-us-x-tpd-local', 'locale': 'en-US'});
    } else {
      _ttsService.setVoice({'name': 'en-US-language', 'locale': 'en-US'});
    }

    _ttsCallback?.cancel();

    if (_isTTSActive) _ttsService.speak(speakText);
    _ttsCallback =
        Stream.periodic(_ttsDuration! + const Duration(seconds: 1)).listen(
      (event) {
        if (_isTTSActive) _ttsService.speak(speakText);
      },
    );
  }

  /// Should TTS be talking
  bool _isTTSActive = true;
  void setIsActive(bool isActive) => setState(
        () {
          _isTTSActive = isActive;
          _sharedPreferences?.setBool('isTTSActive', _isTTSActive);
          if (isActive) {
            _startTTS();
          } else {
            _ttsCallback?.cancel();
          }
        },
      );

  /// TTS gender
  bool _isTTSFemale = true;
  void setIsFemale(bool isFemale) => setState(
        () {
          _isTTSFemale = isFemale;
          _sharedPreferences?.setBool('isTTSFemale', _isTTSFemale);
          if (_isTTSActive) _startTTS();
        },
      );

  /// TTS talk duraiton
  Duration? _ttsDuration;
  void setDuration(int seconds) => setState(
        () {
          _ttsDuration = _secondsToDuration(seconds);
          _sharedPreferences?.setInt('ttsDuration', seconds);
          if (_isTTSActive) _startTTS();
        },
      );

  /// Utility function to deserialize saved Duration
  Duration _secondsToDuration(int seconds) {
    int minutes = (seconds / 60).floor();
    return Duration(minutes: minutes, seconds: seconds % 60);
  }

  // For velocity Tracking
  /// Geolocator is used to find velocity
  GeolocatorPlatform locator = GeolocatorPlatform.instance;

  /// Stream that emits values when velocity updates
  final StreamController<double?> _velocityUpdatedStreamController =
      StreamController<double?>();

  /// Current Velocity in m/s
  double? _velocity;

  /// Highest recorded velocity so far in m/s.
  double? _highestVelocity;

  /// Velocity in m/s to km/hr converter
  double mpstokmph(double mps) => mps * 18 / 5;

  /// Velocity in m/s to miles per hour converter
  double mpstomilesph(double mps) => mps * 85 / 38;

  /// Relevant velocity in chosen unit
  double? convertedVelocity(double? velocity) {
    velocity = velocity ?? _velocity;

    if (widget.unit == 'm/s') {
      return velocity;
    } else if (widget.unit == 'km/h') {
      return mpstokmph(velocity!);
    } else if (widget.unit == 'miles/h') {
      return mpstomilesph(velocity!);
    }
    return velocity;
  }

  @override
  void initState() {
    super.initState();
    // Speedometer functionality. Updates any time velocity chages.
    locator
        .getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
          ),
        )
        .listen(
          (Position position) => _onAccelerate(position.speed),
        );

    // Set velocities to zero when app opens
    _velocity = 0;
    _highestVelocity = 0.0;

    // Set up tts
    _ttsService = FlutterTts();
    _ttsService.setSpeechRate(1);

    // Load Saved values (or default values when no saved values)
    SharedPreferences.getInstance().then(
      (SharedPreferences prefs) {
        _sharedPreferences = prefs;
        _isTTSActive = prefs.getBool('isTTSActive') ?? true;
        _isTTSFemale = prefs.getBool('isTTSFemale') ?? true;
        _ttsDuration = _secondsToDuration(prefs.getInt('ttsDuration') ?? 3);
        // Start text to speech service
        _startTTS();
      },
    );
  }

  /// Callback that runs when velocity updates, which in turn updates stream.
  void _onAccelerate(double speed) {
    locator.getCurrentPosition().then(
      (Position updatedPosition) {
        _velocity = (speed + updatedPosition.speed) / 2;
        if (_velocity! > _highestVelocity!) _highestVelocity = _velocity;
        _velocityUpdatedStreamController.add(_velocity);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double gaugeBegin = 0, gaugeEnd = 200;

    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        // StreamBuilder updates Speedometer when new velocity recieved
        StreamBuilder<Object?>(
          stream: _velocityUpdatedStreamController.stream,
          builder: (context, snapshot) {
            return Speedometer(
              gaugeBegin: gaugeBegin,
              gaugeEnd: gaugeEnd,
              velocity: convertedVelocity(_velocity),
              maxVelocity: convertedVelocity(_highestVelocity),
              velocityUnit: widget.unit,
            );
          },
        ),
        TextToSpeechSettingsForm(
          isTTSActive: _isTTSActive,
          isTTSFemale: _isTTSFemale,
          currentDuration: _ttsDuration,
          activeSetter: setIsActive,
          femaleSetter: setIsFemale,
          durationSetter: setDuration,
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Velocity Stream
    _velocityUpdatedStreamController.close();
    // TTS
    _ttsCallback!.cancel();
    _ttsService.stop();
    super.dispose();
  }
}
