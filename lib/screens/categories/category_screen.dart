import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';
import 'package:academic/components/center_list_view.dart';
import 'package:academic/providers/data_category_repository.dart';
import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/utils.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    Key? key,
    required this.title,
    required this.onPress,
  }) : super(key: key);

  final String title;
  final Function(int id, Map<String, dynamic> category) onPress;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FToast _fToast = new FToast();

  final DataCategoryRepository _dataCategoryRepository =
      new DataCategoryRepository();

  bool _waitCategories = true;
  bool _waitBeforeRoute = false;
  Map<String, dynamic>? _categoryResponse;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    _fetchCategories();
  }

  _setWaitBeforeRoute(bool value) {
    setState(() {
      _waitBeforeRoute = value;
    });
  }

  _setWaitCategories(bool value) {
    setState(() {
      _waitCategories = value;
    });
  }

  Future _gotoTargetPage({required int id}) async {
    _setWaitBeforeRoute(true);

    try {
      Map<String, dynamic> category =
          await _dataCategoryRepository.getCategory(id: id);
      _setWaitBeforeRoute(false);

      return Navigator.push(
        context,
        PageTransition(
          child: this.widget.onPress(id, category),
          type: PageTransitionType.rightToLeftWithFade,
        ),
      );
    } catch (e) {
      _setWaitBeforeRoute(false);
      return _fToast.showToast(child: failedToast());
    }
  }

  Future _fetchCategories() async {
    try {
      Map<String, dynamic> data = await _dataCategoryRepository.getAll();
      setState(() {
        _categoryResponse = data;
        _waitCategories = false;
      });
    } catch (e) {
      _setWaitCategories(false);
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
              this.widget.title,
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: SafeArea(
            right: false,
            child: RefreshIndicator(
              onRefresh: _fetchCategories,
              child: _buildCategoryItems(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItems() {
    if (_waitCategories) {
      return Container(
        width: double.infinity,
        child: _buildProgressIndicator(),
      );
    } else if (_categoryResponse == null) {
      return _buildFailure();
    } else {
      Map<String, dynamic> data = _categoryResponse!;

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
                  return _categoryCard(
                    category: item,
                    onTap: () async => _gotoTargetPage(id: item['id']),
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
                  "Belum ada bidang apapun. Beritahu kami atau hubungi layanan untuk validasi.",
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

  Widget _categoryCard({
    required Map<String, dynamic> category,
    required void Function()? onTap,
  }) {
    String name = category['name'];

    bool useDefaultCover = category['coverUrl'] == null;
    String placeholderSrc = "assets/gifs/load.gif";
    String defaultSrc = "assets/images/think.png";
    String primarySrc = category['coverUrl'] ?? defaultSrc;

    Widget Function(ImageProvider<Object> image) imageContainer =
        (image) => Container(
              decoration: BoxDecoration(
                color: AppTheme.dismissibleBackground,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              useDefaultCover
                  ? imageContainer(AssetImage(primarySrc))
                  : CachedNetworkImage(
                      imageUrl: primarySrc,
                      imageBuilder: (context, imageProvider) =>
                          imageContainer(imageProvider),
                      placeholder: (context, url) =>
                          imageContainer(AssetImage(placeholderSrc)),
                    ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  name,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
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
