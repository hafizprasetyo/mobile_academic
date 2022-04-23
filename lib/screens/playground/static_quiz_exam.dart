import 'package:page_transition/page_transition.dart';
import 'package:academic/models/exam_point.dart';
import 'package:academic/providers/data_exam_repository.dart';
import 'package:academic/providers/data_lesson_repository.dart';
import 'package:academic/providers/data_quiz_repository.dart';
import 'package:academic/screens/playground/quiz_result.dart';
import 'package:academic/screens/playground/views/static_exam_screen.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StaticQuizExam extends StatefulWidget {
  const StaticQuizExam({
    Key? key,
    required this.classroom,
    required this.lesson,
  }) : super(key: key);

  final Map<String, dynamic> classroom;
  final Map<String, dynamic> lesson;

  @override
  _StaticQuizExamState createState() => _StaticQuizExamState();
}

class _StaticQuizExamState extends State<StaticQuizExam> {
  final DataLessonRepository _dataLessonRepository = new DataLessonRepository();
  final DataQuizRepository _dataQuizRepository = new DataQuizRepository();
  final DataExamRepository _dataExamRepository = new DataExamRepository();
  final FToast _fToast = new FToast();

  late Map<String, dynamic> _classroom;
  late Map<String, dynamic> _lesson;
  late int _pageIndex;

  List? _quizList;
  Map<String, dynamic>? _currentQuiz;

  int? _lessonAttemptId;
  int? _quizAttemptId;
  Map<String, dynamic>? _questionResponse;

  bool _waiting = true;
  bool _hasDialogOpen = false;
  bool _isFinish = false;
  double _grades = 0;

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
    _pageIndex = 0;

