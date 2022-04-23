import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'app_theme.dart';

class Constants {
  // ---------------------------------------------------------------------------
  // APP
  // ---------------------------------------------------------------------------

  static const String companyName = 'Academic Course';
  static const String companyLogo = 'assets/images/logo.png';

  static const String supportEmail = 'academic.service@zonapakar.com';
  static const String dummyPict = 'https://dummyimage.com/600x400/cfcfcf/fff';

  // ---------------------------------------------------------------------------
  // WEBHOST APIs
  // ---------------------------------------------------------------------------

  static const String endpointNoPrefix = 'cat.bimtekacpi.com';
  static const String baseEndpoint = 'https://$endpointNoPrefix/id/api';

  // ---------------------------------------------------------------------------
  // LOCAL APIs
  // ---------------------------------------------------------------------------

  // static const String endpointNoPrefix = '192.168.43.95'; // CELLULAR
  // static const String endpointNoPrefix = '192.168.100.7'; // INDIHOME
  // static const String endpointNoPrefix = '127.0.0.1'; // LOCAL
  // static const String baseEndpoint =
  //     'http://$endpointNoPrefix/github/Bimbel/web_api_aplikasi_ujian/public/id/api';

  // ---------------------------------------------------------------------------
  // APIs Resources
  // ---------------------------------------------------------------------------

  static const String loginEndpoint = '$baseEndpoint/login';
  static const String credentialsEndpoint = '$baseEndpoint/credentials';

  // LESSONS
  static const String lessonsEndpoint = '$baseEndpoint/lessons';
  static const String lessonsBooksEndpoint =
      '$baseEndpoint/lessons/{key}/books';
  static const String lessonQuestionsEndpoint =
      '$lessonsEndpoint/{key}/questions';
  static const String lessonQuizzesEndpoint = '$lessonsEndpoint/{key}/quizzes';
  static const String lessonAttemptsEndpoint = '$baseEndpoint/lesson-attempts';
  static const String lessonAttemptQuestionsEndpoint =
      '$lessonAttemptsEndpoint/{key}/questions';
  static const String lessonAttemptQuizzesEndpoint =
      '$lessonAttemptsEndpoint/{key}/quizzes';

  // BOOKS
  static const String booksEndpoint = '$baseEndpoint/books';

  // QUIZZES
  static const String quizzesEndpoint = '$baseEndpoint/quizzes';
  static const String quizQuestionsEndpoint =
      '$quizzesEndpoint/{key}/questions';
  static const String quizAttemptsEndpoint = '$baseEndpoint/quiz-attempts';
  static const String quizAttemptQuestionsEndpoint =
      '$quizAttemptsEndpoint/{key}/questions';

  // CLASSROOMS
  static const String classroomsEndpoint = '$baseEndpoint/classrooms';
  static const String classroomLessonsEndpoint =
      '$classroomsEndpoint/{key}/lessons';
  static const String classroomParticipantsEndpoint =
      '$classroomsEndpoint/{key}/participants';

  // USERS
  static const String usersEndpoint = '$baseEndpoint/users';
  static const String userClassroomsEndpoint =
      '$usersEndpoint/{key}/classrooms';

  // QUESTIONS
  static const String questionAttemptsEndpoint =
      '$baseEndpoint/question-attempts';

  // PROVINCES
  static const String provincesEndpoint = '$baseEndpoint/provinces';
  static const String provinceCitiesEndpoint =
      '$provincesEndpoint/{key}/cities';

  // CATEGORIES
  static const String categoriesEndpoint = '$baseEndpoint/categories';

  // ---------------------------------------------------------------------------
  // LOCAL KEYs
  // ---------------------------------------------------------------------------

  // Local Storage
  static const String skipOnboardKey = 'skipOnboard';
  static const String tokenKey = 'authenticationToken';
  static const String userIdKey = 'userIdKey';
  static const String userKey = 'userKey';
  static const String isAuthenticatedKey = 'isUserAuthenticated';
  static const String emailSentKey = 'emailSent';

  // Form Name
  static const String emailField = 'email';
  static const String fullnameField = 'fullname';
  static const String essayField = 'essay';
  static const String addressField = 'address';
  static const String genderField = 'gender';
  static const String phoneField = 'phone';
  static const String passwordField = 'password';
  static const String unameField = 'uname';
  static const String usernameField = 'username';
  static const String secureKeyField = 'securekey';
}

class Strings {
  static const String getLocalPrefsFailed = 'Gagal memuat data lokal.';
  static const String requestFailed =
      'Terjadi kesalahan komunikasi dengan server.';
  static const String noConnection =
      'Kesalahan koneksi, pastikan jaringan stabil.';
  static const String serverError = 'Server mengalami masalah tidak terduga.';
  static const String unexpectedError = 'Kesalahan tidak terduga.';
  static const String unstableNetwork =
      'Koneksi tidak stabil, permitaan gagal diteruskan.';
  static const String waitingResponse = 'Menunggu tanggapan...';
  static const String loading = 'Memuat...';
  static const String signInOverTry =
      'Terlalu banyak percobaan untuk masuk, coba beberapa saat lagi.';
  static const String loadConnection = 'Menunggu koneksi...';

