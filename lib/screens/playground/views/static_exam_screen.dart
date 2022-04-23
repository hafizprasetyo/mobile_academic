import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:academic/components/forms/essay_input.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StaticExamScreen extends StatefulWidget {
  const StaticExamScreen({
    Key? key,
    required this.title,
    required this.onEnd,
    required this.questionList,
    this.subtitle,
    this.questionReference,
    this.duration,
  }) : super(key: key);

  final Function(
    BuildContext context,
    bool overdue,
    int totalQuestions,
    int totalAnswered,
    List questionsTemp,
  ) onEnd;

  final String title;
  final List questionList;
  final String? subtitle;
  final String? questionReference;

  final int? duration;

  @override
  _StaticExamScreenState createState() => _StaticExamScreenState();
}

class _StaticExamScreenState extends State<StaticExamScreen> {
  final _formKey = new GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _currentQuestion = 0;
  int _answeredCount = 0;
  bool _hasDialogOpen = false;
  bool _isTerminated = false;

  late int _duration;
  late int _endTime;
  late int? _staticEndTime;
  late bool _enableCountdown;

  late List _questionList;
  late List<String> _specialQType;

  late int _totalQuestion;
  late int _questionLimit;
  late bool _nextOverflow;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _questionList = this.widget.questionList;
    _specialQType = ['multichoice', 'essay'];

    _duration = this.widget.duration ?? 0;
    _enableCountdown = _duration >= 5;

    _endTime = DateTime.now().millisecondsSinceEpoch + (1000 * _duration);
    _staticEndTime = _setStaticEndTime();

