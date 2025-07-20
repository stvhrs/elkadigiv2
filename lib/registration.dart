import 'dart:developer';

import 'package:elka/main.dart';
import 'package:elka/model/user.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/navigation.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_touch_ripple/widgets/touch_ripple.dart';

// Validation function (case-insensitive)
String? validateEducationLevel(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kosong';
  }
  if (value.length < 6) {
    return 'Minimal 6 karakter';
  }

  // List of valid keywords
  final keywords = ['SMA', 'SMP', 'SD', 'MI', 'SMK', 'MTS', 'MA'];

  // Convert input to lowercase for case-insensitive comparison
  final lowerCaseValue = value.toLowerCase();

  // Check if any keyword (in lowercase) is present in the input
  final containsKeyword = keywords.any(
    (keyword) => lowerCaseValue.contains(keyword.toLowerCase()),
  );

  if (!containsKeyword) {
    return 'Mohon sertakan jenjang : SMA, SMP, SD, MI, SMK, MTS, MA';
  }

  return null; // Input is valid
}

class Registration extends StatefulWidget {
  final String userType;
  final String code;
  final bool isEditMode;
  final UserData? existingUser;

  const Registration(
    this.userType,
    this.code, {
    this.isEditMode = false,
    this.existingUser,
  });

  @override
  State<Registration> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Registration> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
   String? educationLevel;
  String? grade;
  bool _validateEducationFields() {
    if (!widget.isEditMode) {
      // Only validate these fields if NOT in edit mode
      if (educationLevel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih jenjang pendidikan terlebih dahulu')),
        );
        return false;
      }

      if (grade == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pilih kelas terlebih dahulu')));
        return false;
      }
    }
    return true;
  }

  final List<String> educationLevels = ["SD", "SMP", 'SMA'];
  List<String> grades = [];

  final _formKey = GlobalKey<FormState>();
  bool isValid = false;

  final List<String> listid = [
    "1", "2", "3", "4", "5", "6", // SD
    "7", "8", "9", // SMP
    "10", "11", "12", // SMA
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing user data if in edit mode
    _nameController = TextEditingController(
      text:
          widget.isEditMode
              ? widget.existingUser?.name
              : FirebaseAuth.instance.currentUser!.displayName,
    );

    _phoneController = TextEditingController(
      text: widget.isEditMode ? widget.existingUser?.phoneNumber : '',
    );

    if (widget.isEditMode && widget.existingUser != null) {
      // Set existing education level and grade if in edit mode
      educationLevel = widget.existingUser!.jenjang.toString().split('.').last;
      grade =
          listid.contains(widget.existingUser!.kelasId)
              ? widget.existingUser!.kelasId
              : null;
    }
  }

  void setEducationLevel(String value) {
    educationLevel = value;
    switch (value) {
      case "SD":
        grades = ["1", "2", "3", "4", "5", "6"];
        break;
      case "SMP":
        grades = ["7", "8", "9"];
        break;
      case "SMA":
        grades = ["10", "11", "12"];
        break;
    }
    setState(() {});
  }

  void setGrade(String value) {
    grade = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context, listen: false);

    Widget hint(String text, {bool required = true}) => Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color.fromRGBO(172, 172, 172, 1),
            ),
          ),
          if (required)
            Text(
              " *",
              style: TextStyle(
                color: Color.fromRGBO(203, 58, 49, 1),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
         
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color.fromARGB(255, 75, 75, 75),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 32, bottom: 32),
                    child: Center(
                      child: Text(
                        widget.isEditMode ? "Edit Profil" : "Daftar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color.fromARGB(255, 75, 75, 75),
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_back_rounded, color: Colors.transparent),
                ],
              ),
              Text(
                widget.isEditMode
                    ? 'Perbarui data diri kamu'
                    : 'Sebelum lanjut, masukkan\ndata diri kamu dulu, ya!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(75, 75, 75, 1),
                ),
              ),

              SizedBox(height: 16),
              Column(
                children: [
                  hint("Nama Kamu"),
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan nama';
                      }
                      if (value.length < 6) {
                        return 'Minimal 6 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Cont. Aditya Ahmad",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _formKey.currentState!.validate(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [hint("Asal Sekolah")],
                  ),
                  TextFormField(
                    initialValue: provider.selectedSchool!.sekolah,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Cont. SMA Negeri 1 Sragen",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [hint("Nomor Whatsapp", required: false)],
                  ),
                  TextFormField(
                    style: TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "08..",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Only show education level and grade fields if NOT in edit mode
              if (!widget.isEditMode) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          hint("Jenjang"),
                          CustomDropdown(
                            decoration: deco,
                            closedHeaderPadding: EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            hintText: 'Pilih Jenjang',
                            validator: (value) {
                              if (educationLevel == null) return "Silahkan Pilih";
                                if (grade == null ) return null;
                              if (value.toString() == "SD" &&
                                  ![
                                    "1",
                                    "2",
                                    "3",
                                    "4",
                                    "5",
                                    "6",
                                  ].contains(grade!)) {
                                return "Jenjang Tidak Sesuai";
                              }
                              if (value.toString() == "SMP" &&
                                  !["7", "8", "9"].contains(grade!)) {
                                return "Jenjang Tidak Sesuai";
                              }
                              if (value.toString() == "SMA" &&
                                  !["10", "11", "12"].contains(grade!)) {
                                return "Jenjang Tidak Sesuai";
                              }
                              return null;
                            },
                            hideSelectedFieldWhenExpanded: true,
                            items: educationLevels,
                            validateOnChange: true,
                            excludeSelected: false,
                            onChanged: (value) {
                              setEducationLevel(value!);
                              _formKey.currentState!.validate();
                              isValid = _formKey.currentState!.validate();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          hint("Kelas"),
                          CustomDropdown(
                            decoration: deco,
                            closedHeaderPadding: EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            hintText: "Pilih Kelas",
                            hideSelectedFieldWhenExpanded: true,
                            items: grades,
                            excludeSelected: false,
                            validator: (p0) {
                              if (grade == null) return "Silahkan Pilih";
                            },
                            onChanged: (value) {
                              setGrade(value!);
                              _formKey.currentState!.validate();
                              isValid = _formKey.currentState!.validate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],

              Container(
                margin: EdgeInsets.only(top: 24),
                child: ButtonLoading(
                  () async {
                    _formKey.currentState!.validate();
                    if (!_formKey.currentState!.validate()) return;
                    if (grade == null || educationLevel == null) return;
                    final userData = UserData(
                      id: widget.code,
                      email: FirebaseAuth.instance.currentUser!.email!,
                      kelasId:
                          widget.isEditMode
                              ? widget.existingUser!.kelasId
                              : "kelas" + "_" + grade!,
                      kodekabupaten: provider.selectedSchool!.kodeKabKota,
                      phoneNumber: _phoneController.text,
                      npsn: provider.selectedSchool!.npsn,
                      name: _nameController.text,
                      jenjang:
                          widget.isEditMode
                              ? widget.existingUser!.jenjang
                              : Jenjang.values.firstWhere(
                                (e) =>
                                    e.toString() == 'Jenjang.$educationLevel',
                              ),
                      userType:
                          widget.userType == "student"
                              ? UserType.SISWA
                              : UserType.GURU,
                    );

                    await FirebaseService()
                        .setUser(
                          userData,
                          FirebaseAuth.instance.currentUser!.uid,
                        )
                        .then((value) {
                          provider.setCurrentUser(value!);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => Navigation(),
                            ),
                          );
                        });
                  },
                  widget.isEditMode ? "Simpan Perubahan" : "Submit",
                  false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonLoading extends StatefulWidget {
  final Function? callback; // Notice the variable type
  final String title;
  final bool disabled;
  const ButtonLoading(this.callback, this.title, this.disabled, {super.key});
  @override
  State<ButtonLoading> createState() => _ButtonLoadingState();
}

class _ButtonLoadingState extends State<ButtonLoading> {
  var _isLoading = false;

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);
    await widget.callback!();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.disabled || _isLoading) ? null : _onSubmit,
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromHeight(50),
        padding: EdgeInsets.all(16.0),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child:
          _isLoading
              ? SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              )
              : Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
    );
  }
}

