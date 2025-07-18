import 'dart:developer';
import 'package:elka/model/book_model.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/model/school.dart';
import 'package:elka/model/slider.dart';
import 'package:elka/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:elka/model/model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

abstract class FirebaseCacheManager {
  final Box box = Hive.box('firebase_cache_box');
  static const cacheDurationMs = 1; // ~11.5 days

  Future<T?> _fetchWithCache<T>({
    required String cacheKey,
    required Future<T?> Function() fetchFreshData,
    required T? Function(dynamic) fromCache,
    required Map<dynamic, dynamic> Function(T) toMap,
    required T Function(Map<dynamic, dynamic>) fromJson,
    bool forceRefresh = false,
  }) async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final cacheTimestamp = box.get('${cacheKey}_timestamp', defaultValue: 0);

    if (!forceRefresh &&
        cacheTimestamp != 0 &&
        (currentTime - cacheTimestamp) < cacheDurationMs) {
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        log("Fetching $cacheKey from cache");
        return fromCache(cachedData);
      }
    }

    final freshData = await fetchFreshData();
    if (freshData != null) {
      box.put(cacheKey, toMap(freshData));
      box.put('${cacheKey}_timestamp', currentTime);
    }
    return freshData;
  }

  Future<List<T>> _fetchListWithCache<T>({
    required String cacheKey,
    required Future<List<T>> Function() fetchFreshData,
    required T Function(Map<dynamic, dynamic>) fromJson,
    required Map<dynamic, dynamic> Function(T) toMap,
    bool forceRefresh = false,
  }) async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final cacheTimestamp = box.get('${cacheKey}_timestamp', defaultValue: 0);

    if (!forceRefresh &&
        cacheTimestamp != 0 &&
        (currentTime - cacheTimestamp) < cacheDurationMs) {
      final cachedData = box.get(cacheKey, defaultValue: []);
      log("Fetching $cacheKey from cache");
      return List<T>.from(cachedData.map((e) => fromJson(e)));
    }

    final freshData = await fetchFreshData();
    if (freshData.isNotEmpty) {
      box.put(cacheKey, freshData.map(toMap).toList());
      box.put('${cacheKey}_timestamp', currentTime);
    }
    return freshData;
  }
}

class AuthService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<School?> signInWithGoogle(String path, String code) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) return null;

      final snapshot = await db.child("$path/$code").get();
      return snapshot.exists
          ? await SchoolService().fetchSchool(path, code)
          : null;
    } catch (e) {
      log("Google sign-in error: $e");
      return null;
    }
  }
}

class SchoolService extends FirebaseCacheManager {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<School?> fetchSchool(
    String path,
    String schoolId, {
    bool forceRefresh = false,
  }) {
    return _fetchWithCache<School>(
      cacheKey: schoolId,
      fetchFreshData: () async {
        final snapshot = await db.child('$path/$schoolId').get();
        return snapshot.exists
            ? School.fromJson(snapshot.value as Map<dynamic, dynamic>)
            : null;
      },
      fromCache: (cached) => cached != null ? School.fromJson(cached) : null,
      toMap: (school) => school.toMap(),
      fromJson: School.fromJson,
      forceRefresh: forceRefresh,
    );
  }
}

class UserService extends FirebaseCacheManager {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<UserData?> fetchUser(String userId, {bool forceRefresh = false}) {
    return _fetchWithCache<UserData>(
      cacheKey: userId,
      fetchFreshData: () async {
        final snapshot = await db.child('users/$userId').get();
        return snapshot.exists
            ? UserData.fromJson(snapshot.value as Map<dynamic, dynamic>)
            : null;
      },
      fromCache: (cached) => cached != null ? UserData.fromJson(cached) : null,
      toMap: (user) => user.toMap(),
      fromJson: UserData.fromJson,
      forceRefresh: forceRefresh,
    );
  }

  Future<UserData?> setUser(UserData user, String userId) async {
    try {
      await db.child('users/$userId').set(user.toMap());
      box.put(userId, user.toMap());
      box.put('${userId}_timestamp', DateTime.now().millisecondsSinceEpoch);
      return user;
    } catch (e) {
      log('Error saving user: $e');
      return null;
    }
  }
}

