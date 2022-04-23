import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:academic/models/user.dart';
import 'package:academic/screens/categories/category_screen.dart';
import 'package:academic/screens/classrooms/classroom_detail_book.dart';
import 'package:academic/screens/classrooms/classroom_detail_simulation.dart';
import 'package:academic/screens/classrooms/classroom_detail_static.dart';
import 'package:academic/screens/classrooms/classroom_screen.dart';
import 'package:academic/screens/login.dart';
import 'package:academic/screens/profile/profile_screen.dart';
import 'package:academic/utils/app_theme.dart';

import 'package:academic/utils/constants.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = this.widget.user;
  }

  _gotoBook() {
    return Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: ClassroomScreen(
          title: 'Ruang Belajar',
          onPress: (id, data) => ClassroomDetailBook(classroom: data),
        ),
      ),
      (route) => true,
    );
  }

  _gotoSimulation() {
    return Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: ClassroomScreen(
          title: 'Ruang Simulasi',
          onPress: (key, data) => CategoryScreen(
            title: data['name'],
            onPress: (id, category) =>
                ClassroomDetailSimulation(classroom: data, categoryId: id),
          ),
        ),
      ),
      (route) => true,
    );
  }

  _gotoStaticSimulation() {
    return Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: ClassroomScreen(
          title: 'Ruang Kecermatan',
          onPress: (key, data) => CategoryScreen(
            title: data['name'],
            onPress: (id, category) =>
                ClassroomDetailStatic(classroom: data, categoryId: id),
          ),
        ),
      ),
      (route) => true,
    );
  }

  _gotoProfile() async {
    return Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: ProfileScreen(),
      ),
      (route) => true,
    );
  }

  _gotoLogin() async {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _menuList = [
      _cardMenu(
        title: "MATERI",
        imgSrc: "assets/images/menu_book.jpg",
        shortText: "Bahan belajar serta panduan pengerjaan",
        onTap: _gotoBook,
      ),
      _cardMenu(
        title: "SIMULASI",
        imgSrc: "assets/images/menu_test.jpg",
        shortText: "Simulasi tes sesuai bidang dan kompetensi",
        onTap: _gotoSimulation,
      ),
      _cardMenu(
        title: "CERMAT",
        imgSrc: "assets/images/menu_chart.png",
        shortText: "Kerjakan tes kecermatan secara cepat dan tepat",
        onTap: _gotoStaticSimulation,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.kBgDarkColor,
      body: Column(
        children: [
          Flexible(
            child: Material(
              elevation: 1,
              child: Container(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.fromLTRB(
                    10, MediaQuery.of(context).padding.top + 10, 10, 10),
                width: double.infinity,
                height: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              height: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Image.asset(Constants.companyLogo),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Selamat Datang,\n",
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${_user.fullName}",
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                minFontSize: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: SizedBox(
                                height: 40,
                                child: Container(
                                  width: 140,
                                  child: OutlinedButton(
                                    onPressed: _gotoProfile,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: AutoSizeText(
                                        "PROFIL",
                                        minFontSize: 0,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: SizedBox(
                                height: 40,
                                child: Container(
                                  width: 140,
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red.shade300),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: AutoSizeText(
                                        'KELUAR',
                                        minFontSize: 0,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    onPressed: _gotoLogin,
                                  ),
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
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: 240,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _menuList.length,
                  itemBuilder: (context, index) {
                    return _menuList[index];
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardMenu({
    required String title,
    required String imgSrc,
    void Function()? onTap,
    String? shortText,
  }) {
    return Container(
      width: 380,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AutoSizeText(
                          title,
                          minFontSize: 0,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      shortText != null
                          ? Flexible(
                              child: AutoSizeText(
                                shortText,
                                minFontSize: 0,
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: AppTheme.deactivatedText),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imgSrc),
                      fit: BoxFit.cover,
                    ),
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


// _user.photoUrl != null
// ? Flexible(
//     child: CachedNetworkImage(
//       imageUrl: _user.photoUrl!,
//       imageBuilder: (context,
//               imageProvider) =>
//           Container(
//         width: 40,
//         height: 40,
//         alignment:
//             Alignment.center,
//         decoration:
//             BoxDecoration(
//           shape:
//               BoxShape.circle,
//           image:
//               DecorationImage(
//             image:
//                 imageProvider,
//             fit: BoxFit.fill,
//           ),
//         ),
//       ),
//       placeholder: (context,
//               url) =>
//           CircularProgressIndicator(),
//       errorWidget: (context,
//               url, error) =>
//           Icon(Icons.error),
//     ),
//   )
// : CircleAvatar(
//     backgroundColor:
//         AppTheme.disabled,
//     child: AutoSizeText(
//       _user.fullName
//           .substring(0, 1),
//       minFontSize: 0,
//       style: TextStyle(
//         fontSize: 12,
//         color: AppTheme
//             .deactivatedText,
//       ),
//     ),
//   ),
// Flexible(child: SizedBox(width: 5)),