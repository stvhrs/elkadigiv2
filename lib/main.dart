import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:elka/firebase_options.dart';
import 'package:elka/login_google.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box<dynamic> box;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : null,
  );

  await Hive.initFlutter(); // Initialize Hive
  box = await Hive.openBox("firebase_cache_box");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

late BuildContext ctxt;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 
  @override
  void initState() {
    if (!kIsWeb) {
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctxt = context;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          fontFamily: "Futura",
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: SlideTransitionBuilder(),
              TargetPlatform.iOS: SlideTransitionBuilder(),
            },
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Color.fromARGB(255, 53, 141, 99),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white, // Set the text color to white
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            errorStyle: TextStyle(fontSize: 10),
            isDense: true,
            hintStyle: TextStyle(
              color: Colors.grey,
            ), // Optional: Change hint color
            filled: true,
            fillColor:
                Colors.white, // Optional: Background color of the text field
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Adjust the roundness
              borderSide: BorderSide(
                color: Color.fromARGB(255, 75, 167, 123),
                width: 1.5,
              ), // Foc
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.red, width: 1.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Color.fromRGBO(215, 215, 215, 1),
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Color.fromRGBO(215, 215, 215, 1),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Color.fromARGB(255, 75, 167, 123),
                width: 1.5,
              ), // Focused border color
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.shade900,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
            surfaceTintColor: Color.fromARGB(255, 249, 249, 249),
            actionsIconTheme: IconThemeData(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
          ),

          textTheme: TextTheme(
            titleMedium: TextStyle(color: Colors.grey.shade700),
          ),
          scaffoldBackgroundColor:
              Colors.white, // const Color.fromARGB(255, 249, 249, 249),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color.fromARGB(255, 197, 226, 179),
            primary: Color.fromARGB(255, 75, 167, 123),
          ),
        ),
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child:
              FirebaseAuth.instance.currentUser == null && box.isEmpty
                  ? SignInPage()
                  : Navigation(),
        ),
      ),
    );
  }
}

const List<String> list = <String>[
  'SD Kelas 1',
  'SD Kelas 2',
  'SD Kelas 3',
  'SD Kelas 4',
  'SD Kelas 5',
  'SD Kelas 6',
  'SMP Kelas 7',
  "SMP Kelas 8",
  "SMP Kelas 9",
  "SMA Kelas 10",
  "SMA Kelas 11",
  "SMA Kelas 12",
];

const List<String> listid = <String>[
  'kelas_1',
  'kelas_2',
  'kelas_3',
  'kelas_4',
  'kelas_5',
  'kelas_6',
  'kelas_7',
  "kelas_8",
  "kelas_9",
  "kelas_10",
  "kelas_11",
  "kelas_12",
];

class SlideTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastLinearToSlowEaseIn,
        ),
      ),
      child: child,
    );
  }
}
