import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';
import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/components/forms/address_input.dart';
import 'package:academic/components/forms/fullname_input.dart';
import 'package:academic/components/forms/gender_dropdown.dart';
import 'package:academic/components/forms/phone_input.dart';
import 'package:academic/components/label_icon.dart';
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/models/user.dart';
import 'package:academic/providers/data_lesson_repository.dart';
import 'package:academic/providers/data_user_repository.dart';
import 'package:academic/screens/playground/default_result.dart';
import 'package:academic/screens/playground/quiz_result.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataUserRepository _dataUserRepository = new DataUserRepository();
  final DataLessonRepository _dataLessonRepository = new DataLessonRepository();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _profileFormKey =
      new GlobalKey<FormBuilderState>();
  final FToast _fToast = new FToast();

  bool _waitUserProfile = true;
  bool _waitHistories = true;
  bool _waitAsync = false;

  int _initialMenu = 0;

  Map<String, dynamic>? _historyResponse;
  User? _user;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _loadData();
  }

  _gotoDefaultResult({
    required Map<String, dynamic> lessonAttempt,
    required String questionEndpoint,
  }) {
    return Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: DefaultResult(
          questionsEndpoint: questionEndpoint,
          title: lessonAttempt['name'],
          assessment: lessonAttempt['resultInfo'],
          finalGrades: lessonAttempt['finalGrades'].toString(),
          passingGrades: lessonAttempt['passingGrades'].toString(),
        ),
      ),
    );
  }

  _gotoExamResult({
    required Map<String, dynamic> lessonAttempt,
    required List quizAttempts,
  }) {
    return Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: QuizResult(
          task: lessonAttempt,
          title: lessonAttempt['name'],
          finalGrades: lessonAttempt['finalGrades'].toString(),
          passingGrades: lessonAttempt['passingGrades'].toString(),
          submissionList: quizAttempts,
        ),
      ),
    );
  }

  _changeMenu(int index) async {
    setState(() {
      _initialMenu = index;
    });

    await _loadData();
  }

  _setWaitAsync(bool value) {
    setState(() {
      _waitAsync = value;
    });
  }

  _setWaitUserProfile(bool value) {
    setState(() {
      _waitUserProfile = value;
    });
  }

  _setWaitHistories(bool value) {
    setState(() {
      _waitHistories = value;
    });
  }

  bool _isMenuActive(int index) {
    return _initialMenu == index;
  }

  Widget _showMenuDisplay(int index) {
    List<Widget> menus = [
      _buildProfile(),
      _buildHistoryItems(),
    ];

    return menus[index];
  }

  Future _loadData() async {
    await _fetchUserProfile();
    await _fetchAttemptHistories();
  }

  Future _saveProfileUpdate({required Map<String, dynamic> formData}) async {
    _setWaitAsync(true);

    try {
      User? user = await _dataUserRepository.saveProfile(
        fullName: formData[Constants.fullnameField],
        phoneNumber: formData[Constants.phoneField],
        gender: formData[Constants.genderField],
        address: formData[Constants.addressField],
      );

      _setWaitAsync(false);

      if (user == null) {
        return _fToast.showToast(
          child: warningToast(message: "Tidak ada perubahan apapun!"),
        );
      } else {
        setState(() {
          _user = user;
        });

        return _fToast.showToast(
          child: successToast(message: "Berhasil melakukan perubahan!"),
        );
      }
    } on APIException catch (e) {
      _setWaitAsync(false);
      return ExceptionDialog(screenContext: context).apiErrors(e);
    } catch (e) {
      _setWaitAsync(false);
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _gotoDetailsResult({required int attemptId}) async {
    _setWaitAsync(true);

    try {
      Map<String, dynamic> lessonAttempt =
          await _dataLessonRepository.getAttempt(
        attemptId: attemptId,
      );

      if (lessonAttempt['stateMode'] == 'questiontest') {
        String endpoint = Constants.lessonAttemptQuestionsEndpoint
            .replaceAll('{key}', attemptId.toString());
        _setWaitAsync(false);

        return _gotoDefaultResult(
          lessonAttempt: lessonAttempt,
          questionEndpoint: endpoint,
        );
      } else if (lessonAttempt['stateMode'] == 'quiztest') {
        Map<String, dynamic> quizAttemptsResponse =
            await _dataLessonRepository.getAttemptQuizzes(attemptId: attemptId);
        _setWaitAsync(false);

        return _gotoExamResult(
          lessonAttempt: lessonAttempt,
          quizAttempts: quizAttemptsResponse['results'],
        );
      }
    } catch (e) {
      _setWaitAsync(false);
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchUserProfile() async {
    try {
      User user = await _dataUserRepository.getProfile();

      setState(() {
        _user = user;
        _waitUserProfile = false;
      });
    } catch (e) {
      _setWaitUserProfile(false);
    }
  }

  Future _fetchAttemptHistories() async {
    try {
      Map<String, dynamic> data = await _dataLessonRepository.getAttempts();

      setState(() {
        _historyResponse = data;
        _waitHistories = false;
      });
    } catch (e) {
      _setWaitHistories(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_waitAsync,
      child: ModalProgressHUD(
        inAsyncCall: _waitAsync,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.kBgDarkColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: MaterialButton(
              minWidth: 20,
              onPressed: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                size: 15,
              ),
            ),
            title: Text(
              StringUtils.capitalize('Profil Partisipan', allWords: true),
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                physics: ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: 300, minWidth: 300),
                          child: Card(
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => _isMenuActive(0)
                                        ? null
                                        : _changeMenu(0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      color: _isMenuActive(0)
                                          ? AppTheme.notWhite
                                          : null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: AppTheme.deactivatedText,
                                          ),
                                          SizedBox(width: 5),
                                          Flexible(
                                              child: Text("Pengaturan Akun")),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(height: 1),
                                  InkWell(
                                    onTap: () => _isMenuActive(1)
                                        ? null
                                        : _changeMenu(1),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      color: _isMenuActive(1)
                                          ? AppTheme.notWhite
                                          : null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.history,
                                            color: AppTheme.deactivatedText,
                                          ),
                                          SizedBox(width: 5),
                                          Flexible(child: Text("Riwayat Tes")),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: 600, minWidth: 600),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                child: child,
                                opacity: animation,
                              );
                            },
                            child: _showMenuDisplay(_initialMenu),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailure() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Image.asset('assets/images/bug.png', height: 180),
          SizedBox(height: 24),
          Text(
            'Oops! Terjadi kesalahan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            width: 360,
            child: Text(
              "Mohon maaf, kesalahan tidak terduga atau pastikan koneksi internet kamu stabil.\nSegarkan halaman untuk coba lagi!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.deactivatedText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItems({bool scrollable = true}) {
    if (_waitHistories) {
      return _buildProgressIndicator();
    } else if (_historyResponse == null) {
      return _buildFailure();
    } else {
      Map<String, dynamic> data = _historyResponse!;

      if (empty(data['totalResults'])) {
        return _buildEmptyItems();
      } else {
        return ListView.separated(
          physics: scrollable
              ? ClampingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: data['totalResults'],
          itemBuilder: (context, index) {
            Map<String, dynamic> item = data['results'][index];

            return _historyCard(
              lessonAttempt: item,
              onTap: (taskId, taskDetails) =>
                  _gotoDetailsResult(attemptId: taskId),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 8);
          },
        );
      }
    }
  }

  Widget _buildEmptyItems() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Image.asset('assets/images/searchfor.png', height: 180),
          SizedBox(height: 24),
          Text(
            'Oops! Belum ada',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            width: 360,
            child: Text(
              'Belum ada riwayat apapun, kerjakan tes dan akses riwayat tes kamu disini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.deactivatedText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 25),
        Text(
          Strings.loading,
          style: TextStyle(
            color: AppTheme.deactivatedText,
          ),
        ),
      ],
    );
  }

  Widget _historyCard({
    required Map<String, dynamic> lessonAttempt,
    required void Function(int attemptId, Map<String, dynamic> lessonAttempt)
        onTap,
  }) {
    int attemptId = lessonAttempt['taskId'];
    String name = lessonAttempt['name'];
    String startDate = lessonAttempt['readableTimeStart'];

    double finalGrades =
        double.parse(lessonAttempt['finalGrades']?.toString() ?? 0.toString());
    double passingGrades = double.parse(
        lessonAttempt['passingGrades']?.toString() ?? 0.toString());

    Map<String?, dynamic>? assessment = lessonAttempt['resultInfo'];
    Map<String?, dynamic>? categoryInfo = lessonAttempt['categoryInfo'];
    Map<String?, dynamic>? subcategoryInfo = lessonAttempt['subcategoryInfo'];
    Map<String?, dynamic>? authorInfo = lessonAttempt['authorInfo'];

    int totalCorrect = 0;
    int totalWrong = 0;
    int totalQuestion = 0;

    if (assessment != null) {
      totalQuestion = assessment['totalQuestion'] ?? totalQuestion;
      totalCorrect = assessment['totalCorrect'] ?? totalCorrect;
      totalWrong = assessment['totalWrong'] ?? totalWrong;
    }

    String? category;
    String? subcategory;
    String? author;

    if (categoryInfo != null) {
      category = categoryInfo['name'];
    }

    if (subcategoryInfo != null) {
      subcategory = subcategoryInfo['name'];
    }

    if (subcategoryInfo != null) {
      subcategory = subcategoryInfo['name'];
    }

    if (authorInfo != null) {
      author = authorInfo['name'];
    }

    return GestureDetector(
      onTap: () => onTap(attemptId, lessonAttempt),
      child: Card(
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Container(
            child: Column(
              children: [
                Container(
                  child: ListTile(
                    trailing: Icon(Icons.arrow_forward_rounded),
                    subtitle: category != null
                        ? Row(
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  color: AppTheme.deactivatedText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subcategory != null
                                  ? Text(
                                      " - $subcategory",
                                      style: TextStyle(
                                        color: AppTheme.deactivatedText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Container(),
                            ],
                          )
                        : null,
                    title: Text(name, style: AppTheme.textTheme.headline6),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      _flatTile(
                        child: Text(startDate),
                        childWeight: 2,
                        leading: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tanggal/Waktu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      _flatTile(
                        child: Text(finalGrades.toString()),
                        trailing: Text(
                          finalGrades >= passingGrades ? 'LOLOS' : 'GAGAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: finalGrades >= passingGrades
                                ? Colors.green[900]
                                : Colors.red[900],
                          ),
                        ),
                        leading: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total Nilai',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      _flatTile(
                        leadingColor: Colors.red[100],
                        childColor: Colors.green[100],
                        child: Container(
                          child: Text(
                            'Jawaban Benar',
                            style: TextStyle(
                              color: Colors.green[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        leading: Container(
                          child: Text(
                            'Jawaban Salah',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        trailing: Container(
                          child: Text(
                            'Total Soal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      _flatTile(
                        leadingColor: Colors.red[100],
                        childColor: Colors.green[100],
                        child: Text(
                          totalCorrect.toString(),
                          style: TextStyle(color: Colors.green[900]),
                        ),
                        leading: Text(
                          totalWrong.toString(),
                          style: TextStyle(color: Colors.red[900]),
                        ),
                        trailing: Text(totalQuestion.toString()),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Divider(height: 0),
                Container(
                  padding: const EdgeInsets.all(15),
                  color: AppTheme.notWhite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (author != null)
                        RichText(
                          text: TextSpan(
                            text: 'Pemateri ',
                            style: TextStyle(color: AppTheme.deactivatedText),
                            children: [
                              TextSpan(
                                text: author,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _flatTile({
    required Widget child,
    Widget? leading,
    Widget? trailing,
    int? childWeight,
    int? leadingWeight,
    int? trailingWeight,
    Color? childColor,
    Color? leadingColor,
    Color? trailingColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null)
            Expanded(
              flex: leadingWeight ?? 1,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: leadingColor ?? AppTheme.notWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: leading,
              ),
            )
          else
            Container(),
          Expanded(
            flex: childWeight ?? 1,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: childColor ?? AppTheme.notWhite,
                borderRadius: BorderRadius.circular(5),
              ),
              child: child,
            ),
          ),
          if (trailing != null)
            Expanded(
              flex: trailingWeight ?? 1,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: trailingColor ?? AppTheme.notWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: trailing,
              ),
            )
          else
            Container(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    if (_waitUserProfile) {
      return _buildProgressIndicator();
    } else if (_user == null) {
      return _buildFailure();
    } else {
      User user = _user!;

      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "PENGATURAN AKUN",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  _userProfileInformation(
                    name: user.fullName,
                    email: user.email,
                    username: user.username,
                    photoUrl: user.photoUrl,
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Text(
                        "BIODATA",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  FormBuilder(
                    key: _profileFormKey,
                    child: _userProfileInput(user: user),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: flatButton(
                label: "SIMPAN PERUBAHAN",
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () async {
                  FocusScope.of(this.context).unfocus();
                  if (_profileFormKey.currentState!.saveAndValidate()) {
                    await _saveProfileUpdate(
                      formData: _profileFormKey.currentState!.value,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _userProfileInput({required User user}) {
    return Column(
      children: [
        FullNameInput(value: user.fullName),
        SizedBox(height: 10),
        PhoneInput(value: user.phoneNumber),
        SizedBox(height: 10),
        GenderDropdown(value: user.gender),
        SizedBox(height: 10),
        AddressInput(value: user.address),
      ],
    );
  }

  Widget _userProfileInformation({
    required String name,
    required String email,
    required String username,
    String? photoUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        photoUrl != null
            ? Flexible(
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              )
            : Flexible(
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 48,
                      color: AppTheme.deactivatedText,
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.primaries[
                        Random().nextInt(Colors.primaries.length)][200],
                  ),
                ),
              ),
        SizedBox(width: 10.0),
        Flexible(
          child: Column(
            children: [
              LabelIcon(label: username, icon: Icons.alternate_email_outlined),
              LabelIcon(label: email, icon: Icons.mail_outlined),
            ],
          ),
        ),
      ],
    );
  }
}
