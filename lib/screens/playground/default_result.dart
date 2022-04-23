import 'dart:io';

import 'package:expand_widget/expand_widget.dart';
import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/models/user.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/http_helper.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DefaultResult extends StatefulWidget {
  const DefaultResult({
    Key? key,
    required this.questionsEndpoint,
    required this.assessment,
    required this.title,
    required this.finalGrades,
    required this.passingGrades,
    this.subtitle,
    this.questionReference,
    this.nextButtonAction,
    this.showPredicate = true,
    this.showNextButton = false,
    this.showPassingGrades = true,
  }) : super(key: key);

  final String questionsEndpoint;
  final String finalGrades;
  final String passingGrades;
  final bool showPassingGrades;
  final Map<String, dynamic> assessment;
  final bool showPredicate;
  final String title;
  final String? subtitle;
  final String? questionReference;
  final bool showNextButton;
  final void Function()? nextButtonAction;

  @override
  _DefaultResultState createState() => _DefaultResultState();
}

class _DefaultResultState extends State<DefaultResult> {
  final DataAuthenticationRepository _dataAuthenticationRepository =
      new DataAuthenticationRepository();

  late String _title;
  late String? _subtitle;
  late bool _showPredicate;
  late String? _questionReference;
  late bool _showNextButton;
  late bool _showPassingGrades;
  late void Function()? _nextButtonAction;

  late Map<String, dynamic> _assessment;
  late double _finalGrades;
  late double _passingGrades;

  User? _user;
  Map<String, dynamic>? _questionResponse;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _title = this.widget.title;
    _subtitle = this.widget.subtitle;
    _showPredicate = this.widget.showPredicate;
    _questionReference = this.widget.questionReference;
    _showNextButton = this.widget.showNextButton;
    _showPassingGrades = this.widget.showPassingGrades;
    _nextButtonAction = this.widget.nextButtonAction;
    _assessment = this.widget.assessment;

    _passingGrades = double.parse(this.widget.passingGrades);
    _finalGrades = double.parse(this.widget.finalGrades);

