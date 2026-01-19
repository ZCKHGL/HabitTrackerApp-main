// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Pencatat Kebiasaan';

  @override
  String get language => 'Bahasa';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get english => 'Inggris';

  @override
  String get settings => 'Pengaturan';

  @override
  String get add => 'Tambah';

  @override
  String get emptyHabit => 'Belum ada kebiasaan.\nTap + untuk menambahkan.';

  @override
  String get followSystem => 'Ikuti Tema Sistem';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get deleteHabit => 'Hapus Kebiasaan?';

  @override
  String deleteConfirm(Object habitName) {
    return 'Hapus \"$habitName\" beserta riwayatnya?';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String habitDeleted(Object habitName) {
    return 'Kebiasaan \"$habitName\" dihapus';
  }

  @override
  String get lightActivity => 'Aktivitas sedikit';

  @override
  String get highActivity => 'Aktivitas banyak';

  @override
  String get analytics => 'Analitik';

  @override
  String get history => 'Riwayat';

  @override
  String get noHistory => 'Belum ada riwayat';

  @override
  String get startCompletingHabits =>
      'Mulai menyelesaikan kebiasaan untuk melihat riwayat Anda';

  @override
  String get today => 'Hari Ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get addHabit => 'Tambah Kebiasaan';

  @override
  String get save => 'SIMPAN';

  @override
  String get habitNameEmpty => 'Nama kebiasaan tidak boleh kosong';

  @override
  String get habitCategory => 'Kategori Kebiasaan';

  @override
  String get goodHabit => 'Kebiasaan Baik';

  @override
  String get badHabit => 'Kebiasaan Buruk';

  @override
  String get colorAssigned => 'Warna ditugaskan secara otomatis';

  @override
  String get type => 'Tipe';

  @override
  String get untimed => 'Tanpa Waktu';

  @override
  String get timed => 'Dengan Waktu';

  @override
  String get target => 'Target';

  @override
  String get completed => 'Selesai';

  @override
  String get notCompleted => 'Belum Selesai';

  @override
  String get monthly => 'Bulanan';

  @override
  String get consistency => 'Konsistensi';

  @override
  String get streak => 'Rekor';

  @override
  String get percentage => 'Persentase';

  @override
  String get noData => 'Data tidak tersedia';

  @override
  String get january => 'Januari';

  @override
  String get february => 'Februari';

  @override
  String get march => 'Maret';

  @override
  String get april => 'April';

  @override
  String get may => 'Mei';

  @override
  String get june => 'Juni';

  @override
  String get july => 'Juli';

  @override
  String get august => 'Agustus';

  @override
  String get september => 'September';

  @override
  String get october => 'Oktober';

  @override
  String get november => 'November';

  @override
  String get december => 'Desember';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Agu';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Okt';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Des';

  @override
  String get useTimer => 'Gunakan Timer';

  @override
  String get setDuration => 'Atur Durasi';

  @override
  String get colorBlueAutomatic => 'Warna: Biru (otomatis untuk good habits)';

  @override
  String get colorRedAutomatic => 'Warna: Merah (otomatis untuk bad habits)';

  @override
  String get login => 'Masuk';

  @override
  String get logout => 'Keluar';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get loginSubtitle =>
      'Masuk untuk menyinkronkan kebiasaan Anda di berbagai perangkat';

  @override
  String get createAccountSubtitle =>
      'Buat akun untuk menyinkronkan kebiasaan Anda';

  @override
  String get loginSubtitleShort => 'Sinkronkan data di berbagai perangkat';

  @override
  String get noAccount => 'Belum punya akun?';

  @override
  String get haveAccount => 'Sudah punya akun?';

  @override
  String get guest => 'Tamu';

  @override
  String get guestDescription => 'Menggunakan aplikasi tanpa akun';

  @override
  String get logoutConfirm => 'Apakah Anda yakin ingin keluar?';

  @override
  String get emailRequired => 'Email wajib diisi';

  @override
  String get emailInvalid => 'Masukkan email yang valid';

  @override
  String get passwordRequired => 'Kata sandi wajib diisi';

  @override
  String get passwordTooShort => 'Kata sandi minimal 6 karakter';

  @override
  String get enterEmailFirst => 'Masukkan email Anda terlebih dahulu';

  @override
  String get passwordResetSent => 'Email reset kata sandi telah dikirim';

  @override
  String get accountCreated => 'Akun berhasil dibuat! Silakan masuk.';
}
