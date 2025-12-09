import 'package:bamtol_market_app/firebase_options.dart';
import 'package:bamtol_market_app/src/app.dart';
import 'package:bamtol_market_app/src/common/controller/authentication_controller.dart';
import 'package:bamtol_market_app/src/common/controller/bottom_nav_controller.dart';
import 'package:bamtol_market_app/src/common/controller/common_layout_controller.dart';
import 'package:bamtol_market_app/src/common/controller/data_load_controller.dart';
import 'package:bamtol_market_app/src/common/repository/cloud_firebase_storage_repository.dart';
import 'package:bamtol_market_app/src/home/controller/home_controller.dart';
import 'package:bamtol_market_app/src/product/repository/product_repository.dart';
import 'package:bamtol_market_app/src/product/write/controller/product_write_controller.dart';
import 'package:bamtol_market_app/src/product/write/page/product_write_page.dart';
import 'package:bamtol_market_app/src/root.dart';
import 'package:bamtol_market_app/src/splash/controller/splash_controller.dart';
import 'package:bamtol_market_app/src/user/login/controller/login_controller.dart';
import 'package:bamtol_market_app/src/user/login/page/login_page.dart';
import 'package:bamtol_market_app/src/user/repository/authentication_repository.dart';
import 'package:bamtol_market_app/src/user/repository/user_repository.dart';
import 'package:bamtol_market_app/src/user/signup/controller/signup_controller.dart';
import 'package:bamtol_market_app/src/user/signup/page/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;
    return GetMaterialApp(
      title: '당근마켓 클론 코딩',
      initialRoute: '/',
      // 초기 페이지 설정
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xff212123),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xff212123),
      ),
      initialBinding: BindingsBuilder(() {
        var authenticationRepository = AuthenticationRepository(
          FirebaseAuth.instance,
        );
        var userRepository = UserRepository(db);
        Get.put(authenticationRepository);
        Get.put(userRepository);
        Get.put(CommonLayoutController());
        Get.put(ProductRepository(db));
        Get.put(BottomNavController());
        Get.put(SplashController());
        Get.put(DataLoadController());
        Get.put(
          AuthenticationController(authenticationRepository, userRepository),
        );
        Get.put(CloudFirebaseRepository(FirebaseStorage.instance));
      }),
      getPages: [
        /*
        name : 라우트 경로 정의
        page : 정의한 라우트 경로(URL)로 접근했을 때 화면에 보여줄 위젯 페이지 정의
         */
        GetPage(name: '/', page: () => const App()),
        GetPage(name: '/home', page: () => const Root(),
        binding: BindingsBuilder(() {
          Get.put(HomeController(Get.find<ProductRepository>()));
        })),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<LoginController>(
              () => LoginController(Get.find<AuthenticationRepository>()),
            );
          }),
        ),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(
          name: '/signup/:uid',
          page: () => const SignupPage(),
          binding: BindingsBuilder(() {
            Get.create<SignupController>(
              () => SignupController(
                Get.find<UserRepository>(),
                Get.parameters['uid'] as String,
              ),
            );
          }),
        ),
        GetPage(
          name: '/product/write',
          page: () => ProductWritePage(),
          binding: BindingsBuilder(() {
            Get.put(
              ProductWriteController(
                Get.find<AuthenticationController>().userModel.value,
                Get.find<ProductRepository>(),
                Get.find<CloudFirebaseRepository>(),
              ),
            );
          }),
        ),
      ],
    );
  }
}
