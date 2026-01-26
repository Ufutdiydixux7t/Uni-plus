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
      'delegate': 'Delegate',
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
      'materials': 'Materials',
      'summaries': 'Summaries',
      'tasks': 'Tasks',
      'grades': 'Grades',
      'forms': 'Forms',
      'assignments': 'Assignments',
      'language': 'Language',
      'logout': 'Logout',
      'welcome': 'Welcome',
      'noContent': 'No content available yet.',
    },
    'ar': {
      'appTitle': 'يوني بلس',
      'student': 'طالب',
      'delegate': 'مندوب',
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
      'materials': 'المصادر',
      'summaries': 'الملخصات',
      'tasks': 'المهام',
      'grades': 'الدرجات',
      'forms': 'النماذج',
      'assignments': 'التكاليف',
      'language': 'اللغة',
      'logout': 'تسجيل الخروج',
      'welcome': 'أهلاً بك',
      'noContent': 'لا يوجد محتوى متاح بعد.',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get student => _localizedValues[locale.languageCode]!['student']!;
  String get delegate => _localizedValues[locale.languageCode]!['delegate']!;
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
  String get materials => _localizedValues[locale.languageCode]!['materials']!;
  String get summaries => _localizedValues[locale.languageCode]!['summaries']!;
  String get tasks => _localizedValues[locale.languageCode]!['tasks']!;
  String get grades => _localizedValues[locale.languageCode]!['grades']!;
  String get forms => _localizedValues[locale.languageCode]!['forms']!;
  String get assignments => _localizedValues[locale.languageCode]!['assignments']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get noContent => _localizedValues[locale.languageCode]!['noContent']!;
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
