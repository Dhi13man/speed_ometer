import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:gender_selection/gender_selection.dart';

class TextToSpeechSettingsForm extends StatelessWidget {
  TextToSpeechSettingsForm({
    @required this.isTTSActive,
    @required this.isTTSFemale,
    @required this.currentDuration,
    @required this.activeSetter,
    @required this.femaleSetter,
    @required this.durationSetter,
    Key key,
  }) : super(key: key);

  final bool isTTSActive;
  final bool isTTSFemale;
  final Duration currentDuration;

  final void Function(bool) activeSetter;
  final void Function(bool) femaleSetter;
  final void Function(int) durationSetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 0, left: 25, right: 25),
      padding: EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
      width: MediaQuery.of(context).size.width / 2 - 20,
      height: MediaQuery.of(context).size.height / 2 - 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color(0xFF252222),
      ),
      alignment: Alignment.center,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Narrate the Speed:  ',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Switch(
                value: isTTSActive,
                onChanged: (bool newIsActive) => activeSetter(newIsActive),
                activeColor: Color(0xFFE9A246),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: FlatButton(
              color: const Color(0xFFD68822),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              onPressed: () => showDialog(
                context: context,
                child: AlertDialog(
                  backgroundColor: const Color(0xFF252222),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Center(
                    child: Text(
                      'Choose Minutes : Seconds',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  content: TimeForm(
                    currentMinutes: (currentDuration?.inMinutes ?? 0) % 60,
                    currentSeconds: (currentDuration?.inSeconds ?? 3) % 60,
                    durationSetter: durationSetter,
                    parentScaffold: Scaffold.of(context),
                  ),
                ),
              ),
              child: const Text(
                'Update Narration Frequency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GenderSelection(
            selectedGender: (isTTSFemale) ? Gender.Female : Gender.Male,
            unSelectedGenderTextStyle: TextStyle(color: Colors.white),
            onChanged: (Gender gender) {
              bool isFemale = gender == Gender.Female;
              femaleSetter(isFemale);
            },
            size: 70,
            padding: const EdgeInsets.all(0),
          ),
        ],
      ),
    );
  }
}

class TimeForm extends StatefulWidget {
  TimeForm(
      {Key key,
      @required int currentSeconds,
      @required int currentMinutes,
      @required this.durationSetter,
      @required this.parentScaffold})
      : _currentMinutes = currentMinutes,
        _currentSeconds = currentSeconds,
        super(key: key);

  final int _currentSeconds, _currentMinutes;
  final void Function(int) durationSetter;

  final ScaffoldState parentScaffold;

  @override
  _TimeFormState createState() => _TimeFormState();
}

class _TimeFormState extends State<TimeForm> {
  int _currentSeconds, _currentMinutes;

  @override
  void initState() {
    super.initState();
    _currentMinutes = widget._currentMinutes;
    _currentSeconds = widget._currentSeconds;
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle selectedTextStyle = TextStyle(
          color: Color(0xFFE9A246),
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        unselectedTextStyle = TextStyle(color: Colors.white38, fontSize: 20);
    return Container(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new NumberPicker.integer(
                zeroPad: true,
                selectedTextStyle: selectedTextStyle,
                textStyle: unselectedTextStyle,
                listViewWidth: 65,
                initialValue: _currentMinutes,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) => setState(() => _currentMinutes = value),
              ),
              Text(
                ':',
                style: TextStyle(fontSize: 25, color: Colors.white24),
              ),
              new NumberPicker.integer(
                zeroPad: true,
                selectedTextStyle: selectedTextStyle,
                textStyle: unselectedTextStyle,
                listViewWidth: 65,
                initialValue: _currentSeconds,
                minValue: 3,
                maxValue: 59,
                onChanged: (value) => setState(() => _currentSeconds = value),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: FlatButton(
              color: Color(0xFF086624),
              padding: EdgeInsets.all(15),
              onPressed: () {
                widget.parentScaffold.hideCurrentSnackBar();

                int minutes = _currentMinutes;
                int seconds = _currentSeconds % 60;
                int convertedTime = minutes * 60 + seconds;
                if (seconds > 60) {
                  widget.parentScaffold.showSnackBar(
                    SnackBar(
                      content: Text('Please convert to minutes!'),
                    ),
                  );
                  return null;
                } else if (seconds < 0) {
                  widget.parentScaffold.showSnackBar(
                    SnackBar(
                      content: Text('Please enter postive time!'),
                    ),
                  );
                  return null;
                }
                if (seconds > 60) {
                  widget.parentScaffold.showSnackBar(
                    SnackBar(
                      content: Text('Enter between 1 and 60 minutes!'),
                    ),
                  );
                  return null;
                } else if (seconds < 0) {
                  widget.parentScaffold.showSnackBar(
                    SnackBar(
                      content: Text('Please enter postive time!'),
                    ),
                  );
                  return null;
                }
                if (convertedTime < 3) {
                  widget.parentScaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Minimum time should be 3 seconds to avoid overlap!',
                      ),
                    ),
                  );
                  return null;
                }
                widget.durationSetter(convertedTime);
                Navigator.of(context).pop();
              },
              child: Text(
                'Update Frequency',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