    _totalQuestion = _questionList.length;
    _questionLimit = _totalQuestion - 1;
    _nextOverflow = _currentQuestion >= _questionLimit;
  }

  String _getReadableNumber(int number) {
    return number > 0 && number < 10
        ? "0${number.toString()}"
        : number.toString();
  }

  int? _setStaticEndTime({bool reset = false}) {
    int? apiQuestionDuration = _questionList[_currentQuestion]['duration'];
    int? questionDuration = DateTime.now().millisecondsSinceEpoch;

    if (apiQuestionDuration != null) {
      if (apiQuestionDuration >= 60) {
        questionDuration += (1000 * 59);
      } else if (apiQuestionDuration <= 1) {
        questionDuration = null;
      } else {
        questionDuration += (1000 * apiQuestionDuration);
      }
    } else {
      questionDuration += (1000 * 4);
    }

    if (reset) {
      setState(() {
        _staticEndTime = questionDuration;
      });
    }

    return questionDuration;
  }

  void _typeAnswer(String? value) {
    Map<String, dynamic> activeQuestion = _questionList[_currentQuestion];
    String? userAnswer = empty(value) ? null : value;

    setState(() {
      if (userAnswer != null) {
        if (empty(activeQuestion['userAnswer'])) _answeredCount += 1;
      } else {
        if (!empty(activeQuestion['userAnswer'])) _answeredCount -= 1;
      }

      _questionList[_currentQuestion]['userAnswer'] = userAnswer;
    });
  }

  void _selectAnswer(int optionKey, bool flag, double point) {
    Map<String, dynamic> activeQuestion = _questionList[_currentQuestion];
    dynamic userAnswerInit = activeQuestion['userAnswer'];

    setState(() {
      switch (activeQuestion['qType']) {
        case 'multichoice':
          List userAnswer = userAnswerInit;

          if (userAnswer.contains(optionKey)) {
            // Hapus dan tetapkan jawaban
            userAnswer.remove(optionKey);
            _questionList[_currentQuestion]['userAnswer'] = userAnswer;

            if (empty(userAnswer)) _answeredCount -= 1;
          } else {
            // Hitung jumlah terjawab
            if (empty(userAnswer)) _answeredCount += 1;

            // Tandai dan tetapkan jawaban
            userAnswer.add(optionKey);
            _questionList[_currentQuestion]['userAnswer'] = userAnswer;
          }
          break;
        case 'singlechoice':
          // Hitung jumlah terjawab
          if (empty(userAnswerInit)) _answeredCount += 1;

          // Tetapkan jawaban
          _questionList[_currentQuestion]['userAnswer'] = optionKey;
          break;
      }
    });

    if (!_specialQType.contains(activeQuestion['qType'])) _next();
  }

  void _setOverflow() {
    setState(() {
      _nextOverflow = _currentQuestion >= _questionLimit;
    });
  }

  void _next() {
    String qType = _questionList[_currentQuestion]['qType'];

    Future.delayed(Duration(milliseconds: qType == 'essay' ? 200 : 100), () {
      setState(() {
        if (!_nextOverflow) {
          _currentQuestion += 1;
          _setOverflow();

          _staticEndTime = _setStaticEndTime();
        } else {
          _finish(false);
        }
      });
    });
  }

  Future _forceClose() async {
    bool forwardResult = await _validateDialogInfo(
      message: "Riwayat tes kamu akan hilang. Yakin ingin keluar dari tes ini?",
    );

    if (forwardResult) {
      _resetDialogOpen(false);
      setState(() {
        _isTerminated = true;
      });

      return Navigator.pop(context);
    }
  }

  void _finish(bool overdue) {
    _resetDialogOpen(false);
    if (_isTerminated) return;

    this.widget.onEnd(
          context,
          overdue,
          _questionList.length,
          _answeredCount,
          _questionList,
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: _buildHeader(),
              ),
              Divider(height: 0),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(10),
                  children: [
                    if (!empty(this.widget.questionReference))
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              // border: Border.all(color: AppTheme.disabled),
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: Html(
                              data: this.widget.questionReference,
                              customImageRenders: imageCacheRender(),
                              style: {
                                '*': Style(
                                  alignment: Alignment.topCenter,
                                  textAlign: TextAlign.center,
                                  width: double.infinity,
                                )
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // border: Border.all(color: AppTheme.disabled),
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildQuestionHeader(),
                          Divider(height: 25),
                          _buildQuestionSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 0),
            _answerInputBuilder(
              qType: _questionList[_currentQuestion]['qType'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerInputBuilder({required String qType}) {
    switch (qType) {
      case 'essay':
        return _buildEssayInput();
      case 'multichoice':
      case 'singlechoice':
        return _buildOptionList();
      default:
        return Container();
    }
  }

  Widget _buildQuestionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFlagInfo(color: AppTheme.normalText),
        SizedBox(width: 25),
        Row(
          children: [
            CountdownTimer(
              endTime: _staticEndTime ?? 0,
              onEnd: _staticEndTime != null ? _next : null,
              widgetBuilder:
                  (BuildContext context, CurrentRemainingTime? time) {
                return _boxNumber(
                  color: Colors.red,
                  number: _getReadableNumber(time?.sec ?? 0),
                );
              },
            ),
            SizedBox(width: 5),
            _boxNumber(
              color: Colors.green,
              number: _getReadableNumber(_currentQuestion + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEssayInput() {
    String formName = combineTwoKey(
      Constants.essayField,
      _questionList[_currentQuestion]['questionKey'],
    );

    return Container(
      constraints: BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilder(
              key: _formKey,
              child: EssayInput(
                name: formName,
                value: _questionList[_currentQuestion]['userAnswer'],
              ),
              onChanged: () {
                if (_formKey.currentState!.saveAndValidate()) {
                  _typeAnswer(_formKey.currentState!.value[formName]);
                }
              },
            ),
            SizedBox(height: 10),
            Text(
              "Jawaban kamu tersimpan otomatis!",
              style: TextStyle(
                color: AppTheme.deactivatedText,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOptionList() {
    Map<String, dynamic> activeQuestion = _questionList[_currentQuestion];
    List options = activeQuestion['options'] ?? [];

    return Container(
      height: 80,
      child: Center(
        child: ListView.separated(
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> item = options[index];
            bool isActive = false;

            switch (activeQuestion['qType']) {
              case 'multichoice':
                List selectedAnswers = activeQuestion['userAnswer'];
                isActive = selectedAnswers.contains(item['key']);
                break;
              case 'singlechoice':
                int? selectedAnswer = activeQuestion['userAnswer'];
                isActive = item['key'] == selectedAnswer;
                break;
            }

            return Container(
              constraints: BoxConstraints(minWidth: 80),
              child: _buildSingleOption(
                optionKey: item['key'],
                content: item['htmlAnswer'],
                flag: item['flag'],
                point: item['point'].toDouble(),
                active: isActive,
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(width: 5);
          },
        ),
      ),
    );
  }

  Widget _buildSingleOption({
    required int optionKey,
    required String content,
    required bool flag,
    required double point,
    bool active = false,
  }) {
    String qType = _questionList[_currentQuestion]['qType'];
    Color? bgColor;
    Color? borderColor;

    switch (qType) {
      case 'singlechoice':
        bgColor = Colors.yellow[800];
        borderColor = Colors.transparent;
        break;
      case 'multichoice':
        bgColor = Colors.transparent;
        borderColor = Colors.yellow[800];
    }

    return InkWell(
      onTap: () => _selectAnswer(optionKey, flag, point),
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.greenAccent : bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: active
                  ? Colors.transparent
                  : borderColor ?? Colors.greenAccent),
        ),
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Html(
              data: content,
              shrinkWrap: true,
              style: {
                '*': Style(
                  alignment: Alignment.center,
                  textAlign: TextAlign.center,
                  fontSize: content.length <= 10 ? FontSize.em(2) : null,
                  fontWeight: content.length <= 10 ? FontWeight.bold : null,
                )
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection({Widget? header}) {
    return Column(
      children: [
        header ?? Container(),
        if (!empty(header))
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 0),
          )
        else
          Container(),
        if (!empty(_questionList[_currentQuestion]['htmlStatement'] ?? false))
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppTheme.notWhite,
                    )),
                child: Html(
                  data: _questionList[_currentQuestion]['htmlStatement'] ?? '',
                ),
              ),
              SizedBox(height: 10),
            ],
          )
        else
          Container(),
        Html(
          data: _questionList[_currentQuestion]['htmlQuestion'] ?? '',
        ),
      ],
    );
  }

  Widget _buildHeader() {
    Widget buildTitle = Text(
      this.widget.title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: this.widget.subtitle != null ? 1.5 : null,
        color: Colors.black,
      ),
    );

    Widget buildSubtitle = Text(
      this.widget.subtitle ?? "",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.deactivatedText,
      ),
    );

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red[900],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: IconButton(
              onPressed: _forceClose,
              icon: Icon(
                Icons.close_outlined,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        this.widget.subtitle != null
            ? Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [buildTitle, buildSubtitle],
                ),
              )
            : buildTitle,
        Expanded(child: Container()),
        Container(
          alignment: Alignment.centerLeft,
          child: _buildCountdownTimer(
            endTime: _enableCountdown ? _endTime : 0,
            onEnd: () => _enableCountdown ? _finish(true) : null,
            color: AppTheme.normalText,
          ),
        ),
      ],
    );
  }

  Widget _buildFlagInfo({
    Color color = AppTheme.disabled,
  }) {
    String totalAnswered = _getReadableNumber(_answeredCount);
    String totalQuestion = _getReadableNumber(_totalQuestion);

    TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: color,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          FontAwesomeIcons.flag,
          size: 25,
          color: Colors.blue,
        ),
        SizedBox(width: 10),
        Text(
          "$totalAnswered / $totalQuestion",
          style: labelStyle,
        ),
      ],
    );
  }

  Widget _buildCountdownTimer({
    required int endTime,
    required void Function()? onEnd,
    Color color = AppTheme.disabled,
  }) {
    TextStyle numberStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: color,
    );

    TextStyle separatorStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: color,
    );

    return Row(
      children: [
        CountdownTimer(
          endTime: endTime,
          onEnd: onEnd,
          widgetBuilder: (BuildContext context, CurrentRemainingTime? time) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${time?.hours ?? '00'}", style: numberStyle),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
                  child: Text(':', style: separatorStyle),
                ),
                Text("${time?.min ?? '00'}", style: numberStyle),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
                  child: Text(':', style: separatorStyle),
                ),
                Text("${time?.sec ?? '00'}", style: numberStyle),
              ],
            );
          },
        ),
        SizedBox(width: 10),
        Icon(
          FontAwesomeIcons.stopwatch,
          size: 25,
          color: Colors.red[900],
        ),
      ],
    );
  }

  Widget _boxNumber({
    required String number,
    Color? color,
  }) {
    return Container(
      width: 50,
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color ?? AppTheme.notWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
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
