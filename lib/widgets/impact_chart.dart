import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ImpactChart extends StatefulWidget {
  const ImpactChart({super.key});

  @override
  State<ImpactChart> createState() => _ImpactChartState();
}

class _ImpactChartState extends State<ImpactChart> {
  bool _showTooltip = false;
  double _tooltipX = 0;
  double _tooltipY = 0;
  String _tooltipText = '';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Trigger the entry animation where spots rise up from 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF10B981);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartWidth = constraints.maxWidth;
        final double chartHeight = constraints.maxHeight;

        // Clamp positions to keep tooltip within bounds safely
        final double tooltipLeft = (_tooltipX - 50).clamp(8.0, chartWidth - 108.0);
        final double tooltipTop = (_tooltipY - 15).clamp(4.0, chartHeight - 40.0);

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 10),
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.transparent,
                      getTooltipItems: (touchedSpots) {
                        // Suppress standard tooltip box
                        return touchedSpots.map((spot) => null).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (!event.isInterestedForInteractions ||
                          touchResponse == null ||
                          touchResponse.lineBarSpots == null ||
                          touchResponse.lineBarSpots!.isEmpty) {
                        setState(() {
                          _showTooltip = false;
                        });
                        return;
                      }

                      final spot = touchResponse.lineBarSpots!.first;
                      final localPos = event.localPosition ?? Offset.zero;

                      String dayStr = '';
                      switch (spot.x.toInt()) {
                        case 0: dayStr = 'Seg'; break;
                        case 1: dayStr = 'Ter'; break;
                        case 2: dayStr = 'Qua'; break;
                        case 3: dayStr = 'Qui'; break;
                        case 4: dayStr = 'Sex'; break;
                        case 5: dayStr = 'Sab'; break;
                        case 6: dayStr = 'Dom'; break;
                      }

                      setState(() {
                        _showTooltip = true;
                        _tooltipX = localPos.dx;
                        _tooltipY = localPos.dy - 35;
                        _tooltipText = '$dayStr - meals: ${spot.y.toInt()}';
                      });
                    },
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFF1F5F9),
                        strokeWidth: 1.5,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('Seg', style: style);
                              break;
                            case 1:
                              text = const Text('Ter', style: style);
                              break;
                            case 2:
                              text = const Text('Qua', style: style);
                              break;
                            case 3:
                              text = const Text('Qui', style: style);
                              break;
                            case 4:
                              text = const Text('Sex', style: style);
                              break;
                            case 5:
                              text = const Text('Sab', style: style);
                              break;
                            case 6:
                              text = const Text('Dom', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _isLoaded
                          ? const [
                              FlSpot(0, 12),
                              FlSpot(1, 18),
                              FlSpot(2, 15),
                              FlSpot(3, 25),
                              FlSpot(4, 22),
                              FlSpot(5, 30),
                              FlSpot(6, 28),
                            ]
                          : const [
                              FlSpot(0, 0),
                              FlSpot(1, 0),
                              FlSpot(2, 0),
                              FlSpot(3, 0),
                              FlSpot(4, 0),
                              FlSpot(5, 0),
                              FlSpot(6, 0),
                            ],
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [greenColor, greenColor],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            greenColor.withValues(alpha: 0.3),
                            greenColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutBack,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              left: tooltipLeft,
              top: tooltipTop,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showTooltip ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _tooltipText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
