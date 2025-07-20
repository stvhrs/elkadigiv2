import 'dart:developer';
import 'package:elka/model/bank_soal.dart';
import 'package:elka/model/book_model.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/model/material.dart';
import 'package:elka/model/school.dart';
import 'package:elka/model/slider.dart';
import 'package:elka/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:elka/model/model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // clientId:
  //     "969146186573-tnsolf28l4ls3o62o8mi1uuto45u7im0.apps.googleusercontent.com",

  // scopes: ['email', 'profile'], // Remove 'openid' if not needed
);
final FirebaseAuth _auth = FirebaseAuth.instance;

class FirebaseService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  final Box box = Hive.box('firebase_cache_box');
  static const cacheDurationMs =
      1 * 24 * 60 * 60 * 1000; // 4 days in milliseconds
  final DatabaseReference _materiRef = FirebaseDatabase.instance.ref('materi');

  // Mengambil data materi dari Firebase
  Future<List<Map<dynamic, dynamic>>> fetchCourseData(
    String npsn,
    String kelasId,

    String subjectId,
  ) async {
    Map<dynamic, dynamic> convertToMapStringDynamic(
      Map<Object?, Object?> originalMap,
    ) {
      return originalMap.map((key, value) {
        final stringKey = key.toString();
        dynamic convertedValue = value;
        if (value is Map<Object?, Object?>) {
          convertedValue = convertToMapStringDynamic(value);
        } else if (value is List) {
          convertedValue =
              value.map((item) {
                if (item is Map<Object?, Object?>) {
                  return convertToMapStringDynamic(item);
                }
                return item;
              }).toList();
        }
        return MapEntry(stringKey, convertedValue);
      });
    }

    try {
      final nspnKelasMapelId = npsn + "_" + kelasId + "_" + subjectId;
      log(nspnKelasMapelId);

      final response =
          await FirebaseDatabase.instance
              .ref("materi/$npsn")
              .orderByChild("nspnKelasMapelId")
              .equalTo(nspnKelasMapelId)
              .get();
      log(response.value.toString());
      if (response.value != null) {
        final data = response.children;
        List<Map<dynamic, dynamic>> rawStreams =
            data.map((e) {
              (e.value as Map<dynamic, dynamic>)["id"] = e.key;
              return convertToMapStringDynamic(
                e.value as Map<Object?, Object?>,
              );
            }).toList();
        return rawStreams;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> saveMaterial(MaterialCourse material) async {
    try {
      // Update existing
      await _materiRef.child('${material.nspn}').update({
        material.id!: material.toMap(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete materi
  Future<void> deleteMaterial(String npsn, String key) async {
    try {
      await _materiRef.child('$npsn/$key').remove();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BankSoal>> fetchTrout({
    required String jenjang,
    bool forceRefresh = false,
  }) async {
    return await _fetchListWithCache<BankSoal>(
      cacheKey: 'tryout_$jenjang',
      fetchFreshData: () => _fetchFromFirebasetryout(jenjang),
      fromJson: BankSoal.fromMap,
      toMap: (item) => item.toMap(),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<BankSoal>> _fetchFromFirebasetryout(String jenjang) async {
    try {
      final snapshot =
          await FirebaseDatabase.instance.ref('tryout/$jenjang').get();

      if (snapshot.exists) {
        List<BankSoal> list = [];
        for (var element in snapshot.children) {
          (element.value as Map<dynamic, dynamic>)["id"] = element.key;

          list.add(BankSoal.fromMap(element.value as Map<dynamic, dynamic>));
        }
        return list;
      }
      return [];
    } catch (e) {
      log('Error fetching bank soal from Firebase: $e');
      rethrow;
    }
  }

  Future<List<BankSoal>> fetchBankSoal({
    required String kelasSubjectId,
    bool forceRefresh = false,
  }) async {
    return await _fetchListWithCache<BankSoal>(
      cacheKey: 'bank_soal_$kelasSubjectId',
      fetchFreshData: () => _fetchFromFirebase(kelasSubjectId),
      fromJson: BankSoal.fromMap,
      toMap: (item) => item.toMap(),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<BankSoal>> _fetchFromFirebase(String kelasSubjectId) async {
    try {
      final snapshot =
          await FirebaseDatabase.instance
              .ref('bank_soal/$kelasSubjectId')
              .get();

      if (snapshot.exists) {
        List<BankSoal> list = [];
        for (var element in snapshot.children) {
          (element.value as Map<dynamic, dynamic>)["id"] = element.key;

          list.add(BankSoal.fromMap(element.value as Map<dynamic, dynamic>));
        }
        return list;
      }
      return [];
    } catch (e) {
      log('Error fetching bank soal from Firebase: $e');
      rethrow;
    }
  }
Future<List<BankSoalpdf>> fetchBankSoalPdf({
    required String kelasSubjectId,
    bool forceRefresh = false,
  }) async {
    return await _fetchListWithCache<BankSoalpdf>(
      cacheKey: 'bank_soal_pdf_$kelasSubjectId',
      fetchFreshData: () => _fetchFromFirebase2(kelasSubjectId),
      fromJson: BankSoalpdf.fromMap,
      toMap: (item) => item.toMap(),
      forceRefresh: forceRefresh,
    );
  }

  // Direct Firebase fetch
  Future<List<BankSoalpdf>> _fetchFromFirebase2(String kelasSubjectId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('bank_soal_pdf')
          .orderByChild('kelasSubjectId')
          .equalTo(kelasSubjectId)
          .get();

      if (snapshot.exists) {
        List<BankSoalpdf> list = [];
        for (var element in snapshot.children) {
          final data = element.value as Map<dynamic, dynamic>;
          data['id'] = element.key; // Add the Firebase key as id
          list.add(BankSoalpdf.fromMap(data));
        }
        return list;
      }
      return [];
    } catch (e) {
      log('Error fetching bank soal pdf from Firebase: $e');
      rethrow;
    }
  }
  Future<T?> _fetchWithCache<T>({
    required String cacheKey,
    required Future<T?> Function() fetchFreshData,

    required T? Function(dynamic) fromCache,
    required Map<dynamic, dynamic> Function(T) toMap,
    required T Function(Map<dynamic, dynamic>) fromJson,
    bool forceRefresh = false,
  }) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final cacheTimestamp = box.get('${cacheKey}_timestamp', defaultValue: 0);

      if (!forceRefresh &&
          cacheTimestamp != 0 &&
          (currentTime - cacheTimestamp) < cacheDurationMs) {
        final cachedData = box.get(cacheKey);
        if (cachedData != null) {
          log("Fetching $cacheKey from cache");
          final result = fromCache(cachedData);
          log(
            "[CACHE HIT] Successfully fetched $cacheKey from cache: ${result.toString()}",
          );
          return result;
        }
      }

      log("Fetching fresh data for $cacheKey");
      final freshData = await fetchFreshData();
      if (freshData != null) {
        box.put(cacheKey, toMap(freshData));
        box.put('${cacheKey}_timestamp', currentTime);
        log(
          "[FRESH DATA] Successfully fetched $cacheKey: ${freshData.toString()}",
        );
      } else {
        log("[FRESH DATA] No data found for $cacheKey");
      }
      return freshData;
    } catch (e) {
      log("Error fetching $cacheKey: $e");
      rethrow;
    }
  }

  // Generic list fetcher
  Future<List<T>> _fetchListWithCache<T>({
    required String cacheKey,
    required Future<List<T>> Function() fetchFreshData,
    required T Function(Map<dynamic, dynamic>) fromJson,
    required Map<dynamic, dynamic> Function(T) toMap,
    bool forceRefresh = false,
  }) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final cacheTimestamp = box.get('${cacheKey}_timestamp', defaultValue: 0);

      if (!forceRefresh &&
          cacheTimestamp != 0 &&
          (currentTime - cacheTimestamp) < cacheDurationMs) {
        final cachedData = box.get(cacheKey, defaultValue: []);
        log("Fetching $cacheKey from cache");
        final result = List<T>.from(cachedData.map((e) => fromJson(e)));
        log(
          "[CACHE HIT] Successfully fetched $cacheKey from cache. Item count: ${result.length}",
        );
        return result;
      }

      log("Fetching fresh list data for $cacheKey");
      final freshData = await fetchFreshData();
      if (freshData.isNotEmpty) {
        box.put(cacheKey, freshData.map(toMap).toList());
        box.put('${cacheKey}_timestamp', currentTime);
        log(
          "[FRESH DATA] Successfully fetched $cacheKey. Item count: ${freshData.length}",
        );
      } else {
        log("[FRESH DATA] No data found for $cacheKey");
      }
      return freshData;
    } catch (e) {
      log("Error fetching list $cacheKey: $e");
      rethrow;
    }
  }

  Future<List<MaterialCourse>> fetchAllMaterialCoursesByKelas(
    String kelasId,
    String mapelId,
    String npsn, {

    bool forceRefresh = false,
  }) async {
    final snapshot =
        await FirebaseDatabase.instance
            .ref('materi/$npsn')
            .orderByChild('nspnKelasMapelId')
            .equalTo("${npsn}_${kelasId}_${mapelId}")
            .get();

    if (snapshot.exists) {
      final materialCourses =
          snapshot.children.map((e) {
            final data = Map<dynamic, dynamic>.from(
              e.value as Map<dynamic, dynamic>,
            );
            data["id"] = e.key;
            log("KEY");
            log(data["id"]);
            return MaterialCourse.fromMap(data);
          }).toList();

      log(
        "[MATERIALCourse] Successfully fetched ${materialCourses.length} materialCourses for kelas: $kelasId",
      );
      return materialCourses;
    }
    log("[MATERIALCourse] No materialCourses found for kelas: $kelasId");
    return [];
  }

  Future<String> pushMaterialCourse({required MaterialCourse material}) async {
    try {
      // Create a reference to the materi/$npsn path
      final materialsRef = FirebaseDatabase.instance.ref(
        'materi/${material.nspn}',
      );

      // Generate a new push ID
      // Anda bisa menghasilkan ID baru di sini jika diperlukan, misalnya dengan push()
      final newPushId = materialsRef.push().key;

      // Prepare the data with composite ID
      final materialData = {
        ...material
            .toMap(), // Pastikan toMap() menghasilkan Map<String, Object>
        'nspnKelasMapelId': '${material.nspnKelasMapelId}',
        'createdAt': ServerValue.timestamp,
      };

      // Push the data to Firebase
      await materialsRef.child(newPushId!).set(materialData);
      log('[MATERIAL] Successfully added new material: ${material.title}');
      return newPushId;
    } catch (e) {
      log('[MATERIAL] Error adding material: $e');
      throw Exception('Failed to add material: $e');
    }
  }

  // School operations
  Future<School?> fetchSchool(String path, String schoolId) {
    return _fetchWithCache<School>(
      cacheKey: schoolId,
      fetchFreshData: () async {
        final snapshot = await db.child('$path/$schoolId').get();
        if (snapshot.exists) {
          (snapshot.value as Map<dynamic, dynamic>)["id"] = snapshot.key;

          final school = School.fromJson(
            snapshot.value as Map<dynamic, dynamic>,
          );
          log("[SCHOOL] Successfully fetched school: ${school.toString()}");
          return school;
        }
        log("[SCHOOL] School not found for ID: $schoolId");
        return null;
      },
      fromCache: (cached) => cached != null ? School.fromJson(cached) : null,
      toMap: (school) => school.toMap(),
      fromJson: School.fromJson,
      forceRefresh: false,
    );
  }

  // User operations
  Future<UserData?> fetchUser(String userId) {
    return _fetchWithCache<UserData>(
      cacheKey: userId,
      fetchFreshData: () async {
        final snapshot = await db.child('users/$userId').get();
        if (snapshot.exists) {
          final user = UserData.fromJson(
            snapshot.value as Map<dynamic, dynamic>,
          );
          log("[USER] Successfully fetched user: ${user.toString()}");
          return user;
        }
        log("[USER] User not found for ID: $userId");
        return null;
      },
      fromCache: (cached) => cached != null ? UserData.fromJson(cached) : null,
      toMap: (user) => user.toMap(),
      fromJson: UserData.fromJson,
      forceRefresh: false,
    );
  }

  Future<UserData?> setUser(UserData user, String userId) async {
    try {
      log("[USER] Attempting to save user: ${user.toString()}");
      await db.child('users/$userId').set(user.toMap());
      box.put(userId, user.toMap());
      box.put('${userId}_timestamp', DateTime.now().millisecondsSinceEpoch);
      log("[USER] Successfully saved user: ${user.toString()}");
      return user;
    } catch (e) {
      log('[USER] Error saving user: $e');
      return null;
    }
  }

  // Authentication
  Future<School?> signInWithGoogle(String path, String code) async {
    try {
      log("[AUTH] Starting Google Sign-In process");
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log("[AUTH] Google Sign-In cancelled by user");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      log("[AUTH] Authenticating with Firebase");
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        log("[AUTH] Firebase authentication failed");
        return null;
      }

      log("[AUTH] Fetching school data for code: $code");
      final snapshot = await db.child("$path/$code").get();
      if (snapshot.exists) {
        final school = await fetchSchool(path, code);
        log(
          "[AUTH] Successfully authenticated and fetched school: ${school?.toString()}",
        );
        return school;
      }
      log("[AUTH] School not found for code: $code");
      return null;
    } catch (e) {
      log("[AUTH] Google sign-in error: $e");
      return null;
    }
  }

  // Content fetching methods
  Future<List<EmodulModel>> fetchAllEmodulsByKelas(
    String kelasId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<EmodulModel>(
      cacheKey: 'emoduls_$kelasId',
      fetchFreshData: () async {
        log("[EMODUL] Fetching emoduls for kelas: $kelasId");
        final snapshot =
            await db
                .child('emoduls')
                .orderByChild('kelasId')
                .equalTo(kelasId)
                .get();

        if (snapshot.exists) {
          final emoduls =
              snapshot.children
                  .map(
                    (e) => EmodulModel.fromJson(
                      e.key!,
                      e.value as Map<dynamic, dynamic>,
                    ),
                  )
                  .toList();
          log(
            "[EMODUL] Successfully fetched ${emoduls.length} emoduls for kelas: $kelasId",
          );
          return emoduls;
        }
        log("[EMODUL] No emoduls found for kelas: $kelasId");
        return [];
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
        log("[SUBJECT] Fetching subjects for kelas: $kelasId");
        final kelasSnap = await db.child('kelas/$kelasId').get();
        if (!kelasSnap.exists ||
            (kelasSnap.value as Map<dynamic, dynamic>)['subjects'] == null) {
          log("[SUBJECT] No subjects found for kelas: $kelasId");
          return [];
        }

        final subjectRefs =
            (kelasSnap.value as Map<dynamic, dynamic>)['subjects'].keys
                .cast<String>();
        final subjectsSnap = await db.child('subjects').get();

        if (subjectsSnap.exists) {
          final subjects =
              subjectsSnap.children
                  .where((e) => subjectRefs.contains(e.key))
                  .map((e) => Subject.fromSnapshot(e.key!, e.value as Map))
                  .toList();
          log(
            "[SUBJECT] Successfully fetched ${subjects.length} subjects for kelas: $kelasId",
          );
          return subjects;
        }
        log("[SUBJECT] No subjects found in database");
        return [];
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
    log(babId);
    return _fetchListWithCache<Subab>(
      cacheKey: '${babId}_subabs',
      fetchFreshData: () async {
        log("[SUBAB] Fetching subabs for bab: $babId");
        final snapshot =
            await db
                .child('subabs')
                .orderByChild('bab_id')
                .equalTo(babId)
                .get();

        // Convert snapshot to list of Subab objects
        List<Subab> subabs =
            snapshot.children
                .map((e) => Subab.fromSnapshot(e.key!, e.value as Map))
                .toList();

        // Sort by order_index (ascending)
        subabs.sort((a, b) {
          final orderA =
              a.orderIndex ?? 0; // Handle null dengan default value 0
          final orderB = b.orderIndex ?? 0;
          return orderA.compareTo(orderB);
        });

        log(
          "[SUBAB] Successfully fetched and sorted ${subabs.length} subabs for bab: $babId",
        );
        return subabs;
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
      cacheKey: '${kelasId}_${mapelId}',
      fetchFreshData: () async {
        log("[BAB] Fetching babs for kelas: $kelasId and subject: $mapelId");
        final snapshot =
            await db
                .child('babs')
                .orderByChild('kelasSubjectId')
                .equalTo('${kelasId}_$mapelId')
                .get();

        // Convert to Bab objects
        List<Bab> babs =
            snapshot.children
                .map((e) => Bab.fromSnapshot(e.key!, e.value as Map, []))
                .toList();

        // Sort by order_index (ascending)
        babs.sort((a, b) {
          final orderA =
              a.order_index ?? 0; // Handle null dengan default value 0
          final orderB = b.order_index ?? 0;
          return orderA.compareTo(orderB);
        });

        log(
          "[BAB] Successfully fetched and sorted ${babs.length} babs for kelas: $kelasId and subject: $mapelId",
        );
        return babs;
      },
      fromJson: (json) => Bab.fromSnapshot(json['id'], json['data'], []),
      toMap: (bab) => {'id': bab.id, 'data': bab.toMap()},
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Book>> fetchBooks(
    String selectedKelasId, {
    bool forceRefresh = false,
  }) {
    return _fetchListWithCache<Book>(
      cacheKey: 'books_$selectedKelasId',
      fetchFreshData: () async {
        log("[BOOK] Fetching books for kelas: $selectedKelasId");
        final snapshot =
            await db
                .child('books')
                .orderByChild('kelas')
                .equalTo(selectedKelasId)
                .get();
        final books =
            snapshot.children
                .map(
                  (e) => Book.fromSnapshot(e.value as Map, isUniversal: false),
                )
                .toList();
        log(
          "[BOOK] Successfully fetched ${books.length} books for kelas: $selectedKelasId",
        );
        return books;
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
        log("[BOOK] Fetching universal books");
        final snapshot = await db.child('books_universal').get();
        final books =
            snapshot.children
                .map(
                  (e) => Book.fromSnapshot(e.value as Map, isUniversal: true),
                )
                .toList();
        log("[BOOK] Successfully fetched ${books.length} universal books");
        return books;
      },
      fromJson: (json) => Book.fromSnapshot(json, isUniversal: true),
      toMap: (book) => book.toMap(),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SliderItem>> getSlidersByKabupatenId(
    String kabupatenId, {
    bool forceRefresh = false,
  }) {
    log(kabupatenId + "kodeeeeee");
    return _fetchListWithCache<SliderItem>(
      cacheKey: '${kabupatenId + "SD"}_sliders',
      fetchFreshData: () async {
        log("[SLIDER] Fetching sliders for kabupaten: $kabupatenId");
        final snapshot = await db.child('sliders/${kabupatenId.trim()}').get();
        final sliders =
            snapshot.children
                .map(
                  (e) => SliderItem.fromJson(e.value as Map<dynamic, dynamic>),
                )
                .toList();
        log(
          "[SLIDER] Successfully fetched ${sliders.length} sliders for kabupaten: $kabupatenId",
        );
        return sliders;
      },
      fromJson: (json) => SliderItem.fromJson(json),
      toMap: (slider) => slider.toMap(),
      forceRefresh: forceRefresh,
    );
  }
}
