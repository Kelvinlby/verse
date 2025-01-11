import 'package:flutter/material.dart';


bool xlaPreAllocatingStatus = true;
int preAllocationRatio = 75;


class XlaController extends StatefulWidget {
  const XlaController({super.key});

  @override
  State<XlaController> createState() => _XlaControllerState();
}


class _XlaControllerState extends State<XlaController> {
  bool _xlaPreAllocatingStatus = true;
  int _preAllocationRatio = 75;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  'XLA Pre-Allocation',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono Bold',
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            Switch(
              value: _xlaPreAllocatingStatus,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (bool value) {
                setState(() {
                  _xlaPreAllocatingStatus = value;
                  xlaPreAllocatingStatus = _xlaPreAllocatingStatus;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_xlaPreAllocatingStatus) Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      'Allocation Ratio:  ${_preAllocationRatio.toString().padLeft(2, ' ')}%',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono Bold',
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _preAllocationRatio.toDouble(),
                  max: 99,
                  label: _preAllocationRatio.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _preAllocationRatio = value.round();
                      preAllocationRatio = _preAllocationRatio;
                    });
                  },
                ),
              ],
            )
        ),
      ],
    );
  }
}