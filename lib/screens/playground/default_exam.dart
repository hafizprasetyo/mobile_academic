import 'package:page_transition/page_transition.dart';
import 'package:academic/models/exam_point.dart';
import 'package:academic/providers/data_exam_repository.dart';
import 'package:academic/providers/data_lesson_repository.dart';
import 'package:academic/screens/playground/default_result.dart';
import 'package:academic/screens/playground/views/friendly_exam_screen.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academic/utils/utils.dart';

class DefaultExam extends StatefulWidget {
  const DefaultExam({
    Key? key,
    required this.classroom,
    required this.lesson,
  }) : super(key: key);

  final Map<String, dynamic> classroom;
  final Map<String, dynamic> lesson;

  @override
  _DefaultExamState createState() => _DefaultExamState();
}

class _DefaultExamState extends State<DefaultExam> {
  final DataLessonRepository _dataLessonRepository = new DataLessonRepository();
  final DataExamRepository _dataExamRepository = new DataExamRepository();
  final FToast _fToast = new FToast();

  late Map<String, dynamic> _classroom;
  late Map<String, dynamic> _lesson;

  int? _lessonAttemptId;
  Map<String, dynamic>? _questionResponse;

  bool _waiting = true;
  bool _hasDialogOpen = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _fToast.init(context);
    _classroom = this.widget.classroom;
    _lesson = this.widget.lesson;

    _initializeNewAttempt();
  }

  Future _initializeNewAttempt() async {
    try {
      await _fetchQuestions();
      await _fetchAttemptId();

      setState(() {
        _waiting = false;
      });
    } catch (e) {
      return _validateDialogInfo(
        showCancelButton: false,
        title: "Peringatan",
        message:
            "Terjadi kesalahan, gagal memuat informasi soal. Beritahu atau hubungi pengelola untuk validasi!",
      ).then((v) => Navigator.pop(context));
    }
  }

  Future<Map<String, dynamic>> _getQuestions() async {
    try {
      Map<String, dynamic> response = await _dataLessonRepository.getQuestions(
        lessonId: _lesson['id'],
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future _fetchQuestions() async {
    try {
      Map<String, dynamic> data = await _getQuestions();

      setState(() {
        _questionResponse = data;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createNewAttempt() async {
    try {
      Map<String, dynamic> response =
          await _dataLessonRepository.storeNewAttempt(
        classroomId: _classroom['id'],
        lessonId: _lesson['id'],
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future _fetchAttemptId() async {
    try {
      Map<String, dynamic> data = await _createNewAttempt();

      setState(() {
        _lessonAttemptId = data['taskId'];
      });
    } catch (e) {
      rethrow;
    }
  }

  Future _saveFinalResult({
    required List questionsTemp,
    required bool isOverdue,
  }) async {
    try {
      String endpoint =
          Constants.lessonAttemptsEndpoint + "/" + _lessonAttemptId.toString();

      ExamPoint examPoint = await _dataExamRepository.storeQuestionsResult(
        lessonAttemptId: _lessonAttemptId!,
        quizAttemptId: null,
        questionsTemp: questionsTemp,
      );

      double sumGrades = double.parse(_lesson['sumGrades'].toString());
      Map<String, dynamic> response =
          await _dataExamRepository.storeFinalResult(
        endpoint: endpoint,
        grades: finalGrades(examPoint: examPoint, sumGrades: sumGrades),
        overdue: isOverdue,
      );

      if (response['invalid']) throw Exception();
    } catch (e) {
      rethrow;
    }
  }

  Future _forwardFinalResult({
    required List questionsTemp,
    required bool isOverdue,
    required int totalAnswered,
    required int totalQuestion,
  }) async {
    bool forwardResult;

    if (isOverdue) {
      forwardResult = await _validateDialogInfo(
        showCancelButton: false,
        message:
            "Tes Berakhir, kamu kehabisan waktu. Silahkan teruskan hasil tes.",
      );
    } else {
      bool hasMissing = totalAnswered < totalQuestion;
      int totalMissed = totalQuestion - totalAnswered;

      forwardResult = await _validateDialogInfo(
        message: (hasMissing ? "$totalMissed Soal belum terjawab. " : "") +
            "Kamu yakin ingin mengakhiri tes?",
      );
    }

    if (!forwardResult) return;

    try {
      setState(() {
        _waiting = true;
      });

      await _saveFinalResult(
        questionsTemp: questionsTemp,
        isOverdue: isOverdue,
      );
      return _gotoDetailsResult();
    } catch (e) {
      return _validateDialogInfo(
        showCancelButton: false,
        title: "Peringatan",
        message:
            "Terjadi kesalahan, hasil tes kamu gagal diteruskan. Beritahu atau hubungi pengelola untuk validasi!",
      ).then((v) => Navigator.pop(context));
    }
  }

  Future _gotoDetailsResult() async {
    try {
      String questionEndpoint = Constants.lessonAttemptQuestionsEndpoint
          .replaceAll('{key}', _lessonAttemptId.toString());

      Map<String, dynamic> data = await _dataLessonRepository.getAttempt(
        attemptId: _lessonAttemptId!,
      );

      return Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: DefaultResult(
            questionsEndpoint: questionEndpoint,
            title: data['name'],
            assessment: data['resultInfo'],
            finalGrades: data['finalGrades'].toString(),
            passingGrades: data['passingGrades'].toString(),
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_waiting || _questionResponse == null) {
      return WillPopScope(
        onWillPop: () async => !_waiting,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            child: _buildProgressIndicator(),
          ),
        ),
      );
    } else {
      List questionList = _questionResponse!['results'];

      return FriendlyExamScreen(
        title: _lesson['name'],
        duration: _lesson['durationTime'],
        questionList: questionList,
        onEnd: (ctx, overdue, totalQuestions, totalAnswered, questionsTemp) {
          return _forwardFinalResult(
            questionsTemp: questionsTemp,
            isOverdue: overdue,
            totalAnswered: totalAnswered,
            totalQuestion: totalQuestions,
          );
        },
      );
    }
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

  _resetDialogOpen(bool status) {
    if (_hasDialogOpen) Navigator.pop(context);
    setState(() {
      _hasDialogOpen = status;
    });
  }

  Future<bool> _validateDialogInfo({
    required String message,
    String title = "Informasi",
    bool showCancelButton = true,
  }) async {
    bool? isOk;
    _resetDialogOpen(true);

    return await showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Text(title),
            actionsPadding: EdgeInsets.all(15),
            content: Builder(
              builder: (context) {
                return Container(
                  width: 360,
                  child: Text(message),
                );
              },
            ),
            actions: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showCancelButton)
                      Expanded(
                        child: flatButton(
                          label: "BATAL",
                          onPressed: () {
                            isOk = false;
                            _resetDialogOpen(false);
                          },
                        ),
                      ),
                    SizedBox(width: showCancelButton ? 10 : 0),
                    Expanded(
                      child: flatButton(
                        label: "MENGERTI",
                        backgroundColor: AppTheme.mainBtn,
                        onPressed: () {
                          isOk = true;
                          _resetDialogOpen(false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((v) => isOk ?? false);
  }
}
