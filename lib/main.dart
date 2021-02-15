import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'speedometer_container.dart';

void main() {
  runApp(NoPermissionApp(hasCheckedPermissions: false));
  WidgetsFlutterBinding.ensureInitialized();

  Geolocator.checkPermission().then(
    (LocationPermission permission) {
      // App must be reinstalled to be used if permission denied forever.
      if (permission == LocationPermission.deniedForever)
        runApp(NoPermissionApp(hasCheckedPermissions: true));
      else // Run app and ask for permissions.
        runApp(SpeedometerApp());
    },
  );
}

class SpeedometerApp extends StatefulWidget {
  @override
  _SpeedometerAppState createState() => _SpeedometerAppState();
}

class _SpeedometerAppState extends State<SpeedometerApp> {
  /// Shared preferences to be loaded for persistence
  SharedPreferences sharedPreferences;

  /// Unit selection
  final List<String> units = const <String>['m/s', 'km/h', 'miles/h'];
  String currentSelectedUnit = 'm/s';

  void unitSelectorFunciton(String newUnit) => setState(
        () => currentSelectedUnit = newUnit,
      );

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then(
      (SharedPreferences prefs) {
        sharedPreferences = prefs;
        setState(
          () => currentSelectedUnit = (prefs.getString('unit') ?? 'm/s'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Voice Speedometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Speedometer',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          actions: units.map<Widget>((String unitType) {
            return UnitSelectionButton(
              unitButtonName: unitType,
              currentSelectedUnit: currentSelectedUnit,
              unitSelector: unitSelectorFunciton,
              sharedPreferences: sharedPreferences,
            );
          }).toList(),
        ),
        body: MainScreen(unit: currentSelectedUnit),
      ),
    );
  }
}

class UnitSelectionButton extends StatelessWidget {
  const UnitSelectionButton({
    Key key,
    this.unitButtonName = 'm/s',
    @required this.currentSelectedUnit,
    @required this.unitSelector,
    @required this.sharedPreferences,
  }) : super(key: key);

  final String unitButtonName, currentSelectedUnit;
  final void Function(String) unitSelector;

  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    final Color textColor = unitButtonName != currentSelectedUnit
        ? Colors.white
        : Color(0xFFE9A246);
    return Container(
      padding: EdgeInsets.only(right: 10),
      child: FlatButton(
        onPressed: () {
          unitSelector(unitButtonName);
          if (sharedPreferences != null)
            sharedPreferences.setString('unit', unitButtonName);
        },
        minWidth: 0,
        padding: EdgeInsets.zero,
        child: Text(unitButtonName, style: TextStyle(color: textColor)),
      ),
    );
  }
}

class NoPermissionApp extends StatelessWidget {
  const NoPermissionApp({
    Key key,
    @required bool hasCheckedPermissions,
  })  : _hasCheckedPermissions = hasCheckedPermissions ?? false,
        super(key: key);

  final bool _hasCheckedPermissions;

  @override
  Widget build(BuildContext context) {
    Widget outWidget;
    // Splash screen mode
    if (!_hasCheckedPermissions)
      outWidget = Image(
        image: AssetImage('images/splash_image.png'),
        alignment: Alignment.center,
        fit: BoxFit.contain,
      );
    // Error Message mode
    else
      outWidget = Text(
        'Location permissions permanently denied!\n' +
            'Please reinstall app and provide permissions!',
        style: TextStyle(
          color: Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      );
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: outWidget),
      ),
    );
  }
}