    _fetchCurrentUser();
    _fetchQuestions(this.widget.questionsEndpoint);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _gotoException(dynamic error) {
    return Navigator.of(this.context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExceptionScreen(exception: error),
      ),
    );
  }

  Future _fetchQuestions(String endpoint) async {
    try {
      String token = await _dataAuthenticationRepository.getAccessToken();
      Map<String, dynamic> response = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      setState(() {
        _questionResponse = response;
      });
    } on APIException catch (e) {
      return new ExceptionDialog(screenContext: context).apiErrors(e);
    } catch (e) {
      return _gotoException(e);
    }
  }

  Future _fetchCurrentUser() async {
    try {
      User user = await _dataAuthenticationRepository.getCurrentUser();

      setState(() {
        _user = user;
      });
    } on APIException catch (e) {
      return new ExceptionDialog(screenContext: context).apiErrors(e);
    } catch (e) {
      return _gotoException(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _questionResponse != null,
      child: ModalProgressHUD(
        color: Colors.white,
        opacity: 1,
        inAsyncCall: _user != null && _questionResponse == null,
        progressIndicator: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 25),
                Text(
                  'Memuat...',
                  style: TextStyle(
                    color: AppTheme.deactivatedText,
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.blue[800],
          bottomNavigationBar: !_showNextButton
              ? null
              : Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(AppTheme.mainBtn),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      child: Text("LANJUTKAN"),
                      onPressed: _nextButtonAction,
                    ),
                  ),
                ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.blue[800],
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            title: Text(
              'RINCIAN HASIL',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _user?.fullName ?? 'Anonim',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 25),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _gradesBox(
                                  title: 'Nilai Perolehan',
                                  gradeNumber: _finalGrades.toString(),
                                  textColor: _finalGrades >= _passingGrades
                                      ? Colors.green[900]
                                      : Colors.red[900],
                                  backgroundColor:
                                      _finalGrades >= _passingGrades
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: !_showPassingGrades
                                        ? Radius.circular(5)
                                        : Radius.zero,
                                    bottomRight:
                                        !_showPassingGrades && !_showPredicate
                                            ? Radius.circular(5)
                                            : Radius.zero,
                                    bottomLeft: !_showPredicate
                                        ? Radius.circular(5)
                                        : Radius.zero,
                                  ),
                                ),
                              ),
                              if (_showPassingGrades)
                                Expanded(
                                  child: _gradesBox(
                                    title: 'Nilai Standar',
                                    gradeNumber: _passingGrades.toString(),
                                    textColor: Colors.green[900],
                                    backgroundColor: Colors.green[100],
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomRight: !_showPredicate
                                          ? Radius.circular(5)
                                          : Radius.zero,
                                    ),
                                  ),
                                )
                              else
                                Container(),
                            ],
                          ),
                        ),
                        if (_showPredicate)
                          _gradesBox(
                            gradeNumber: _finalGrades >= _passingGrades
                                ? 'LOLOS'
                                : 'GAGAL',
                            backgroundColor: AppTheme.notWhite,
                            textColor: _finalGrades >= _passingGrades
                                ? Colors.green[900]
                                : Colors.red[900],
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          )
                        else
                          Container()
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: _referencesHeader(
                            title: _title,
                            subtitle: _subtitle,
                            questionReference: _questionReference,
                          ),
                        ),
                        Divider(height: 0),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Informasi Jawaban : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.deactivatedText,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _labelIcon(
                                          icon: Icons.check_circle_outlined,
                                          backgroundColor: Colors.green[100],
                                          color: Colors.green[900],
                                          label:
                                              "${_assessment['totalCorrect'].toString()} Benar",
                                          stretch: true,
                                        ),
                                        SizedBox(width: 10),
                                        _labelIcon(
                                          icon: Icons.cancel_outlined,
                                          backgroundColor: Colors.red[100],
                                          color: Colors.red[900],
                                          label:
                                              "${_assessment['totalWrong'].toString()} Salah",
                                          stretch: true,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                child: Column(
                                  children: _buildListQuestions(
                                      list:
                                          _questionResponse?['results'] ?? []),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelIcon({
    required IconData icon,
    required Color? backgroundColor,
    required Color? color,
    required String label,
    bool stretch = false,
  }) {
    return Row(
      crossAxisAlignment:
          stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.notWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.deactivatedText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _singleOption({
    required bool flag,
    required String content,
    required double point,
    bool active = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: flag
                      ? Colors.green[100]
                      : active
                          ? Colors.red[100]
                          : AppTheme.notWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Html(
                  data: content,
                  style: {
                    '*': Style(
                      color: flag
                          ? Colors.green[900]
                          : active
                              ? Colors.red[900]
                              : Colors.black,
                      fontWeight:
                          flag || active ? FontWeight.bold : FontWeight.normal,
                    )
                  },
                ),
              ),
            ),
            SizedBox(width: 3),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: flag
                      ? Colors.green[100]
                      : active
                          ? Colors.red[100]
                          : AppTheme.notWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  point.toString(),
                  style: TextStyle(
                    color: flag
                        ? Colors.green[900]
                        : active
                            ? Colors.red[900]
                            : Colors.black,
                    fontWeight:
                        flag || active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: flag
                      ? Colors.green[100]
                      : active
                          ? Colors.red[100]
                          : AppTheme.notWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: active
                    ? Icon(
                        Icons.check,
                        color: flag
                            ? Colors.green[900]
                            : active
                                ? Colors.red[900]
                                : Colors.black,
                      )
                    : Container(),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions({
    required List options,
    required dynamic userAnswer,
  }) {
    final widgetBuilder = <Widget>[];

    for (int i = 0; i < options.length; i++) {
      Map<String, dynamic> option = options[i];

      String content = option['htmlAnswer'] ?? 'Empty';
      double point = double.parse(option['point']?.toString() ?? 0.toString());
      bool flag = option['flag'] ?? false;
      int key = option['key'] ?? 0;

      bool isActive = false;

      if (userAnswer is List) {
        isActive = userAnswer.contains(key);
      } else if (userAnswer is int) {
        isActive = userAnswer == key;
      }

      widgetBuilder.add(_singleOption(
        flag: flag,
        content: content,
        point: point,
        active: isActive,
      ));
    }

    return widgetBuilder;
  }

  List<Widget> _buildListQuestions({required List list}) {
    final questionWidgets = <Widget>[];

    for (int i = 0; i < list.length; i++) {
      Map<String, dynamic> item = list[i];

      int key = item['questionKey'] ?? 0;
      String? statement = item['htmlStatement'] ?? null;
      String question = item['htmlQuestion'] ?? 'Empty';
      dynamic userAnswer = item['userAnswer'] ?? null;
      List optionList = item['options'];

      questionWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: _questionSection(
            number: i + 1,
            questionKey: key,
            qType: item['qType'],
            question: question,
            optionList: optionList,
            statement: statement,
            userAnswer: userAnswer,
          ),
        ),
      );
    }

    return questionWidgets;
  }

  Widget _gradesBox({
    required String gradeNumber,
    String? title,
    Color? textColor,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        children: [
          if (!empty(title))
            Column(
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
              ],
            )
          else
            Container(),
          Text(
            gradeNumber,
            style: TextStyle(
              fontSize: 32,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEssay({Map<String, dynamic>? userAnswer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jawaban Kamu : ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: userAnswer == null
                          ? AppTheme.notWhite
                          : userAnswer['correct']
                              ? Colors.green[100]
                              : Colors.red[100],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Html(
                      data: userAnswer == null
                          ? '<strong>Kamu tidak menjawab soal ini</strong>'
                          : userAnswer['text'],
                      style: {
                        '*': Style(
                          color: userAnswer == null
                              ? Colors.black
                              : userAnswer['correct']
                                  ? Colors.green[900]
                                  : Colors.red[900],
                          fontWeight:
                              userAnswer == null ? null : FontWeight.bold,
                        )
                      },
                    ),
                  ),
                ),
                SizedBox(width: 3),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: userAnswer == null
                          ? AppTheme.notWhite
                          : userAnswer['correct']
                              ? Colors.green[100]
                              : Colors.red[100],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      userAnswer == null
                          ? "0.0"
                          : userAnswer['point'].toString(),
                      style: TextStyle(
                        color: userAnswer == null
                            ? Colors.black
                            : userAnswer['correct']
                                ? Colors.green[900]
                                : Colors.red[900],
                        fontWeight: userAnswer == null ? null : FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionSection({
    required int number,
    required int questionKey,
    required String qType,
    required String question,
    required List optionList,
    required String? statement,
    required dynamic userAnswer,
  }) {
    Widget widgetBuilder = Container();

    switch (qType) {
      case 'essay':
        widgetBuilder = _buildEssay(userAnswer: userAnswer);
        break;
      case 'singlechoice':
      case 'multichoice':
        widgetBuilder = Column(
            children: _buildOptions(
          options: optionList,
          userAnswer: userAnswer,
        ));
        break;
      default:
        widgetBuilder = Container();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  'Soal Nomor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    number < 10 ? '0${number.toString()}' : number.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            empty(userAnswer)
                ? Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.yellow[900],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Terlewati',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 0),
        ),
        if (!empty(statement))
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppTheme.notWhite,
                    )),
                child: Html(
                  data: statement.toString(),
                ),
              ),
              SizedBox(height: 10),
            ],
          )
        else
          Container(),
        Html(data: question),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 0),
        ),
        Container(child: widgetBuilder)
      ],
    );
  }

  Widget _referencesHeader({
    required String title,
    String? subtitle,
    String? questionReference,
  }) {
    Widget buildTitle = Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.5,
        color: Colors.black,
      ),
    );

    Widget buildSubtitle = Text(
      subtitle ?? "",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.deactivatedText,
      ),
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subtitle != null
              ? Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [buildTitle, buildSubtitle],
                  ),
                )
              : buildTitle,
          if (!empty(questionReference))
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 15),
                  ExpandChild(
                    arrowPadding: EdgeInsets.all(0),
                    child: Html(
                      data: questionReference,
                      style: {
                        '*': Style(
                          alignment: Alignment.topCenter,
                          textAlign: TextAlign.center,
                          width: double.infinity,
                        )
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Container(),
        ],
      ),
    );
  }
}
