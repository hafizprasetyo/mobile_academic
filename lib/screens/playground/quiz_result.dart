import 'package:expand_widget/expand_widget.dart';
import 'package:academic/components/exception/exception_controller.dart';
import 'package:academic/exceptions/api_exception.dart';
import 'package:academic/models/user.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'default_result.dart';

class QuizResult extends StatefulWidget {
  const QuizResult({
    Key? key,
    required this.task,
    required this.title,
    required this.finalGrades,
    required this.passingGrades,
    required this.submissionList,
    this.showPredicate = true,
    this.showPassingGrades = true,
  }) : super(key: key);

  final String title;
  final Map<String, dynamic> task;

  final List submissionList;

  final String finalGrades;
  final String passingGrades;
  final bool showPassingGrades;
  final bool showPredicate;

  @override
  _QuizResultState createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  final DataAuthenticationRepository _dataAuthenticationRepository =
      new DataAuthenticationRepository();

  bool _waiting = true;

  late Map<String, dynamic> _task;

  late String _title;
  late bool _showPredicate;
  late bool _showPassingGrades;
  late double _passingGrades;
  late double _finalGrades;

  late List _submissionList;

  User? _user;

  @override
  void initState() {
    super.initState();

    _task = this.widget.task;
    _title = this.widget.title;
    _showPredicate = this.widget.showPredicate;
    _showPassingGrades = this.widget.showPassingGrades;
    _submissionList = this.widget.submissionList;

    _passingGrades = double.parse(this.widget.passingGrades);
    _finalGrades = double.parse(this.widget.finalGrades);

    _fetchCurrentUser();
    _waiting = false;
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

  _gotoExamResult({required Map<String, dynamic> submission}) {
    String taskName = _task['name'];

    int id = submission['submissionId'];
    String itemName = submission['name'];
    Map<String, dynamic> info = submission['resultInfo'];

    String endpoint = Constants.quizAttemptQuestionsEndpoint.replaceAll(
      '{key}',
      id.toString(),
    );

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DefaultResult(
          questionsEndpoint: endpoint,
          title: "$taskName",
          subtitle: "$itemName",
          questionReference: submission['htmlReference'],
          assessment: info,
          finalGrades: submission['finalGrades'].toString(),
          passingGrades: "0",
          showPassingGrades: false,
          showPredicate: false,
        ),
      ),
    );
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
    return ModalProgressHUD(
      inAsyncCall: _waiting,
      color: Colors.white,
      opacity: 1,
      child: Scaffold(
        backgroundColor: Colors.blue[800],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue[800],
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          title: Text(
            'RINCIAN TES',
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
                        _user?.fullName ?? "Anonim",
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
                                backgroundColor: _finalGrades >= _passingGrades
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
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
                  padding: EdgeInsets.only(bottom: 175),
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
                        child: _referencesHeader(title: _title),
                      ),
                      Divider(height: 0),
                      Container(
                        child: ListView.separated(
                          padding: EdgeInsets.all(15),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _submissionList.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> submission =
                                _submissionList[index];

                            return _submissionCard(
                              submission: submission,
                              onTap: (id, item) =>
                                  _gotoExamResult(submission: item),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 8);
                          },
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
    );
  }

  Widget _submissionCard({
    required Map<String, dynamic> submission,
    required void Function(int submissionId, Map<String, dynamic> details)
        onTap,
  }) {
    int submissionId = submission['submissionId'];
    String name = submission['name'];
    Map<String, dynamic> info = submission['resultInfo'];

    double finalGrades = double.parse(submission['finalGrades'].toString());

    int totalCorrect = info['totalCorrect'];
    int totalWrong = info['totalWrong'];
    int totalQuestion = info['totalQuestion'];

    return GestureDetector(
      onTap: () => onTap(submissionId, submission),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Container(
            child: Column(
              children: [
                Container(
                  child: ListTile(
                    trailing: Icon(Icons.arrow_forward_rounded),
                    title: Text(name, style: AppTheme.textTheme.headline6),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: Column(
                    children: [
                      _flatTile(
                        leading: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total Nilai',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        child: Text(finalGrades.toString()),
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
          if (title != null)
            Column(
              children: [
                Text(
                  title,
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

  Widget _referencesHeader({
    required String title,
    String? questionReference,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.5,
            color: Colors.black,
          ),
        ),
        if (questionReference != null)
          Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 15),
                ExpandChild(
                  arrowPadding: EdgeInsets.all(0),
                  child: Text(questionReference),
                ),
              ],
            ),
          )
        else
          Container(),
      ],
    );
  }
}
