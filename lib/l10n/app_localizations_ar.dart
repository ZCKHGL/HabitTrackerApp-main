// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع العادات';

  @override
  String get language => 'اللغة';

  @override
  String get indonesian => 'إندونيسيا';

  @override
  String get english => 'الإنجليزية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get add => 'إضافة';

  @override
  String get emptyHabit => 'لا توجد عادات حتى الآن.\nانقر + لإضافة واحدة.';

  @override
  String get followSystem => 'اتبع موضوع النظام';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get deleteHabit => 'حذف العادة؟';

  @override
  String deleteConfirm(Object habitName) {
    return 'حذف \"$habitName\" وسجلها؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String habitDeleted(Object habitName) {
    return 'تم حذف العادة \"$habitName\"';
  }

  @override
  String get lightActivity => 'نشاط خفيف';

  @override
  String get highActivity => 'نشاط عالي';

  @override
  String get analytics => 'التحليلات';

  @override
  String get history => 'السجل';

  @override
  String get noHistory => 'لا يوجد سجل حتى الآن';

  @override
  String get startCompletingHabits =>
      'ابدأ بإتمام العادات لرؤية السجل الخاص بك';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get addHabit => 'إضافة عادة';

  @override
  String get save => 'حفظ';

  @override
  String get habitNameEmpty => 'لا يمكن أن يكون اسم العادة فارغًا';

  @override
  String get habitCategory => 'فئة العادة';

  @override
  String get goodHabit => 'عادة جيدة';

  @override
  String get badHabit => 'عادة سيئة';

  @override
  String get colorAssigned => 'تم تعيين اللون تلقائيًا';

  @override
  String get type => 'النوع';

  @override
  String get untimed => 'بدون وقت';

  @override
  String get timed => 'محدود الوقت';

  @override
  String get target => 'الهدف';

  @override
  String get completed => 'مكتمل';

  @override
  String get notCompleted => 'لم يكتمل';

  @override
  String get monthly => 'شهري';

  @override
  String get consistency => 'الاتساق';

  @override
  String get streak => 'المسلسل';

  @override
  String get percentage => 'النسبة المئوية';

  @override
  String get noData => 'لا توجد بيانات متاحة';

  @override
  String get january => 'يناير';

  @override
  String get february => 'فبراير';

  @override
  String get march => 'مارس';

  @override
  String get april => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get june => 'يونيو';

  @override
  String get july => 'يوليو';

  @override
  String get august => 'أغسطس';

  @override
  String get september => 'سبتمبر';

  @override
  String get october => 'أكتوبر';

  @override
  String get november => 'نوفمبر';

  @override
  String get december => 'ديسمبر';

  @override
  String get jan => 'ينا';

  @override
  String get feb => 'فبر';

  @override
  String get mar => 'مار';

  @override
  String get apr => 'أبر';

  @override
  String get jun => 'يون';

  @override
  String get jul => 'يول';

  @override
  String get aug => 'أغس';

  @override
  String get sep => 'سبت';

  @override
  String get oct => 'أكت';

  @override
  String get nov => 'نوف';

  @override
  String get dec => 'ديس';

  @override
  String get useTimer => 'استخدم المؤقت';

  @override
  String get setDuration => 'تعيين المدة';

  @override
  String get colorBlueAutomatic => 'اللون: أزرق (تلقائي للعادات الجيدة)';

  @override
  String get colorRedAutomatic => 'اللون: أحمر (تلقائي للعادات السيئة)';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginSubtitle => 'قم بتسجيل الدخول لمزامنة عاداتك عبر الأجهزة';

  @override
  String get createAccountSubtitle => 'أنشئ حسابًا لمزامنة عاداتك';

  @override
  String get loginSubtitleShort => 'مزامنة بياناتك عبر الأجهزة';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get guest => 'ضيف';

  @override
  String get guestDescription => 'استخدام التطبيق بدون حساب';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get enterEmailFirst => 'الرجاء إدخال بريدك الإلكتروني أولاً';

  @override
  String get passwordResetSent => 'تم إرسال بريد إعادة تعيين كلمة المرور';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول.';
}
