import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Speedometer extends StatelessWidget {
  const Speedometer({
    Key key,
    @required this.gaugeBegin,
    @required this.gaugeEnd,
    @required this.velocity,
    @required this.maxVelocity,
    @required this.velocityUnit,
  }) : super(key: key);

  final double gaugeBegin;
  final double gaugeEnd;
  final double velocity;
  final double maxVelocity;

  final String velocityUnit;

  final TextStyle _annotationTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: gaugeBegin,
          maximum: gaugeEnd,
          labelOffset: 30,
          axisLineStyle: AxisLineStyle(
            thicknessUnit: GaugeSizeUnit.factor,
            thickness: 0.03,
          ),
          majorTickStyle: MajorTickStyle(
            length: 6,
            thickness: 4,
            color: Colors.white,
          ),
          minorTickStyle: MinorTickStyle(
            length: 3,
            thickness: 3,
            color: Colors.white,
          ),
          axisLabelStyle: GaugeTextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: gaugeBegin,
              endValue: gaugeEnd,
              sizeUnit: GaugeSizeUnit.factor,
              startWidth: 0.03,
              endWidth: 0.03,
              gradient: SweepGradient(
                colors: const <Color>[
                  Colors.green,
                  Colors.yellow,
                  Colors.red,
                ],
                stops: const <double>[0.0, 0.5, 1],
              ),
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: maxVelocity,
              needleLength: 0.95,
              enableAnimation: true,
              animationType: AnimationType.ease,
              needleStartWidth: 1.5,
              needleEndWidth: 6,
              needleColor: Colors.white54,
              knobStyle: KnobStyle(knobRadius: 0.09),
            ),
            NeedlePointer(
              value: velocity,
              needleLength: 0.95,
              enableAnimation: true,
              animationType: AnimationType.ease,
              needleStartWidth: 1.5,
              needleEndWidth: 6,
              needleColor: Colors.red,
              knobStyle: KnobStyle(knobRadius: 0.09),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      velocity.toStringAsFixed(2),
                      style: _annotationTextStyle.copyWith(fontSize: 25),
                    ),
                    SizedBox(width: 10),
                    Text(velocityUnit, style: _annotationTextStyle),
                  ],
                ),
              ),
              angle: 90,
              positionFactor: 0.75,
            )
          ],
        ),
      ],
    );
  }
}