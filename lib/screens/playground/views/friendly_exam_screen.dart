import 'package:expand_widget/expand_widget.dart';
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

class FriendlyExamScreen extends StatefulWidget {
  const FriendlyExamScreen({
    Key? key,
    required this.title,
    required this.onEnd,
    required this.questionList,
    this.subtitle,
    this.questionReference,
    this.duration,
    this.forwardAfterAnswered = false,
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
  final bool forwardAfterAnswered;

  @override
  _FriendlyExamScreenState createState() => _FriendlyExamScreenState();
}

class _FriendlyExamScreenState extends State<FriendlyExamScreen> {
  final _formKey = new GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _currentQuestion = 0;
  int _answeredCount = 0;
  bool _hasDialogOpen = false;
  bool _isTerminated = false;

  late int _duration;
  late int _endTime;
  late bool _enableCountdown;

  late List _questionList;
  late bool _forwardAfterAnswered;
  late List<String> _specialQType;

  late int _totalQuestion;
  late int _questionLimit;
  late bool _nextOverflow;
  late bool _prevOverflow;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _duration = this.widget.duration ?? 0;
    _enableCountdown = _duration >= 5;
    _endTime = DateTime.now().millisecondsSinceEpoch + (1000 * _duration);

    _questionList = this.widget.questionList;
    _forwardAfterAnswered = this.widget.forwardAfterAnswered;
    _specialQType = ['multichoice', 'essay'];

    _totalQuestion = _questionList.length;
    _questionLimit = _totalQuestion - 1;
    _nextOverflow = _currentQuestion >= _questionLimit;
    _prevOverflow = _currentQuestion <= 0;
  }

  String _getReadableNumber(int number) {
    return number > 0 && number < 10
        ? "0${number.toString()}"
        : number.toString();
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

    if (_forwardAfterAnswered &&
        !_specialQType.contains(activeQuestion['qType'])) _next();
  }

  void _setOverflow() {
    setState(() {
      _nextOverflow = _currentQuestion >= _questionLimit;
      _prevOverflow = _currentQuestion <= 0;
    });
  }

  void _next() {
    String qType = _questionList[_currentQuestion]['qType'];

    Future.delayed(
        Duration(
            milliseconds:
                _forwardAfterAnswered && !_specialQType.contains(qType)
                    ? 100
                    : 0), () {
      setState(() {
        if (!_nextOverflow) {
          _currentQuestion += 1;
          _setOverflow();
        } else {
          if (_forwardAfterAnswered) _finish(false);
        }
      });
    });
  }

  void _prev() {
    setState(() {
      if (!_prevOverflow) {
        _currentQuestion -= 1;
        _setOverflow();
      }
    });
  }

  void _move(int index) {
    setState(() {
      _currentQuestion = index;
      _setOverflow();
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
        body: Row(
          children: [
            Expanded(
              flex: 3,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildFlagInfo(color: AppTheme.normalText),
                            SizedBox(width: 25),
                            _buildCountdownTimer(
                              endTime: _enableCountdown ? _endTime : 0,
                              onEnd: () =>
                                  _enableCountdown ? _finish(true) : null,
                              color: AppTheme.normalText,
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 0),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: _buildReferenceHeader(),
                      ),
                      Divider(height: 0),
                      Expanded(
                        child: Container(
                          child: ListView(
                            physics: ScrollPhysics(),
                            padding: EdgeInsets.all(10),
                            shrinkWrap: true,
                            children: [
                              _buildQuestionSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 1),
            Expanded(
              flex: 2,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      headerSliverBuilder: (context, _) {
                        return [
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Container(
                                  width: double.infinity,
                                  height: 0.001,
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                      body: Column(
                        children: [
                          TabBar(
                            indicatorColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: AppTheme.deactivatedText,
                            tabs: [
                              Tab(
                                text: "Opsi Jawaban",
                                icon: Icon(Icons.list_alt_rounded),
                              ),
                              Tab(
                                text: "Denah Soal",
                                icon: Icon(Icons.padding_outlined),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              // Disable horizontal swipe
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                _answerInputBuilder(
                                  qType: _questionList[_currentQuestion]
                                      ['qType'],
                                ),
                                Column(
                                  children: [
                                    _buildBoxIndicator(),
                                    Expanded(child: _buildQuestionGridNumber()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: _forwardAfterAnswered
                    ? _buildSpecialNavButton()
                    : _buildNavButton(),
              ),
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

  Widget _buildEssayInput() {
    String formName = combineTwoKey(
      Constants.essayField,
      _questionList[_currentQuestion]['questionKey'],
    );

    return Padding(
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
            "Jawaban kamu tersimpan otomatis. Jika sudah yakin silahkan lanjutkan!",
            style: TextStyle(
              color: AppTheme.deactivatedText,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOptionList() {
    Map<String, dynamic> activeQuestion = _questionList[_currentQuestion];
    List options = activeQuestion['options'] ?? [];

    return ListView.separated(
      padding: EdgeInsets.all(5),
      shrinkWrap: true,
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

        return _buildSingleOption(
          optionKey: item['key'],
          content: item['htmlAnswer'],
          flag: item['flag'],
          point: item['point'].toDouble(),
          active: isActive,
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 2);
      },
    );
  }

  Widget _buildSpecialNavButton() {
    Map<String, dynamic> activeQuestion = _questionList[_currentQuestion];

    return Container(
      padding: EdgeInsets.all(5),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (!_nextOverflow &&
                  _specialQType.contains(activeQuestion['qType']))
                Expanded(
                  child: _solidButton(
                    label: 'LANJUT',
                    color: Colors.primaries[9],
                    onPressed: _next,
                  ),
                ),
              SizedBox(width: 5),
              if (_nextOverflow &&
                  _specialQType.contains(activeQuestion['qType']))
                Expanded(
                  child: _solidButton(
                    label: "SELESAI",
                    color: Colors.red,
                    onPressed: () => _finish(false),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton() {
    return Container(
      padding: EdgeInsets.all(5),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (!_prevOverflow)
                Expanded(
                  child: _solidButton(
                    label: "SEBELUMNYA",
                    color: Colors.primaries[8],
                    onPressed: _prev,
                  ),
                ),
              SizedBox(
                width: !_prevOverflow && !_nextOverflow ? 5 : 0,
              ),
              if (!_nextOverflow)
                Expanded(
                  child: _solidButton(
                    label: 'LANJUT',
                    color: Colors.primaries[9],
                    onPressed: _next,
                  ),
                ),
              SizedBox(width: 5),
              Expanded(
                child: _solidButton(
                  label: "SELESAI",
                  color: Colors.red,
                  onPressed: () => _finish(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxIndicator() {
    return Material(
      elevation: 1,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _labelIcon(
                icon: Icons.check,
                backgroundColor: Colors.blue,
                color: Colors.white,
                label: 'Terjawab',
                stretch: true,
              ),
              SizedBox(width: 5),
              _labelIcon(
                icon: Icons.push_pin_outlined,
                backgroundColor: Colors.green,
                color: Colors.white,
                label: 'Soal #',
                stretch: true,
              ),
              SizedBox(width: 5),
              _labelIcon(
                icon: Icons.block,
                backgroundColor: AppTheme.disabled,
                color: Colors.white,
                label: 'Terlewati',
                stretch: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionGridNumber() {
    return GridView.count(
      physics: ScrollPhysics(),
      crossAxisCount: 6,
      shrinkWrap: true,
      children: List.generate(
        _questionList.length,
        (index) {
          String readableNumber = _getReadableNumber(index + 1);
          bool answered = !empty(_questionList[index]['userAnswer']);
          Color boxColor = (_currentQuestion == index)
              ? Colors.green
              : answered
                  ? Colors.blue
                  : AppTheme.disabled;

          Widget boxNumber = _boxNumber(
            number: readableNumber,
            color: boxColor,
          );

          return Container(
            margin: EdgeInsets.all(5),
            child: _forwardAfterAnswered
                ? boxNumber
                : Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: () => _move(index), child: boxNumber),
                  ),
          );
        },
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
    Map<String, dynamic> activeQuestion = _questionList[_currentQuestion];
    double indicatorRadius = 100;

    switch (activeQuestion['qType']) {
      case 'multichoice':
        indicatorRadius = 4;
        break;
      case 'singlechoice':
      default:
        indicatorRadius = 100;
        break;
    }

    return Material(
      child: Card(
        color: AppTheme.chipBackground,
        child: TextButton(
          onPressed: () => _selectAnswer(optionKey, flag, point),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Html(
                    data: content,
                  ),
                ),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: active ? Colors.greenAccent : null,
                    border: Border.all(
                      color: Colors.greenAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(indicatorRadius),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildReferenceHeader() {
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            this.widget.subtitle != null
                ? Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [buildTitle, buildSubtitle],
                    ),
                  )
                : buildTitle,
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                child: _boxNumber(
                  color: Colors.green,
                  number: _getReadableNumber(_currentQuestion + 1),
                ),
              ),
            ),
          ],
        ),
        if (!empty(this.widget.questionReference))
          Column(
            children: [
              SizedBox(height: 10),
              ExpandChild(
                arrowPadding: EdgeInsets.all(0),
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
            ],
          )
        else
          Container(),
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

  Widget _solidButton({
    required String label,
    required Color color,
    required void Function()? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        child: Text(label),
        onPressed: onPressed,
      ),
    );
  }

  Widget _labelIcon({
    required IconData icon,
    required Color? backgroundColor,
    required Color? color,
    required String label,
    bool stretch = false,
    bool ltr = false,
  }) {
    Widget labelContainer = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.notWhite,
        borderRadius: BorderRadius.only(
          topLeft: ltr ? Radius.circular(5) : Radius.zero,
          bottomLeft: ltr ? Radius.circular(5) : Radius.zero,
          topRight: ltr ? Radius.zero : Radius.circular(5),
          bottomRight: ltr ? Radius.zero : Radius.circular(5),
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
    );

    Widget iconContainer = Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: ltr ? Radius.zero : Radius.circular(5),
          bottomLeft: ltr ? Radius.zero : Radius.circular(5),
          topRight: ltr ? Radius.circular(5) : Radius.zero,
          bottomRight: ltr ? Radius.circular(5) : Radius.zero,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );

    return Row(
      crossAxisAlignment:
          stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        ltr ? labelContainer : iconContainer,
        ltr ? iconContainer : labelContainer,
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
