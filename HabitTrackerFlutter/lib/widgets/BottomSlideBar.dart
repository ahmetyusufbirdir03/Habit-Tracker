import 'package:flutter/material.dart';

class BottomIndicatorBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onButtonPressed;

  final String rightButtonName;
  final String leftButtonName;
  static const double _indicatorHeight = 3.0;
  final Color _indicatorColor = Colors.black;
  final Color _barColor;
  final Color _selectedTextColor;
  final Color _unselectedTextColor;

  const BottomIndicatorBar({
    super.key,
    required this.selectedIndex,
    required this.onButtonPressed,
    required this.rightButtonName,
    required this.leftButtonName,
    required Color barColor,
    required Color selectedTextColor,
    required Color unselectedTextColor,
  }) :
        _barColor = barColor,
        _selectedTextColor = selectedTextColor,
        _unselectedTextColor = unselectedTextColor;

  Widget _buildButton({
    required String label,
    required int index,
  }) {
    bool isSelected = index == selectedIndex;

    return ElevatedButton(
      onPressed: () => onButtonPressed(index),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        backgroundColor: _barColor,
        foregroundColor: isSelected ? _selectedTextColor : _unselectedTextColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 4), // biraz padding ekledik
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: _barColor,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 50 + _indicatorHeight,
        child: Column(
          children: [
            Container(
              height: _indicatorHeight,
              color: Colors.transparent,
              child: AnimatedAlign(
                alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: _indicatorHeight,
                    decoration: BoxDecoration(
                      color: _indicatorColor,
                      boxShadow: [
                        BoxShadow(
                          color: _indicatorColor,
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildButton(label: rightButtonName, index: 0),
                  ),
                  Expanded(
                    child: _buildButton(label: leftButtonName, index: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}