import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';
import 'package:academic/components/center_list_view.dart';
import 'package:academic/components/label_icon.dart';
import 'package:academic/providers/data_book_repository.dart';
import 'package:academic/providers/data_lesson_repository.dart';
import 'package:academic/screens/books/read_book.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';

class LessonDetailBooks extends StatefulWidget {
  const LessonDetailBooks({
    Key? key,
    required this.lesson,
    required this.title,
  }) : super(key: key);

  final Map<String, dynamic> lesson;
  final String title;

  @override
  _LessonDetailBooksState createState() => _LessonDetailBooksState();
}

class _LessonDetailBooksState extends State<LessonDetailBooks> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DataBookRepository _dataBookRepository = new DataBookRepository();
  final DataLessonRepository _dataLessonRepository = new DataLessonRepository();
  final FToast _fToast = new FToast();

  bool _waitBooks = true;
  bool _waitBeforeRoute = false;

  late Map<String, dynamic> _lesson;
  Map<String, dynamic>? _bookResponse;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _lesson = this.widget.lesson;
    _fetchLessonBooks();
  }

  _setWaitBeforeRoute(bool value) {
    setState(() {
      _waitBeforeRoute = value;
    });
  }

  _setWaitBooks(bool value) async {
    setState(() {
      _waitBooks = value;
    });
  }

  Future _loadData() async {
    await _fetchLesson();
    await _fetchLessonBooks();
  }

  Future _gotoReadBook({required int id}) async {
    _setWaitBeforeRoute(true);

    try {
      Map<String, dynamic> book = await _dataBookRepository.getBook(id: id);
      _setWaitBeforeRoute(false);

      return Navigator.push(
        context,
        PageTransition(
          child: ReadBook(book: book),
          type: PageTransitionType.rightToLeftWithFade,
        ),
      );
    } catch (e) {
      _setWaitBeforeRoute(false);
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchLesson() async {
    try {
      Map<String, dynamic> response =
          await _dataLessonRepository.getLesson(id: _lesson['id']);

      setState(() {
        _lesson = response;
      });
    } catch (e) {
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchLessonBooks() async {
    try {
      Map<String, dynamic> response =
          await _dataLessonRepository.getBooks(lessonId: _lesson['id']);

      setState(() {
        _bookResponse = response;
        _waitBooks = false;
      });
    } catch (e) {
      _setWaitBooks(false);
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
              StringUtils.capitalize(this.widget.title, allWords: true),
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: _buildBookItems(),
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

  Widget _buildBookItems() {
    if (_waitBooks) {
      return Container(
        width: double.infinity,
        child: _buildProgressIndicator(),
      );
    } else if (_bookResponse == null) {
      return _buildFailure();
    } else {
      Map<String, dynamic> data = _bookResponse!;

      if (empty(data['totalResults'])) {
        return _buildEmptyItems(
          message:
              "Mohon maaf, Belum ada materi apapun. Tarik untuk menyegarkan halaman.",
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
                  return _bookCard(
                    book: item,
                    onTap: () async => _gotoReadBook(id: item['id']),
                  );
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

  Widget _bookCard({
    required Map<String, dynamic> book,
    required void Function()? onTap,
  }) {
    String title = book['title'];
    String? description = book['description'];

    // Map<String, dynamic>? lessonInfo = book['lessonInfo'];
    Map<String, dynamic>? authorInfo = book['authorInfo'];

    bool useDefaultCover = book['coverUrl'] == null;
    String placeholderSrc = "assets/gifs/load.gif";
    String defaultSrc = "assets/images/book.png";
    String primarySrc = book['coverUrl'] ?? defaultSrc;

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
                  color: AppTheme.darkGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
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
                            if (authorInfo != null)
                              Column(
                                children: [
                                  LabelIcon(
                                    label: authorInfo['name'],
                                    icon: Icons.badge_outlined,
                                    color: AppTheme.normalText,
                                  ),
                                  Divider(thickness: 0.5),
                                ],
                              )
                            else
                              Container(),
                            description != null
                                ? Html(
                                    data: description,
                                    style: {
                                      '*': Style(
                                          color: AppTheme.deactivatedText),
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      "Tidak ada deskripsi.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.deactivatedText,
                                      ),
                                    ),
                                  ),
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
}