    _initializeNewAttempt();
  }

  void _setWaiting(bool status) {
    setState(() {
      _waiting = status;
    });
  }

  Future _initializeNewAttempt() async {
    try {
      await _fetchQuizzes();
      await _fetchQuizQuestions(quizId: _currentQuiz!['id']);

      await _fetchLessonAttemptId();
      await _fetchQuizAttemptId(
        lessonAttemptId: _lessonAttemptId!,
        quizId: _currentQuiz!['id'],
      );

      _setWaiting(false);
    } catch (e) {
      return _validateDialogInfo(
        showCancelButton: false,
        title: "Peringatan",
        message:
            "Terjadi kesalahan, gagal memuat informasi soal. Beritahu atau hubungi pengelola untuk validasi!",
      ).then((v) => Navigator.pop(context));
    }
  }

  Future<Map<String, dynamic>> _getQuizzes() async {
    try {
      Map<String, dynamic> response = await _dataLessonRepository.getQuizzes(
        lessonId: _lesson['id'],
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future _fetchQuizzes() async {
    try {
      Map<String, dynamic> data = await _getQuizzes();

      if (empty(data['totalResults'])) {
        return _validateDialogInfo(
          showCancelButton: false,
          message: "Mohon maaf, belum ada kuesioner apapun.",
        );
      }

      setState(() {
        _quizList = data['results'];
        _currentQuiz = _quizList![_pageIndex];
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getQuizQuestions({required int quizId}) async {
    try {
      Map<String, dynamic> response = await _dataQuizRepository.getQuestions(
        quizId: quizId,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future _fetchQuizQuestions({required int quizId}) async {
    try {
      Map<String, dynamic> data = await _getQuizQuestions(quizId: quizId);

      if (empty(data['totalResults'])) {
        return await _forwardNext(questionsTemp: null);
      }

      setState(() {
        _questionResponse = data;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createNewLessonAttempt() async {
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

  Future _fetchLessonAttemptId() async {
    try {
      Map<String, dynamic> data = await _createNewLessonAttempt();

      setState(() {
        _lessonAttemptId = data['taskId'];
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createNewQuizAttempt({
    required int lessonAttemptId,
    required int quizId,
  }) async {
    try {
      Map<String, dynamic> response = await _dataQuizRepository.storeNewAttempt(
        lessonAttemptId: lessonAttemptId,
        quizId: quizId,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future _fetchQuizAttemptId({
    required int lessonAttemptId,
    required int quizId,
  }) async {
    try {
      Map<String, dynamic> data = await _createNewQuizAttempt(
        lessonAttemptId: lessonAttemptId,
        quizId: quizId,
      );

      setState(() {
        _quizAttemptId = data['submissionId'];
      });
    } catch (e) {
      rethrow;
    }
  }

  Future _saveFinalResult() async {
    try {
      String endpoint = "${Constants.lessonAttemptsEndpoint}/$_lessonAttemptId";
      double finalGrades = _grades;

      if (_quizList != null) {
        int totalQuiz = _quizList!.length;
        finalGrades = totalQuiz > 0 ? (_grades / totalQuiz) : finalGrades;
      }

      Map<String, dynamic> response =
          await _dataExamRepository.storeFinalResult(
        endpoint: endpoint,
        grades: finalGrades,
        overdue: false,
      );

      if (response['invalid']) throw Exception();
    } catch (e) {
      rethrow;
    }
  }

  Future _saveCurrentResult({
    required List questionsTemp,
    required bool isOverdue,
  }) async {
    try {
      String endpoint = "${Constants.quizAttemptsEndpoint}/$_quizAttemptId";
      ExamPoint examPoint = await _dataExamRepository.storeQuestionsResult(
        lessonAttemptId: _lessonAttemptId!,
        quizAttemptId: _quizAttemptId,
        questionsTemp: questionsTemp,
      );

      double sumGrades = double.parse(_lesson['sumGrades'].toString());
      double grades = finalGrades(examPoint: examPoint, sumGrades: sumGrades);

      setState(() {
        _grades += grades;
      });

      Map<String, dynamic> response =
          await _dataExamRepository.storeFinalResult(
        endpoint: endpoint,
        grades: grades,
        overdue: isOverdue,
      );

      if (response['invalid']) {
        return await _validateDialogInfo(
          message:
              "Mohon maaf, hasil tes kamu saat ini gagal diteruskan, beritahu atau hubungi pengelola untuk validasi!\n\nKetuk MENGERTI untuk ke tes berikutnya atau ketuk BATAL untuk mengakhiri tes.",
        ).then(
          (isOk) async => isOk ? null : Navigator.pop(context),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future _forwardNext({
    required List? questionsTemp,
    bool isOverdue = false,
  }) async {
    try {
      int pageLimit = _quizList!.length - 1;

      setState(() {
        _waiting = true;
        _isFinish = _pageIndex >= pageLimit;
      });

      if (questionsTemp != null) {
        await _saveCurrentResult(
          questionsTemp: questionsTemp,
          isOverdue: isOverdue,
        );
      }

      if (_isFinish) {
        await _saveFinalResult();
        _setWaiting(false);

        await _validateDialogInfo(
          showCancelButton: false,
          message:
              "Tes Berakhir, kamu telah menyelesaikan seluruhnya. Teruskan hasil tes!",
        );

        _setWaiting(true);
        return _gotoDetailsResult();
      } else {
        setState(() {
          _pageIndex += 1;
          _currentQuiz = _quizList![_pageIndex];
        });

        int quizId = _currentQuiz!['id'];

        await _fetchQuizQuestions(quizId: quizId);
        await _fetchQuizAttemptId(
          lessonAttemptId: _lessonAttemptId!,
          quizId: quizId,
        );

        _setWaiting(false);
      }
    } catch (e) {
      _setWaiting(false);
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
      Map<String, dynamic> lessonAttempt =
          await _dataLessonRepository.getAttempt(
        attemptId: _lessonAttemptId!,
      );

      Map<String, dynamic> quizAttemptsResponse =
          await _dataLessonRepository.getAttemptQuizzes(
        attemptId: _lessonAttemptId!,
      );

      return Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: QuizResult(
            task: lessonAttempt,
            title: lessonAttempt['name'],
            finalGrades: lessonAttempt['finalGrades'].toString(),
            passingGrades: lessonAttempt['passingGrades'].toString(),
            submissionList: quizAttemptsResponse['results'],
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_waiting || _currentQuiz == null) {
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
      return StaticExamScreen(
        title: _lesson['name'],
        subtitle: _currentQuiz!['name'],
        questionReference: _currentQuiz!['htmlReference'],
        duration: _isFinish ? 0 : _currentQuiz!['durationTime'],
        questionList: _questionResponse!['results'],
        onEnd: (ctx, overdue, totalQuestions, totalAnswered, questionsTemp) {
          if (_isFinish) return null;

          return _forwardNext(
            questionsTemp: questionsTemp,
            isOverdue: overdue,
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

  _resetDialogOpen({required bool isOpen}) {
    if (_hasDialogOpen) Navigator.pop(context);
    setState(() {
      _hasDialogOpen = isOpen;
    });
  }

  Future<bool> _validateDialogInfo({
    required String message,
    String title = "Informasi",
    bool showCancelButton = true,
  }) async {
    bool? isOk;
    _resetDialogOpen(isOpen: true);

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
                            _resetDialogOpen(isOpen: false);
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
                          _resetDialogOpen(isOpen: false);
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