class ContentService extends FirebaseCacheManager {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<List<EmodulModel>> fetchAllEmodulsByKelas(
    String kelasId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<EmodulModel>(
      cacheKey: 'emoduls_$kelasId',
      fetchFreshData: () async {
        final snapshot =
            await db
                .child('emoduls')
                .orderByChild('kelasId')
                .equalTo(kelasId)
                .get();

        return snapshot.exists
            ? snapshot.children
                .map(
                  (e) => EmodulModel.fromJson(
                    e.key!,
                    e.value as Map<dynamic, dynamic>,
                  ),
                )
                .toList()
            : [];
      },
      fromJson: (json) => EmodulModel.fromJson(json['id'], json['data']),
      toMap: (emodul) => {'id': emodul.id, 'data': emodul.toMap()},
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Subject>> getSubjectsByKelasId(
    String kelasId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<Subject>(
      cacheKey: 'subjects_$kelasId',
      fetchFreshData: () async {
        final kelasSnap = await db.child('kelas/$kelasId').get();
        if (!kelasSnap.exists ||
            (kelasSnap.value as Map<dynamic, dynamic>)['subjects'] == null)
          return [];

        final subjectRefs =
            (kelasSnap.value as Map<dynamic, dynamic>)['subjects'].keys
                .cast<String>();
        final subjectsSnap = await db.child('subjects').get();

        return subjectsSnap.exists
            ? subjectsSnap.children
                .where((e) => subjectRefs.contains(e.key))
                .map((e) => Subject.fromSnapshot(e.key!, e.value as Map))
                .toList()
            : [];
      },
      fromJson: (json) => Subject.fromSnapshot(json['id'], json['data']),
      toMap: (subject) => {'id': subject.id, 'data': subject.toMap()},
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Subab>> getSubabsByBab(
    String babId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<Subab>(
      cacheKey: '${babId}_subabs',
      fetchFreshData: () async {
        final snapshot =
            await db
                .child('subabs')
                .orderByChild('bab_id')
                .equalTo(babId)
                .get();
        return snapshot.children
            .map((e) => Subab.fromSnapshot(e.key!, e.value as Map))
            .toList();
      },
      fromJson: (json) => Subab.fromSnapshot(json['id'], json['data']),
      toMap: (subab) => {'id': subab.id, 'data': subab.toMap()},
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Bab>> getBabsByKelasAndSubject(
    String kelasId,
    String mapelId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<Bab>(
      cacheKey: '${kelasId}_${mapelId}_babs',
      fetchFreshData: () async {
        final snapshot =
            await db
                .child('babs')
                .orderByChild('kelasSubjectId')
                .equalTo('${kelasId}_$mapelId')
                .get();
        return snapshot.children
            .map((e) => Bab.fromSnapshot(e.key!, e.value as Map, []))
            .toList();
      },
      fromJson: (json) => Bab.fromSnapshot(json['id'], json['data'], []),
      toMap: (bab) => {'id': bab.id, 'data': bab.toMap()},
      forceRefresh: forceRefresh,
    );
  }
}

class BookService extends FirebaseCacheManager {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<List<Book>> fetchBooks(
    String selectedKelasId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<Book>(
      cacheKey: 'books_$selectedKelasId',
      fetchFreshData: () async {
        final snapshot =
            await db
                .child('books')
                .orderByChild('kelas')
                .equalTo(selectedKelasId)
                .get();
        return snapshot.children
            .map((e) => Book.fromSnapshot(e.value as Map, isUniversal: false))
            .toList();
      },
      fromJson: (json) => Book.fromSnapshot(json, isUniversal: false),
      toMap: (book) => book.toMap(),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Book>> fetchBooksUniversal({bool forceRefresh = false}) {
    return _fetchListWithCache<Book>(
      cacheKey: 'books_universal',
      fetchFreshData: () async {
        final snapshot = await db.child('books_universal').get();
        return snapshot.children
            .map((e) => Book.fromSnapshot(e.value as Map, isUniversal: true))
            .toList();
      },
      fromJson: (json) => Book.fromSnapshot(json, isUniversal: true),
      toMap: (book) => book.toMap(),
      forceRefresh: forceRefresh,
    );
  }
}

class SliderService extends FirebaseCacheManager {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<List<SliderItem>> getSlidersByKabupatenId(
    String kabupatenId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<SliderItem>(
      cacheKey: '${kabupatenId}_sliders',
      fetchFreshData: () async {
        final snapshot = await db.child('sliders/${kabupatenId.trim()}').get();
        return snapshot.children
            .map((e) => SliderItem.fromJson(e.value as Map))
            .toList();
      },
      fromJson: (json) => SliderItem.fromJson(json),
      toMap: (slider) => slider.toMap(),
      forceRefresh: forceRefresh,
    );
  }
}