  static const String checkEmail =
      'Periksa surel {email} dan konfirmasi tautan yang dikirim untuk validasi akun.';
  static const String registrationSuccessful = 'Registrasi berhasil!';
  static const String gotoSignIn = 'Lanjutkan untuk masuk.';
  static const String emptyClassrooms =
      'Beritahu kami segera, atau hubungi layanan untuk bergabung dengan ruang tes sekarang juga.';
  static const String emptyLessons =
      'Beritahu kami segera, atau tarik layar kebawah untuk memuat ulang.';
}

class Validations {
  static const String alphaDash = r'^[a-z0-9_-]+$';
  static const String alphaNumSpace = r'^[a-zA-Z0-9 ]+$';

  static const String eRequired = 'Pastikan {field} tidak kosong.';
  static const String eAlphaDash =
      'Gunakan format huruf kecil, angka, garis bawah, atau tanda penghubung.';
  static const String eAlphaNumSpace =
      'Gunakan format huruf, angka, atau spasi.';
  static const String eMinLength = 'Gunakan minimal {len} karakter.';
  static const String eMaxLength = 'Pastikan tidak lebih dari {len} karakter.';
  static const String eEmail =
      'Gunakan alamat surel aktif dan format yang sesuai.';
  static const String eNumeric = 'Gunakan format nomor telepon yang sesuai.';
  static const String eEqual = '{field} ditolak, coba lagi.';
}

class Labels {
  static const String sure = 'mengerti';
  static const String back = 'kembali';
  static const String login = 'masuk';
  static const String try_again = 'coba lagi';
  static const String continue_step = 'lanjutkan';
  static const String forward_step = 'teruskan';
  static const String confirm = 'konfirmasi';
  static const String be_sure = 'yakin';
  static const String my_classroom = 'ruang saya';
  static const String cancel = 'batal';
  static const String has_end = 'telah berakhir';
  static const String participant = 'partisipan';
  static const String lesson = 'pelajaran';

  static const String username = 'nama pengguna';
  static const String email = 'alamat surel';
  static const String address = 'alamat domisili';
  static const String gender = 'jenis kelamin';
  static const String password = 'kata sandi';
  static const String repeat_password = 'konfirmasi kata sandi';
  static const String full_name = 'nama lengkap';
  static const String phone_number = 'nomor telepon';
  static const String uname = 'email atau username';
  static const String secure_key = 'kunci akses';
}

class Initials {
  static const String incompleteParams = 'INCOMPLETE_PARAMETERS';
  static const String invalidInput = 'INVALID_INPUT';
  static const String unknownAccount = 'UNKNOWN_ACCOUNT';
  static const String wrongPassword = 'WRONG_PASSWORD';
  static const String accessDenied = 'ACCESS_DENIED';
  static const String authorizationDenied = 'AUTHORIZATION_DENIED';
  static const String resourceNotFound = 'RESOURCE_NOT_FOUND';
  static const String methodDisabled = 'METHOD_DISABLED';
  static const String methodDisallow = 'METHOD_DISALLOW';
  static const String lostResource = 'LOST_RESOURCE';
  static const String internalServer = 'INTERNAL_SERVER';
}

Widget primaryButton({
  required BuildContext context,
  required String label,
  required void Function()? onPressed,
}) {
  return TextButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).primaryColor,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    child: Text(Labels.forward_step.toUpperCase()),
    onPressed: onPressed,
  );
}

Widget failedToast({String? message}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.red[100],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.block,
          color: Colors.red[900],
        ),
        SizedBox(
          width: 12.0,
        ),
        Text(
          message ?? 'Terjadi kesalahan tidak terduga!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red[900],
          ),
        ),
      ],
    ),
  );
}

Widget successToast({String? message}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.green[100],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.green[900],
        ),
        SizedBox(
          width: 12.0,
        ),
        Text(
          message ?? 'Berhasil melakukan tindakan!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ],
    ),
  );
}

Widget warningToast({String? message}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.deepOrange[100],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.deepOrange[900],
        ),
        SizedBox(
          width: 12.0,
        ),
        Text(
          message ?? 'Tindakan peringatan!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange[900],
          ),
        ),
      ],
    ),
  );
}

Widget flatButton({
  required String label,
  required void Function()? onPressed,
  Color? color,
  Color? backgroundColor,
  double? height,
}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.disabled,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppTheme.notWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Map<ImageSourceMatcher, ImageRender> imageCacheRender() {
  return {
    dataUriMatcher(mime: 'image/svg+xml', encoding: null): svgDataImageRender(),
    dataUriMatcher(): base64ImageRender(),
    assetUriMatcher(): assetImageRender(),
    networkSourceMatcher(extension: "svg"): svgNetworkImageRender(),
    networkSourceMatcher(): (context, attributes, element) {
      return CachedNetworkImage(
        errorWidget: (context, x, y) => CircularProgressIndicator(),
        placeholder: (context, url) => CircularProgressIndicator(
          color: AppTheme.chipBackground,
        ),
        fadeInDuration: Duration(milliseconds: 100),
        fadeOutDuration: Duration(milliseconds: 100),
        imageUrl: attributes['src'] ?? Constants.dummyPict,
      );
    },
  };
}

Widget progressIndicator({String? text}) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            text ?? Strings.loading,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
          ),
        ],
      ),
    ),
  );
}