var deco = CustomDropdownDecoration(
  closedErrorBorder: Border.all(color: Colors.red, style: BorderStyle.solid),
  errorStyle: const TextStyle(fontSize: 12),
  closedErrorBorderRadius: BorderRadius.circular(50),
  headerStyle: const TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
  listItemStyle: const TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
  hintStyle: const TextStyle(color: Colors.grey),
  closedBorder: Border.all(
    color: const Color.fromRGBO(215, 215, 215, 1),
    width: 1,
  ),
  expandedBorder: Border.all(
    color: const Color.fromRGBO(215, 215, 215, 1),
    width: 1,
  ),
  expandedSuffixIcon: const Icon(
    IconsaxPlusLinear.arrow_up_1,
    color: Color.fromRGBO(75, 75, 75, 1),
  ),
  closedSuffixIcon: const Icon(
    IconsaxPlusLinear.arrow_down,
    color: Color.fromRGBO(75, 75, 75, 1),
  ),
  searchFieldDecoration: SearchFieldDecoration(
    prefixIcon: const Icon(
      Icons.search_rounded,
      color: Color.fromRGBO(75, 75, 75, 1),
    ),
    suffixIcon:
        (onClear) => const Icon(Icons.close_rounded, color: Colors.transparent),

    hintStyle: const TextStyle(
      color: Colors.grey,
    ), // Optional: Change hint color

    fillColor: Colors.white, // Optional: Background color of the text field
    contentPadding: const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 16.0,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0), // Adjust the roundness
      borderSide: BorderSide.none, // Removes border line
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(
        color: Color.fromRGBO(4, 123, 145, 1),
        width: 1.5,
      ), // Focused border color
    ),
  ),
  closedBorderRadius: BorderRadius.circular(25),
  expandedBorderRadius: BorderRadius.circular(25),
);
