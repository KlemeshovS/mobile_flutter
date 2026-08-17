// lib/screens/day_selection/day_selection_sheet.dart
import 'package:flutter/material.dart';
import 'package:wobbly/models/day_record.dart';
import 'package:wobbly/models/day_data.dart';
import 'package:wobbly/models/drink_level.dart';
import 'package:wobbly/models/drink_trigger.dart';
import 'package:wobbly/app/theme.dart';
import 'package:wobbly/utils/localization.dart';

class DaySelectionSheet extends StatefulWidget {
  final DayData dayData;
  final DayRecord currentRecord;
  final List<DrinkTrigger> currentTriggers;
  final Function(DayRecord) onRecordSelected;
  final Function(Set<DrinkTrigger>) onTriggersSelected;

  const DaySelectionSheet({
    super.key,
    required this.dayData,
    required this.currentRecord,
    this.currentTriggers = const [],
    required this.onRecordSelected,
    required this.onTriggersSelected,
  });

  @override
  State<DaySelectionSheet> createState() => _DaySelectionSheetState();
}

class _DaySelectionSheetState extends State<DaySelectionSheet> {
  late DrinkLevel _selectedDrinkLevel;
  late bool _hasSport;
  late Set<DrinkTrigger> _selectedTriggers;
  final double _normalSize = 45.0;
  final double _selectedSize = 55.0;

  bool get _isAlcoholDay =>
      _selectedDrinkLevel == DrinkLevel.little ||
      _selectedDrinkLevel == DrinkLevel.medium ||
      _selectedDrinkLevel == DrinkLevel.heavy;

  @override
  void initState() {
    super.initState();
    _selectedDrinkLevel = widget.currentRecord.drinkLevel;
    _hasSport = widget.currentRecord.hasSport;
    _selectedTriggers = Set.from(widget.currentTriggers);
  }

  void _onTriggerToggled(DrinkTrigger trigger) {
    setState(() {
      if (_selectedTriggers.contains(trigger)) {
        _selectedTriggers.remove(trigger);
      } else {
        _selectedTriggers.add(trigger);
      }
    });
  }

  void _onDrinkLevelSelected(DrinkLevel level) {
    setState(() {
      if (_selectedDrinkLevel == level) {
        // Снимаем алкоголь – если спорт есть, устанавливаем none, иначе unknown
        _selectedDrinkLevel = _hasSport ? DrinkLevel.none : DrinkLevel.unknown;
      } else {
        _selectedDrinkLevel = level;
      }
    });
  }

  void _onSportSelected() {
    setState(() {
      _hasSport = !_hasSport;
      // Если спорт включили, а алкоголь был unknown, то меняем на none
      if (_hasSport && _selectedDrinkLevel == DrinkLevel.unknown) {
        _selectedDrinkLevel = DrinkLevel.none;
      }
      // Если спорт выключили и алкоголя нет, то unknown
      if (!_hasSport && _selectedDrinkLevel == DrinkLevel.none) {
        _selectedDrinkLevel = DrinkLevel.unknown;
      }
    });
  }

  void _saveAndClose() {
    final record = DayRecord(
      drinkLevel: _selectedDrinkLevel,
      hasSport: _hasSport,
    );
    widget.onRecordSelected(record);
    // Триггеры имеют смысл только для дней с алкоголем.
    widget.onTriggersSelected(_isAlcoholDay ? _selectedTriggers : {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (_isAlcoholDay ? 0.7 : 0.45),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2D2B55),
            Color(0xFF7B68EE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false, // защищаем только от навигационной панели снизу
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Индикатор для перетаскивания
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Выбор алкоголя
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    localizations.drinkPrompt,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Кнопки уровней алкоголя
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDrinkLevelButton(
                          DrinkLevel.little, localizations.littleLabel),
                      _buildDrinkLevelButton(
                          DrinkLevel.medium, localizations.mediumLabel),
                      _buildDrinkLevelButton(
                          DrinkLevel.heavy, localizations.heavyLabel),
                    ],
                  ),
                ],
              ),
            ),

            // Разделитель
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white.withOpacity(0.1),
            ),

            // Выбор спорта
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    localizations.sportPrompt,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Кнопка спорта
                  _buildSportButton(localizations.sportLabel),
                ],
              ),
            ),

            // Триггеры (только для алкогольных дней)
            if (_isAlcoholDay) ...[
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white.withOpacity(0.1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.triggerPrompt,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DrinkTrigger.values.map(_buildTriggerChip).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Кнопка ОК
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: _saveAndClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF8B5CF6),
                  minimumSize: Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  localizations.okButton,
                  style: TextStyle(
                    fontFamily: 'Inter',
                  fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildDrinkLevelButton(DrinkLevel level, String label) {
    final isSelected = _selectedDrinkLevel == level;
    final size = isSelected ? _selectedSize : _normalSize;

    String imagePath;
    switch (level) {
      case DrinkLevel.little:
        imagePath = 'assets/images/little.png';
        break;
      case DrinkLevel.medium:
        imagePath = 'assets/images/medium.png';
        break;
      case DrinkLevel.heavy:
        imagePath = 'assets/images/heavy.png';
        break;
      case DrinkLevel.none:
      default:
        imagePath = 'assets/images/little.png';
    }

    return SizedBox(
      width: 80,
      child: GestureDetector(
        onTap: () => _onDrinkLevelSelected(level),
        child: Column(
          children: [
            Container(
              width: _selectedSize,
              height: _selectedSize,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: isSelected
                      ? Border.all(
                    color: Color(0xFF8B5CF6),
                    width: 3,
                  )
                      : null,
                ),
                child: Image.asset(
                  imagePath,
                  width: isSelected ? 30 : 24,
                  height: isSelected ? 30 : 24,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerChip(DrinkTrigger trigger) {
    final localizations = AppLocalizations.of(context);
    final isSelected = _selectedTriggers.contains(trigger);
    return GestureDetector(
      onTap: () => _onTriggerToggled(trigger),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF8B5CF6).withOpacity(0.3) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF8B5CF6) : Colors.white.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          localizations.translate(trigger.localizationKey),
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSportButton(String sportLabel) {
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: _onSportSelected,
        child: Column(
          children: [
            Container(
              width: _selectedSize,
              height: _selectedSize,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: _hasSport ? _selectedSize : _normalSize,
                height: _hasSport ? _selectedSize : _normalSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC7FF00).withOpacity(_hasSport ? 0.3 : 0.1),
                  border: _hasSport
                      ? Border.all(
                    color: Color(0xFFC7FF00),
                    width: 3,
                  )
                      : Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.directions_run,
                  color: _hasSport
                      ? Color(0xFFC7FF00)
                      : Colors.white.withOpacity(0.7),
                  size: _hasSport ? 30 : 24,
                ),
              ),
            ),
            SizedBox(height: 6),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}