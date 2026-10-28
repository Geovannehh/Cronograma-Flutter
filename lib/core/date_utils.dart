import 'package:flutter/material.dart';

const monthsPt = <String>[
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];
const daysPt = <String>[
  'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo',
];
const shortDaysPt = <String>['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
DateTime weekStart(DateTime date) =>
    dateOnly(date).subtract(Duration(days: date.weekday - 1));
DateTime weekEnd(DateTime date) => weekStart(date).add(const Duration(days: 6));
DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);
DateTime addMonths(DateTime date, int months) =>
    DateTime(date.year, date.month + months, 1);
String twoDigits(int value) => value.toString().padLeft(2, '0');
String formatDate(DateTime date) =>
    '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
String formatTime(DateTime date) =>
    '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
String formatLongDate(DateTime date) =>
    '${date.day} de ${monthsPt[date.month - 1]} de ${date.year}';
String formatWeekdayDate(DateTime date) =>
    '${daysPt[date.weekday - 1]}, ${date.day} de ${monthsPt[date.month - 1]}';
String formatMonthYear(DateTime date) =>
    '${monthsPt[date.month - 1][0].toUpperCase()}${monthsPt[date.month - 1].substring(1)} ${date.year}';
DateTime combineDateAndTime(DateTime date, TimeOfDay time) =>
    DateTime(date.year, date.month, date.day, time.hour, time.minute);
TimeOfDay timeOf(DateTime date) =>
    TimeOfDay(hour: date.hour, minute: date.minute);
String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Bom dia!';
  if (now.hour < 18) return 'Boa tarde!';
  return 'Boa noite!';
}
