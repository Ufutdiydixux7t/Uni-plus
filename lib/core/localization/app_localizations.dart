import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const _localizedValues = {
    'en': {
      'appTitle': 'UniPlus',
      'student': 'Student',
      'roleDelegate': 'Delegate',
      'admin': 'Admin',
      'selectRole': 'Select your role to continue',
      'classCode': 'Class Code',
      'submit': 'Submit',
      'addContent': 'Add Content',
      'title': 'Title',
      'description': 'Description',
      'uploadFile': 'Upload File',
      'save': 'Save',
      'cancel': 'Cancel',
      'lectures': 'Lectures',
      'dailyReports': 'Daily Reports',
      'summaries': 'Summaries',
      'tasks': 'Tasks',
      'grades': 'Grades',
      'forms': 'Forms',
      'assignments': 'Assignments',
      'language': 'Language',
      'logout': 'Logout',
      'welcome': 'Welcome',
      'noContent': 'No content available yet.',
      'tomorrowLectures': 'Tomorrow Lectures',
      'subject': 'Subject',
      'time': 'Time',
      'room': 'Room',
      'doctor': 'Doctor',
      'place': 'Place',
      'fullName': 'Full Name',
      'university': 'University',
      'faculty': 'Faculty / Department',
      'level': 'Level / Year',
      'addLecture': 'Add Lecture',
      'addAnnouncement': 'Add Announcement',
      'note': 'Optional Note',
      'sendSummary': 'Send Summary',
      'receivedSummaries': 'Received Summaries',
      'delete': 'Delete',
      'confirmDelete': 'Are you sure you want to delete this?',
    },
    'ar': {
      'appTitle': 'يوني بلس',
      'student': 'طالب',
      'roleDelegate': 'مندوب',
      'admin': 'مسؤول',
      'selectRole': 'اختر دورك للمتابعة',
      'classCode': 'رمز الفصل',
      'submit': 'إرسال',
      'addContent': 'إضافة محتوى',
      'title': 'العنوان',
      'description': 'الوصف',
      'uploadFile': 'رفع ملف',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'lectures': 'المحاضرات',
      'dailyReports': 'التقارير اليومية',
      'summaries': 'الملخصات',
      'tasks': 'المهام',
      'grades': 'الدرجات',
      'forms': 'النماذج',
      'assignments': 'التكاليف',
      'language': 'اللغة',
      'logout': 'تسجيل الخروج',
      'welcome': 'أهلاً بك',
      'noContent': 'لا يوجد محتوى متاح بعد.',
      'tomorrowLectures': 'محاضرات الغد',
      'subject': 'المادة',
      'time': 'الوقت',
      'room': 'القاعة',
      'doctor': 'الدكتور',
      'place': 'المكان',
      'fullName': 'الاسم الكامل',
      'university': 'الجامعة',
      'faculty': 'الكلية / القسم',
      'level': 'المستوى / السنة',
      'addLecture': 'إضافة محاضرة',
      'addAnnouncement': 'إضافة إعلان',
      'note': 'ملاحظة اختيارية',
      'sendSummary': 'إرسال ملخص',
      'receivedSummaries': 'الملخصات المستلمة',
      'delete': 'حذف',
      'confirmDelete': 'هل أنت متأكد من الحذف؟',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get student => _localizedValues[locale.languageCode]!['student']!;
  String get roleDelegate => _localizedValues[locale.languageCode]!['roleDelegate']!;
  String get admin => _localizedValues[locale.languageCode]!['admin']!;
  String get selectRole => _localizedValues[locale.languageCode]!['selectRole']!;
  String get classCode => _localizedValues[locale.languageCode]!['classCode']!;
  String get submit => _localizedValues[locale.languageCode]!['submit']!;
  String get addContent => _localizedValues[locale.languageCode]!['addContent']!;
  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get uploadFile => _localizedValues[locale.languageCode]!['uploadFile']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get lectures => _localizedValues[locale.languageCode]!['lectures']!;
  String get dailyReports => _localizedValues[locale.languageCode]!['dailyReports']!;
  String get summaries => _localizedValues[locale.languageCode]!['summaries']!;
  String get tasks => _localizedValues[locale.languageCode]!['tasks']!;
  String get grades => _localizedValues[locale.languageCode]!['grades']!;
  String get forms => _localizedValues[locale.languageCode]!['forms']!;
  String get assignments => _localizedValues[locale.languageCode]!['assignments']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get noContent => _localizedValues[locale.languageCode]!['noContent']!;
  String get tomorrowLectures => _localizedValues[locale.languageCode]!['tomorrowLectures']!;
  String get subject => _localizedValues[locale.languageCode]!['subject']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get room => _localizedValues[locale.languageCode]!['room']!;
  String get doctor => _localizedValues[locale.languageCode]!['doctor']!;
  String get place => _localizedValues[locale.languageCode]!['place']!;
  String get fullName => _localizedValues[locale.languageCode]!['fullName']!;
  String get university => _localizedValues[locale.languageCode]!['university']!;
  String get faculty => _localizedValues[locale.languageCode]!['faculty']!;
  String get level => _localizedValues[locale.languageCode]!['level']!;
  String get addLecture => _localizedValues[locale.languageCode]!['addLecture']!;
  String get addAnnouncement => _localizedValues[locale.languageCode]!['addAnnouncement']!;
  String get note => _localizedValues[locale.languageCode]!['note']!;
  String get sendSummary => _localizedValues[locale.languageCode]!['sendSummary']!;
  String get receivedSummaries => _localizedValues[locale.languageCode]!['receivedSummaries']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get confirmDelete => _localizedValues[locale.languageCode]!['confirmDelete']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
