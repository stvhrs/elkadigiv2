import 'dart:developer';
import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/model/bank_soal.dart';
import 'package:elka/model/book_model.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/model/material.dart';
import 'package:elka/model/model.dart';
import 'package:elka/model/school.dart' show School;
import 'package:elka/model/slider.dart';
import 'package:elka/model/user.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<dynamic, dynamic>> _courses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<Map<dynamic, dynamic>> get courses => _courses;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<BankSoal> _bankSoal = [];
  List<BankSoal> get bankSoal => _bankSoal;

  Future<void> loadBankSoal({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = '';
    // notifyListeners();

    try {
      final prov = currentUser;
      if (prov == null) {
        throw Exception('User data not available');
      }

      final data = await _firebaseService.fetchTrout(
        jenjang: prov.jenjang.name,
        forceRefresh: forceRefresh,
      );

      _bankSoal = data;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      // _isLoading = false;
      // notifyListeners();
    }
  }

  // Method untuk mengambil data materi
  Future<void> fetchCourses(
    String npsn,
    String kelasId,
    String subjectId,
  ) async {
    _isLoading = true;

    try {
      _courses = await _firebaseService.fetchCourseData(
        npsn,
        kelasId,
        subjectId,
      );
      _courses = _courses.reversed.toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Map<dynamic, dynamic> newCourse) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assume FirebaseService has an `addCourse` method
      var courseId = await _firebaseService.pushMaterialCourse(
        material: MaterialCourse.fromMap(newCourse),
      );
      newCourse['id'] = courseId; // Add the generated ID to the course
      _courses.add(newCourse);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to add course: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a course by ID
  Future<void> deleteCourse(String courseId, String npsn) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteMaterial(
        npsn,
        courseId,
      ); // Assume this exists
      _courses.removeWhere((course) => course['id'] == courseId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to delete course: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit a course by ID
  Future<void> editCourse(MaterialCourse material) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.saveMaterial(material); // Assume this exists
      final index = _courses.indexWhere(
        (course) => course['id'] == material.id,
      );
      if (index != -1) {
        _courses[index] = {..._courses[index], ...material.toMap()};
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update course: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _locked = false;
  Color _color = const Color.fromARGB(255, 75, 167, 123);
  Color _colorLight = const Color.fromARGB(255, 75, 167, 123);

  double scoreDiagnostic = 0;

  // Navigation state
  Subject? _selectedSubject;
  Bab? _selectedBab;
  Subab? _selectedSubab;

  // Data collections
  List<Bab> _babs = [];
  List<Subab> _subabs = [];
  List<EmodulModel> _emoduls = [];
  List<Subject> _subjects = [];
  List<SliderItem> _sliderItems = [];

  // User and school context
  late School _selectedSchool;
  late UserData _currentUser;

  // Getters
  bool get locked => _locked;
  Color get color => _color;
  Color get colorLight => _colorLight;
  Subject? get selectedSubject => _selectedSubject;
  List<Bab> get babs => _babs;
  List<Subab> get subabs => _subabs;
  Bab? get selectedBab => _selectedBab;
  Subab? get selectedSubab => _selectedSubab;
  List<EmodulModel> get emoduls => _emoduls;
  List<Subject> get subjects => _subjects;
  List<SliderItem> get sliderItems => _sliderItems;
  School get selectedSchool => _selectedSchool;
  UserData get currentUser => _currentUser;
  List<Book> _books = [];
  List<Book> _booksUniversal = [];

  // New setters for books
  void setBooks(List<Book> books) {
    _books = List.from(books);
    notifyListeners();
  }

  void setBooksUniversal(List<Book> booksUniversal) {
    _booksUniversal = List.from(booksUniversal);
    notifyListeners();
  }

  // Existing getters

  // New getters for books
  List<Book> get books => _books;
  List<Book> get booksUniversal => _booksUniversal;

  // Setters
  void setLocked(bool locked) {
    _locked = locked;
    notifyListeners();
  }

  void setColor(Color color, [bool listen = true]) {
    _color = color;
    _colorLight = Helper.lightenColor(color);
    if (listen) notifyListeners();
  }

  void setSliderItems(List<SliderItem> sliderItems) {
    _sliderItems = List.from(sliderItems);
    notifyListeners();
  }

  void setSubabs(List<Subab> subabs) {
    _subabs = List.from(subabs);
    notifyListeners();
  }

  void setBabs(List<Bab> babs) {
    _babs = babs;
    notifyListeners();
  }

  void setEmoduls(List<EmodulModel> emoduls) {
    _emoduls = List.from(emoduls);
    notifyListeners();
  }

  void setSubjects(List<Subject> subjects) {
    _subjects = List.from(subjects);
    notifyListeners();
  }

  void setSelectedSchool(School? school) {
    _selectedSchool = school!;
    notifyListeners();
  }

  void setCurrentUser(UserData user) {
    _currentUser = user;
    notifyListeners();
  }

  void setScoreDiagnostic(double val, [bool listen = true]) {
    log("score diagnostic $val");
    scoreDiagnostic = val;
    if (listen) notifyListeners();
  }

  bool _isLoadingAny = false;

  bool get isLoadingAny => _isLoadingAny;

  // Setters for loading states
  void _setloading(bool loading, [bool listen = false]) {
    _isLoadingAny = loading;
    if (listen) notifyListeners();
  }

  // Navigation state management
  Future<void> setSelectedKelas(String kelasId) async {
    if (_currentUser == null || _currentUser!.kelasId.isEmpty) return;
    // _setloading(false);
    // notifyListeners();
    _currentUser =
        (await FirebaseService().setUser(
          currentUser.copyWith(kelasId: kelasId),
          FirebaseAuth.instance.currentUser!.uid,
        ))!;

    _subjects = await FirebaseService().getSubjectsByKelasId(kelasId);

    _books = await FirebaseService().fetchBooks(kelasId);
    _bankSoal=await FirebaseService().fetchTrout(jenjang: currentUser.jenjang.name);
    // _emoduls = await FirebaseService().fetchAllEmodulsByKelas(kelasId);
    log(kelasId);
    // loadBankSoal();

    // _setloading(false);

    notifyListeners();
  }

  void setSelectedSubject(Subject subject) {
    _selectedSubject = subject;
    _selectedBab = null;
    _selectedSubab = null;
    _babs.clear();
    _subabs.clear();
    notifyListeners();
  }

  void setSelectedBab(Bab bab) {
    _selectedBab = bab;
    _selectedSubab = null;
    scoreDiagnostic = 0;
    notifyListeners();
  }

  void setSelectedSubab(Subab subab) {
    _selectedSubab = subab;
    notifyListeners();
  }

  void clearSelections() {
    _selectedSubject = null;
    _selectedBab = null;
    _selectedSubab = null;
    notifyListeners();
  }
}
