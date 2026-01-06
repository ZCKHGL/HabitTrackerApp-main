import 'package:flutter/material.dart';

class WheelTimerPicker extends StatefulWidget {
  final Duration initial;
  final ValueChanged<Duration> onChanged;

  const WheelTimerPicker({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<WheelTimerPicker> createState() => _WheelTimerPickerState();
}

class _WheelTimerPickerState extends State<WheelTimerPicker> {
  late FixedExtentScrollController _hCtrl;
  late FixedExtentScrollController _mCtrl;
  late FixedExtentScrollController _sCtrl;

  static const _maxHour = 24;
  static const _maxMin = 59;
  static const _maxSec = 59;

  int _h = 0, _m = 0, _s = 0;

  @override
  void initState() {
    super.initState();
    _h = widget.initial.inHours.clamp(0, _maxHour);
    _m = widget.initial.inMinutes.remainder(60).clamp(0, _maxMin);
    _s = widget.initial.inSeconds.remainder(60).clamp(0, _maxSec);
    _hCtrl = FixedExtentScrollController(initialItem: _h);
    _mCtrl = FixedExtentScrollController(initialItem: _m);
    _sCtrl = FixedExtentScrollController(initialItem: _s);
  }

  void _emit() {
    final d = Duration(hours: _h, minutes: _m, seconds: _s);
    widget.onChanged(d);
  }

  Widget _wheel({
    required String label,
    required int count,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 44,
              perspective: 0.002,
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(count + 1, (i) {
                  return Center(
                    child: Text(
                      i.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 22),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
    // beri tinggi tetap agar tidak menyebabkan unbounded height di dalam ListView
    return SizedBox(
      height: 180,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(shape: border),
        child: Row(
          children: [
            _wheel(
              label: 'Jam',
              count: _maxHour,
              controller: _hCtrl,
              onChanged: (i) {
                setState(() => _h = i);
                _emit();
              },
            ),
            _wheel(
              label: 'Menit',
              count: _maxMin,
              controller: _mCtrl,
              onChanged: (i) {
                setState(() => _m = i);
                _emit();
              },
            ),
            _wheel(
              label: 'Detik',
              count: _maxSec,
              controller: _sCtrl,
              onChanged: (i) {
                setState(() => _s = i);
                _emit();
              },
            ),
          ],
        ),
      ),
    );
  }
}
