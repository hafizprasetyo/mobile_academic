import 'package:auto_size_text/auto_size_text.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:academic/providers/data_book_repository.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';

class ReadBook extends StatefulWidget {
  const ReadBook({
    Key? key,
    required this.book,
  }) : super(key: key);

  final Map<String, dynamic> book;

  @override
  _ReadBookState createState() => _ReadBookState();
}

class _ReadBookState extends State<ReadBook> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DataBookRepository _dataBookRepository = new DataBookRepository();
  final FToast _fToast = new FToast();

  bool _waitBeforeRoute = false;

  late Map<String, dynamic> _book;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _book = this.widget.book;
  }

  Future _fetchBook() async {
    try {
      Map<String, dynamic> response =
          await _dataBookRepository.getBook(id: _book['id']);

      setState(() {
        _book = response;
      });
    } catch (e) {
      return _fToast.showToast(child: failedToast());
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
          body: RefreshIndicator(
            onRefresh: _fetchBook,
            child: Row(
              children: [
                Expanded(
                  flex: size.width > 1340 ? 3 : 5,
                  child: DefaultTabController(
                    length: 1,
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        centerTitle: false,
                        leading: MaterialButton(
                          minWidth: 20,
                          onPressed: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 15,
                          ),
                        ),
                        title: Text(
                          StringUtils.capitalize(
                            _book['title'],
                            allWords: true,
                          ),
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      body: SafeArea(
                        child: _buildBookInfo(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2),
                Expanded(
                  flex: size.width > 1340 ? 8 : 10,
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: SafeArea(child: _buildBookContent()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    bool useDefaultCover = _book['coverUrl'] == null;

    String placeholderSrc = "assets/gifs/load.gif";
    String defaultSrc = "assets/images/book.png";
    String primarySrc = _book['coverUrl'] ?? defaultSrc;

    Widget Function(ImageProvider<Object> image) imageContainer =
        (image) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ),
            );

    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        Container(
          width: double.infinity,
          height: 240,
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
        Divider(color: AppTheme.chipBackground),
        _book['description'] != null
            ? Padding(
                padding: const EdgeInsets.all(5),
                child: Html(
                  data: _book["description"],
                  style: {
                    '*': Style(
                      color: AppTheme.deactivatedText,
                    )
                  },
                ),
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
    );
  }

  Widget _buildBookContent() {
    Map<String, dynamic>? authorInfo = _book['authorInfo'];

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: AutoSizeText(
                _book['title'],
                softWrap: true,
                minFontSize: 0,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (authorInfo != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Icon(
                        Icons.badge_outlined,
                        color: AppTheme.deactivatedText,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 5),
                    AutoSizeText(
                      authorInfo['name'],
                      minFontSize: 0,
                      style: TextStyle(
                        color: AppTheme.deactivatedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 10),
          Divider(height: 0),
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                child: Html(
                  data: _book['text'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
