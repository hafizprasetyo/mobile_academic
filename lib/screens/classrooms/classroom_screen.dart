import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';
import 'package:academic/components/center_list_view.dart';
import 'package:academic/components/forms/secure_key_input.dart';
import 'package:academic/components/label_icon.dart';
import 'package:academic/providers/data_classroom_repository.dart';
import 'package:academic/providers/data_user_repository.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({
    Key? key,
    required this.title,
    required this.onPress,
  }) : super(key: key);

  final String title;
  final Function(int id, Map<String, dynamic> classroom) onPress;

  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  final GlobalKey<FormBuilderState> _formKey =
      new GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FToast _fToast = new FToast();

  final DataUserRepository _dataUserRepository = new DataUserRepository();
  final DataClassroomRepository _dataClassroomRepository =
      new DataClassroomRepository();

  bool _waitClassrooms = true;
  bool _waitBeforeRoute = false;
  Map<String, dynamic>? _classroomResponse;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _fetchUserClassrooms();
  }

  _setWaitBeforeRoute(bool value) {
    setState(() {
      _waitBeforeRoute = value;
    });
  }

  _setWaitClassrooms(bool value) {
    setState(() {
      _waitClassrooms = value;
    });
  }

  Future _gotoClassroomDetail({required int id}) async {
    _setWaitBeforeRoute(true);
    bool validToRoute = true;

    try {
      Map<String, dynamic> classroom =
          await _dataClassroomRepository.getClassroom(id: id);
      _setWaitBeforeRoute(false);

      if (!classroom['alreadyNow']) {
        return _showDialogInfo(
            "Ruang tes tutup, akses kembali ketika ruang tes ini telah dibuka.");
      }

      if (classroom['secure']) {
        validToRoute =
            await _validateSecureKey(originalKey: classroom['secureKey']);
      }

      if (validToRoute) {
        return Navigator.push(
          context,
          PageTransition(
            child: this.widget.onPress(id, classroom),
            type: PageTransitionType.rightToLeftWithFade,
          ),
        );
      }
    } catch (e) {
      _setWaitBeforeRoute(false);
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchUserClassrooms() async {
    try {
      Map<String, dynamic> data = await _dataUserRepository.getClassrooms();
      setState(() {
        _classroomResponse = data;
        _waitClassrooms = false;
      });
    } catch (e) {
      _setWaitClassrooms(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_waitBeforeRoute,
      child: ModalProgressHUD(
        inAsyncCall: _waitBeforeRoute,
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
              this.widget.title.toUpperCase(),
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: SafeArea(
            right: false,
            child: RefreshIndicator(
              onRefresh: _fetchUserClassrooms,
              child: FutureBuilder(
                future: Future.delayed(
                  Duration(milliseconds: 500),
                  () => _fetchUserClassrooms(),
                ),
                builder: (context, snapshot) {
                  return _buildClassroomItems();
                },
              ),
            ),
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

  Future<bool> _validateSecureKey({required String originalKey}) async {
    bool status = false;

    return await showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Text("Konfirmasi Kunci Akses"),
          actionsPadding: EdgeInsets.all(15),
          content: Builder(
            builder: (context) {
              return Container(
                width: 360,
                child: FormBuilder(
                  key: _formKey,
                  child: SecureKeyInput(
                    originalKey: originalKey,
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      label: "YAKIN",
                      backgroundColor: AppTheme.mainBtn,
                      onPressed: () {
                        if (_formKey.currentState!.saveAndValidate()) {
                          status = true;
                          return Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((v) => status);
  }

  Widget _buildClassroomItems() {
    if (_waitClassrooms) {
      return Container(
        width: double.infinity,
        child: _buildProgressIndicator(),
      );
    } else if (_classroomResponse == null) {
      return _buildFailure();
    } else {
      Map<String, dynamic> data = _classroomResponse!;

      if (empty(data['totalResults'])) {
        return _buildEmptyItems();
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
                  return _classroomCard(
                    classroom: item,
                    onTap: () async => _gotoClassroomDetail(id: item['id']),
                  );
                },
              ),
            )
          ],
        );
      }
    }
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

  Widget _buildEmptyItems() {
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
                  "Kamu belum memiliki ruang simulasi. Beritahu kami atau hubungi layanan untuk bergabung.",
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

  Widget _classroomCard({
    required Map<String, dynamic> classroom,
    required void Function()? onTap,
  }) {
    String name = classroom['name'];
    String? openAt = classroom['openAt'] ?? null;
    String? closeAt = classroom['closeAt'] ?? null;
    bool alreadyNow = classroom['alreadyNow'];

    int totalPasrticipants = classroom['totalParticipants'];

    bool useDefaultCover = classroom['coverUrl'] == null;
    String placeholderSrc = "assets/gifs/load.gif";
    String defaultSrc = "assets/images/classroom.png";
    String primarySrc = classroom['coverUrl'] ?? defaultSrc;

    Widget Function(ImageProvider<Object> image) imageContainer =
        (image) => Container(
              decoration: BoxDecoration(
                color: AppTheme.dismissibleBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                image: DecorationImage(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ),
            );

    Widget scheduleView;

    if (alreadyNow && closeAt != null) {
      scheduleView = LabelIcon(
        icon: Icons.lock_clock_outlined,
        label: closeAt,
      );
    } else if (!alreadyNow && openAt != null) {
      scheduleView = LabelIcon(
        icon: Icons.lock_open_outlined,
        label: openAt,
      );
    } else {
      scheduleView = Container();
    }

    return Container(
      width: 420,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        child: InkWell(
          onTap: onTap,
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
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      LabelIcon(
                        iconColor:
                            alreadyNow ? Colors.greenAccent : AppTheme.disabled,
                        icon: alreadyNow
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        label: alreadyNow
                            ? "Sedang Berlangsung"
                            : "Belum Tersedia",
                        iconSize: 16,
                      ),
                      Divider(),
                      scheduleView,
                      LabelIcon(
                        icon: Icons.supervisor_account_outlined,
                        label: "${totalPasrticipants.toString()} Partisipan",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
