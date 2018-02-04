import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:yjournal/models.dart';
import 'package:yjournal/selectors.dart';
import 'package:yjournal/actions.dart';

typedef void DateScrollCallback(DateTime newDate, ScrollController scrollController, PageController pageController);

const Duration _kMonthScrollDuration = const Duration(milliseconds: 200);
const double kDayPickerRowHeight = 24.0;
const double _kDayPickerHeaderPadding = 4.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight = kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2) + 2 * _kDayPickerHeaderPadding;

const int _kAnimationDuration = 500;

class MonthlyPicker extends StatelessWidget {
  final DateTime currentDate;
  final ScrollController scrollController;
  final ScrollController pageController;

  MonthlyPicker({
    Key key,
    @required this.currentDate,
    @required this.scrollController,
    @required this.pageController,
  }) : super(key: key);

  static int monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
  }

  static DateTime indexToDateTime(int index) {
    int start = 1980;
    int monthRemainder = index % 12;
    return new DateTime((start+((index-monthRemainder)/12).truncate()), monthRemainder+1);
  }

  static int dateTimeToIndex(DateTime dateTime) {
    int start = 1980;
    return (dateTime.year - start) * 12 + dateTime.month - 1;
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, _ViewModel vm) {
        return new _View(
          currentDate: currentDate,
          entryDates: vm.entryDates,
          selectedDate: vm.selectedDate,
          onDateChange: (newDate) => vm.onDateChange(newDate, scrollController, pageController),
          pageController: pageController,
        );
      },
    );
  }
}

class _ViewModel {
  final List<DateTime> entryDates;
  final DateTime selectedDate;
  final DateScrollCallback onDateChange;

  _ViewModel({
    @required this.entryDates,
    @required this.selectedDate,
    @required this.onDateChange,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      entryDates: entryDatesSelector(store.state),
      selectedDate: selectedDateSelector(store.state),
      onDateChange: (DateTime newDate, ScrollController scrollController, PageController pageController) {
        store.dispatch(new UpdateSelectedDateAction(newDate));
        //below is num of date headers before selected date
        int i = dateMappedEntriesSelector(store.state).keys.toList().reversed.toList().indexOf(newDate);
        //below is num of entries before the selected date
        int j = -1;
        if (i > -1) j = dateMappedEntriesSelector(store.state).values.toList().reversed.toList().sublist(0,i).fold<int>(0, (int value, List<Entry> e) => value + e.length);
        if (j > -1) scrollController.animateTo(i*32.0+j*60.0, duration: new Duration(milliseconds: _kAnimationDuration), curve: Curves.easeOut);

        pageController.animateToPage(MonthlyPicker.dateTimeToIndex(newDate), curve: Curves.easeOut, duration: new Duration(milliseconds: _kAnimationDuration));
      },
    );
  }
}

class _View extends StatefulWidget {
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChange;
  final List<DateTime> entryDates;
  final DateTime selectedDate;
  final PageController pageController;

  _View({
    Key key,
    @required this.currentDate,
    @required this.onDateChange,
    @required this.entryDates,
    @required this.selectedDate,
    @required this.pageController
  }) : super(key: key);

  @override
  _ViewState createState() => new _ViewState();
}

class _ViewState extends State<_View> {

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    //widget.pageController.init _monthDelta(new DateTime(widget.firstDate), widget.selectedDate));
  }

    /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  List<Widget> _getDayHeaders(TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(new Expanded(
          child: new Container(
            height: kDayPickerRowHeight,
            child: new Center(child: new Text(weekday, style: headerStyle))
          )
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7)
        break;
    }
    return result;
  }

  // Do not use this directly - call getDaysInMonth instead.
  static const List<int> _kDaysInMonth = const <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.FEBRUARY) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear)
        return 29;
      return 28;
    }
    return _kDaysInMonth[month - 1];
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  int _computeFirstDayOffset(int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = new DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

Widget _buildMonth(BuildContext context, int index) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final int year = MonthlyPicker.indexToDateTime(index).year;
    final int month = MonthlyPicker.indexToDateTime(index).month;
    final int daysInMonth = getDaysInMonth(year, month);
    final int firstDayOffset = _computeFirstDayOffset(year, month, localizations);
    final List<Widget> labels = <Widget>[];
    labels.addAll(_getDayHeaders(themeData.textTheme.caption, localizations));
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth && i % DateTime.DAYS_PER_WEEK == 0)
        break;
      if (day < 1 || day > daysInMonth) {
        labels.add(new Expanded(child: new Container()));
      } else {
        final DateTime dayToBuild = new DateTime(year, month, day);
        final bool isFilled = widget.entryDates != null && widget.entryDates.contains(dayToBuild);
        final bool isSelected = widget.selectedDate != null && widget.selectedDate.year == year && widget.selectedDate.month == month && widget.selectedDate.day == day;

        BoxDecoration decoration;
        TextStyle itemStyle = themeData.textTheme.body1;

        if (isSelected) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          decoration = new BoxDecoration(
              color: themeData.accentColor,
              shape: BoxShape.circle
          );
        } else if (widget.currentDate.year == year && widget.currentDate.month == month && widget.currentDate.day == day) {
          // The current day gets a different text color.
          itemStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        }

        Widget dayWidget = new Container(
          decoration: decoration,
          height: kDayPickerRowHeight,
          child: new Padding(
            padding: new EdgeInsets.symmetric(vertical: 4.0),
            child: new Column(
                children: <Widget>[
                  new Text(day.toString(), style: isFilled ? itemStyle.copyWith(fontWeight: FontWeight.bold) : itemStyle),
                ]
            ),
          ),
        );

        dayWidget = new Expanded(
          child: new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.onDateChange(dayToBuild);
            },
            child: dayWidget,
          ),
        );

        labels.add(dayWidget);
      }
    }

    final List<Widget> dayRows = [];
    for (int i = 0; i < labels.length/DateTime.DAYS_PER_WEEK; i += 1) {
      dayRows.add( new Row(
        children: labels.sublist(i*DateTime.DAYS_PER_WEEK, (i+1)*DateTime.DAYS_PER_WEEK),
      ));
    }
    return new Column(
      children: <Widget>[
        new Container(
          height: kDayPickerRowHeight,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(localizations.formatMonthYear(new DateTime(year, month)),
                style: themeData.textTheme.subhead,
              ),
            ]
          ),
        ),
      ]..addAll(dayRows)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      height: _kMaxDayPickerHeight,
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: _kDayPickerHeaderPadding),
        child: new Stack(
          children: <Widget>[
            new PositionedDirectional(
              child: new PageView.builder(
                controller: widget.pageController,
                itemBuilder: _buildMonth,
              ),
            ),
            new PositionedDirectional(
              start: 8.0,
              height: kDayPickerRowHeight,
              child: new IconButton(
                  icon: new Icon(Icons.arrow_left),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    widget.pageController.previousPage(duration: _kMonthScrollDuration, curve: Curves.ease);
                  }
              ),
            ),
            new PositionedDirectional(
              end: 8.0,
              height: kDayPickerRowHeight,
              child: new IconButton(
                  icon: new Icon(Icons.arrow_right),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    widget.pageController.nextPage(duration: _kMonthScrollDuration, curve: Curves.ease);
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}