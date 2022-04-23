import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:academic/components/center_list_view.dart';
import 'package:academic/components/label_icon.dart';
import 'package:academic/models/user.dart';
import 'package:academic/providers/data_classroom_repository.dart';
import 'package:academic/providers/data_lesson_repository.dart';
import 'package:academic/screens/playground/static_quiz_exam.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClassroomDetailStatic extends StatefulWidget {
  const ClassroomDetailStatic(
      {Key? key, required this.classroom, this.categoryId})
      : super(key: key);

  final Map<String, dynamic> classroom;
  final int? categoryId;

  @override
  _ClassroomDetailStaticState createState() => _ClassroomDetailStaticState();
}

class _ClassroomDetailStaticState extends State<ClassroomDetailStatic> {
  final DataClassroomRepository _dataClassroomRepository =
      new DataClassroomRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DataLessonRepository _dataLessonRepository = new DataLessonRepository();
  final FToast _fToast = new FToast();

  bool _waitLessons = true;
  bool _waitParticipants = true;
  bool _waitBeforeRoute = false;

  late Map<String, dynamic> _classroom;
  Map<String, dynamic>? _lessonResponse;
  Map<String, dynamic>? _participantResponse;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _classroom = this.widget.classroom;
    _fetchClassroomLessons();
    _fetchClassroomParticipants();
  }

  _setWaitBeforeRoute(bool value) {
    setState(() {
      _waitBeforeRoute = value;
    });
  }

  _setWaitLessons(bool value) async {
    setState(() {
      _waitLessons = value;
    });
  }

  _setWaitParticipants(bool value) async {
    setState(() {
      _waitParticipants = value;
    });
  }

  _redirectBack() async {
    return Navigator.pop(context);
  }

  Future _loadData() async {
    await _fetchClassroom();
    await _fetchClassroomLessons();
    await _fetchClassroomParticipants();
  }

  Future _gotoPlayground({required int id}) async {
    _setWaitBeforeRoute(true);
    bool validToRoute = false;

    try {
      Map<String, dynamic> lesson =
          await _dataLessonRepository.getLesson(id: id);
      _setWaitBeforeRoute(false);

      if (empty(lesson['totalItems'])) {
        return await _showDialogInfo(
          "Mohon maaf, belum ada butir tes pada modul ini.",
        );
      }

      validToRoute = await _startDialog(lesson: lesson);
      if (!validToRoute) return await _loadData();

      if (lesson['stateMode'] == 'quiztest') {
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaticQuizExam(
              classroom: _classroom,
              lesson: lesson,
            ),
          ),
        );
      }
    } catch (e) {
      _setWaitBeforeRoute(false);
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchClassroom() async {
    try {
      Map<String, dynamic> response =
          await _dataClassroomRepository.getClassroom(id: _classroom['id']);

      setState(() {
        _classroom = response;
      });

      if (!_classroom['alreadyNow']) return _redirectBack();
    } catch (e) {
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchClassroomParticipants() async {
    try {
      Map<String, dynamic> response = await _dataClassroomRepository
          .getParticipants(classroomId: _classroom['id']);

      setState(() {
        _participantResponse = response;
        _waitParticipants = false;
      });
    } catch (e) {
      _setWaitParticipants(false);
    }
  }

  Future _fetchClassroomLessons() async {
    try {
      Map<String, dynamic> response = await _dataClassroomRepository.getLessons(
          classroomId: _classroom['id'], categoryId: widget.categoryId);

      setState(() {
        _lessonResponse = response;
        _waitLessons = false;
      });
    } catch (e) {
      _setWaitLessons(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => !_waitBeforeRoute,
      child: ModalProgressHUD(
        inAsyncCall: _waitBeforeRoute,
        child: Scaffold(
          key: _scaffoldKey,
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
              _classroom['name'] ?? '',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: Row(
              children: [
                // Expanded(
                //   flex: size.width > 1340 ? 3 : 5,
                //   child: DefaultTabController(
                //     length: 2,
                //     child: Scaffold(
                //       backgroundColor: Colors.white,
                //       appBar: AppBar(
                //         backgroundColor: Colors.white,
                //         elevation: 0,
                //         centerTitle: false,
                //         bottom: TabBar(
                //           indicatorColor: Theme.of(context).primaryColor,
                //           unselectedLabelColor: AppTheme.deactivatedText,
                //           tabs: [
                //             Tab(
                //               text: "Informasi",
                //               icon: Icon(Icons.info_outlined),
                //             ),
                //             Tab(
                //               text: "Partisipan",
                //               icon: Icon(Icons.supervisor_account_outlined),
                //             ),
                //           ],
                //         ),
                //         leading: MaterialButton(
                //           minWidth: 20,
                //           onPressed: () => Navigator.pop(context),
                //           child: Icon(
                //             Icons.arrow_back_ios,
                //             size: 15,
                //           ),
                //         ),
                //         title: Text(
                //           StringUtils.capitalize(
                //             _classroom['name'],
                //             allWords: true,
                //           ),
                //           style: TextStyle(fontSize: 16),
                //           softWrap: true,
                //         ),
                //       ),
                //       body: SafeArea(
                //         child: TabBarView(
                //           children: [
                //             _buildClassroomInfo(),
                //             _buildParticipantItems(),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: size.width > 1340 ? 8 : 10,
                  child: _buildLessonItems(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailure() {
    return CenterListView(
      children: [
        Padding(
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
        )
      ],
    );
  }

  Widget _buildClassroomInfo() {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        SizedBox(height: 10),
        // Container(
        //   margin: EdgeInsets.symmetric(horizontal: 10),
        //   child: _flatTile(
        //     leadingColor: Colors.green[100],
        //     childColor: Colors.red[100],
        //     leading: Text(
        //       "BUKA",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.green[900],
        //       ),
        //     ),
        //     child: Text(
        //       "TUTUP",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.red[900],
        //       ),
        //     ),
        //   ),
        // ),
        // Container(
        //   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //   child: _flatTile(
        //     leadingColor: Colors.green[100],
        //     childColor: Colors.red[100],
        //     leading: Text(
        //       "${_classroom['openAt'] ?? '-'}",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         color: Colors.green[900],
        //       ),
        //     ),
        //     child: Text(
        //       "${_classroom['closeAt'] ?? '-'}",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         color: Colors.red[900],
        //       ),
        //     ),
        //   ),
        // ),
        // Divider(),
        _classroom['htmlDesc'] != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Html(
                  data: _classroom["htmlDesc"],
                  style: {
                    '*': Style(
                      color: AppTheme.deactivatedText,
                    )
                  },
                ),
              )
            : Text(
                "Tidak ada deskripsi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.deactivatedText,
                ),
              ),
      ],
    );
  }

  Widget _buildParticipantItems() {
    if (_waitParticipants) {
      return Container(
        width: double.infinity,
        child: _buildProgressIndicator(),
      );
    } else if (_participantResponse == null) {
      return _buildFailure();
    } else {
      Map<String, dynamic> data = _participantResponse!;

      if (empty(data['totalResults'])) {
        return _buildEmptyItems(
          message: "Belum ada partisipan yang bergabung ke ruang simulasi ini.",
        );
      } else {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: data['totalResults'],
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            User user = User.fromMap(data['results'][index]);

            return InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    user.photoUrl != null
                        ? Flexible(
                            child: CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Flexible(
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.notWhite,
                              ),
                              child: Text(
                                user.fullName.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: AppTheme.deactivatedText,
                                ),
                              ),
                            ),
                          ),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Text(user.fullName),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Widget _buildLessonItems() {
    if (_waitLessons) {
      return Container(
        width: double.infinity,
        child: _buildProgressIndicator(),
      );
    } else if (_lessonResponse == null) {
      return _buildFailure();
    } else {
      Map<String, dynamic> data = _lessonResponse!;

      if (empty(data['totalResults'])) {
        return _buildEmptyItems(
          message:
              "Mohon maaf, Belum ada modul apapun. Tarik untuk menyegarkan halaman.",
        );
      } else {
        return CenterListView(
          children: [
            Container(
              height: 240,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: data['totalResults'],
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = data['results'][index];

                  if (item['stateMode'] == 'quiztest') {
                    return _lessonCard(
                      lesson: item,
                      onTap: () async => _gotoPlayground(id: item['id']),
                    );
                  }

                  return Container();
                },
              ),
            )
          ],
        );
      }
    }
  }

  Widget _buildEmptyItems({required String message}) {
    return CenterListView(
      children: [
        Padding(
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
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.deactivatedText),
                ),
              ),
            ],
          ),
        )
      ],
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

  // Widget _flatTile({
  //   required Widget child,
  //   Widget? leading,
  //   Widget? trailing,
  //   int? childWeight,
  //   int? leadingWeight,
  //   int? trailingWeight,
  //   Color? childColor,
  //   Color? leadingColor,
  //   Color? trailingColor,
  //   double borderRadius = 4,
  // }) {
  //   return IntrinsicHeight(
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         if (leading != null)
  //           Expanded(
  //             flex: leadingWeight ?? 1,
  //             child: Container(
  //               alignment: Alignment.center,
  //               padding: EdgeInsets.all(5),
  //               margin: EdgeInsets.only(right: 5),
  //               decoration: BoxDecoration(
  //                 color: leadingColor ?? AppTheme.notWhite,
  //                 borderRadius: BorderRadius.circular(borderRadius),
  //               ),
  //               child: leading,
  //             ),
  //           )
  //         else
  //           Container(),
  //         Expanded(
  //           flex: childWeight ?? 1,
  //           child: Container(
  //             alignment: Alignment.center,
  //             padding: EdgeInsets.all(5),
  //             decoration: BoxDecoration(
  //               color: childColor ?? AppTheme.notWhite,
  //               borderRadius: BorderRadius.circular(borderRadius),
  //             ),
  //             child: child,
  //           ),
  //         ),
  //         if (trailing != null)
  //           Expanded(
  //             flex: trailingWeight ?? 1,
  //             child: Container(
  //               alignment: Alignment.center,
  //               padding: EdgeInsets.all(5),
  //               margin: EdgeInsets.only(left: 5),
  //               decoration: BoxDecoration(
  //                 color: trailingColor ?? AppTheme.notWhite,
  //                 borderRadius: BorderRadius.circular(borderRadius),
  //               ),
  //               child: trailing,
  //             ),
  //           )
  //         else
  //           Container(),
  //       ],
  //     ),
  //   );
  // }

  Widget _lessonCard({
    required Map<String, dynamic> lesson,
    required void Function()? onTap,
  }) {
    String name = lesson['name'];

    // bool hasDuration = lesson['hasDuration'];
    String readableDuration = lesson['readableDuration'] ?? 'Sampai Selesai';

    Map<String, dynamic>? categoryInfo = lesson['categoryInfo'];
    Map<String, dynamic>? subcategoryInfo = lesson['subcategoryInfo'];
    Map<String, dynamic>? authorInfo = lesson['authorInfo'];

    int totalItems = lesson['totalItems'];
    String stateMode = lesson['stateMode'];

    Color? colorMode =
        (stateMode == 'quiztest') ? Colors.orange[200] : Colors.blue[200];
    String readableMode = (stateMode == 'quiztest') ? 'Kuesioner' : 'Soal';
    String readableCount = "$totalItems $readableMode";

    bool useDefaultCover = lesson['coverUrl'] == null;
    String placeholderSrc = "assets/gifs/load.gif";
    String defaultSrc = "assets/images/feedbackImage.png";
    String primarySrc = lesson['coverUrl'] ?? defaultSrc;

    Widget Function(ImageProvider<Object> image) imageContainer =
        (image) => Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ),
            );

    return Container(
      width: 420,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorMode,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: useDefaultCover
                          ? imageContainer(AssetImage(primarySrc))
                          : CachedNetworkImage(
                              imageUrl: primarySrc,
                              imageBuilder: (context, imageProvider) =>
                                  imageContainer(imageProvider),
                              placeholder: (context, url) =>
                                  imageContainer(AssetImage(placeholderSrc)),
                            ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: ListView(
                          physics: ClampingScrollPhysics(),
                          children: [
                            LabelIcon(
                              label: readableDuration,
                              icon: Icons.access_alarm_rounded,
                            ),
                            Divider(thickness: 0.5),
                            LabelIcon(
                              label: readableCount,
                              icon: Icons.description_outlined,
                            ),
                            if (categoryInfo != null && subcategoryInfo != null)
                              Column(
                                children: [
                                  Divider(thickness: 0.5),
                                  LabelIcon(
                                    label:
                                        "${categoryInfo['name']}, ${subcategoryInfo['name']}",
                                    icon: Icons.bookmark_outline_rounded,
                                  ),
                                ],
                              )
                            else
                              Container(),
                            if (authorInfo != null)
                              Column(
                                children: [
                                  Divider(thickness: 0.5),
                                  LabelIcon(
                                    label: authorInfo['name'],
                                    icon: Icons.badge_outlined,
                                  ),
                                ],
                              )
                            else
                              Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showDialogInfo(String message) async {
    return await showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Text("Informasi"),
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
            flatButton(
              label: "MENGERTI",
              backgroundColor: AppTheme.mainBtn,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _startDialog({required Map<String, dynamic> lesson}) async {
    bool status = false;

    Widget infoView = Icon(
      FontAwesomeIcons.bell,
      color: Colors.green[900],
      size: 42,
    );

    if (lesson['hasDuration']) {
      infoView = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.stopwatch,
            color: Colors.red[900],
            size: 22,
          ),
          SizedBox(width: 10),
          Text(
            lesson['readableDuration'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
        ],
      );
    }

    return await showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: LabelIcon(
            label: lesson['name'],
            icon: Icons.feed_outlined,
            color: AppTheme.normalText,
          ),
          content: Builder(
            builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  width: 360,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      infoView,
                      SizedBox(height: 20),
                      Text(
                        "Silahkan mengerjakan dan selesaikan tes sampai batas waktu yang ditentukan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      lesson['htmlDesc'] != null
                          ? Column(
                              children: [
                                SizedBox(height: 10),
                                Divider(thickness: 1),
                                Html(data: lesson['htmlDesc']),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: flatButton(
                    label: "BATAL",
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: flatButton(
                    label: "KERJAKAN",
                    backgroundColor: AppTheme.mainBtn,
                    onPressed: () {
                      status = true;
                      return Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((v) => status);
  }
}
