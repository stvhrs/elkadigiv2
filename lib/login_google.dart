import 'package:elka/model/school.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/registration.dart';
import 'package:elka/screens/navigation.dart';
import 'package:elka/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Tambahkan key untuk form

  // Method to validate the TextFormField
  bool isValidCode(String code) {
    return code.isNotEmpty && code.length > 7;
  }

  Future<void> handleSignIn() async {
    try {
      setState(() => _loading = true);

      String code = _controller.text.trim();

      if (_formKey.currentState!.validate()) {
        final school = await FirebaseService().signInWithGoogle(path, code);

        if (school != null) {
          context.read<NavigationProvider>().setSelectedSchool(school);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Registration(path, _controller.text.trim()),
            ),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed or code invalid')),
          );
        }
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  bool isSelected1 = true;
  bool isSelected2 = false;
  String path = "student";

  // Method to handle checkbox selection
  void handleCheckboxSelection(int index) {
    setState(() {
      if (index == 1) {
        path = "student";
        isSelected1 = true;
        isSelected2 = false; // Unselect the other checkbox
      } else if (index == 2) {
        path = "school";
        isSelected2 = true;
        isSelected1 = false; // Unselect the other checkbox
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("asset/locked.png", width: 80),
                SizedBox(height: 8),
                Text(
                  "Kode Akses",
                  style: TextStyle(
                    color: Color.fromRGBO(53, 53, 53, 1),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Masukan Kode yang sudah diberikan",
                  style: TextStyle(
                    color: Color.fromRGBO(53, 53, 53, 1),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Image.asset("asset/siswa.png", width: 25),
                          Text("  Siswa"),
                          Checkbox(
                            value: isSelected1,
                            onChanged: (value) {
                              handleCheckboxSelection(1);
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Row(
                        children: [
                          Image.asset("asset/guru.png", width: 25),
                          Text("  Guru"),
                          Checkbox(
                            value: isSelected2,
                            onChanged: (value) {
                              handleCheckboxSelection(2);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Gunakan Form dan validator pada TextFormField
                  Form(
                    key: _formKey, // Form Key
                    child: TextFormField(
                      onChanged: (v) {},
                      controller: _controller,
                      style: TextStyle(color: Color.fromRGBO(53, 53, 53, 1)),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        alignLabelWithHint: true,
                        hintText: "Cont. PWD105123271",
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          size: 20,
                          color: Color.fromRGBO(103, 164, 114, 1),
                        ),

                        border: OutlineInputBorder(),
                      ),
                      // Menambahkan validator
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode akses tidak boleh kosong';
                        } else if (value.length <= 7) {
                          return 'Kode akses harus lebih dari 7 karakter';
                        }
                        return null; // Valid
                      },
                    ),
                  ),
                  SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonGoogleLong(
                      handleSignIn,
                      "Masuk Dengan Google",
                      false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonGoogleLong extends StatefulWidget {
  final Function? callback; // Notice the variable type
  final String title;
  final bool disabled;
  const ButtonGoogleLong(this.callback, this.title, this.disabled, {super.key});
  @override
  State<ButtonGoogleLong> createState() => _ButtonGoogleLongState();
}

class _ButtonGoogleLongState extends State<ButtonGoogleLong> {
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
        fixedSize: const Size.fromHeight(48),
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
          left: 32,
          right: 32,
        ),
        backgroundColor: Color.fromRGBO(103, 164, 114, 1),
      ),
      child:
          _isLoading
              ? SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("asset/Google.png", color: Colors.white),
                  Spacer(),
                  Text(widget.title, style: TextStyle(color: Colors.white)),
                  Spacer(),
                ],
              ),
    );
  }
}


// import 'package:elka/model/school.dart';
// import 'package:elka/model/user.dart';
// import 'package:elka/provider/navigation_provider.dart';
// import 'package:elka/registration.dart';
// import 'package:elka/screens/navigation.dart';
// import 'package:elka/service/firebase_service.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:iconsax_plus/iconsax_plus.dart';
// import 'package:provider/provider.dart';

// class SignInPage extends StatefulWidget {
//   const SignInPage({super.key});

//   @override
//   State<SignInPage> createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {
//   bool _loading = false;
//   final TextEditingController _controller = TextEditingController();
//   final _formKey = GlobalKey<FormState>(); // Tambahkan key untuk form

//   // Method to validate the TextFormField
//   bool isValidCode(String code) {
//     return code.isNotEmpty && code.length > 7;
//   }

//   Future<void> handleSignIn() async {
//     try {
//       setState(() => _loading = true);

//       String code = _controller.text.trim();

//       if (_formKey.currentState!.validate()) {
//         final school = await FirebaseService().signInWithGoogle(path, code);

//         if (school != null) {
//           context.read<NavigationProvider>().setSelectedSchool(school);
//           FirebaseService().setUser(
//             UserData.fromJson({
//               "email":  FirebaseAuth.instance.currentUser!.email,
//               "id": "SJPA10120318835",
//               "jenjang": "SD",
//               "kelas_id": "kelas_6",
//               "kodekabupaten": "032000  ",
//               "name": FirebaseAuth.instance.currentUser!.displayName,
//               "npsn": "20318520",
//               "phone_number": "046464",
//               "usertype": "SISWA",
//             }),
//             FirebaseAuth.instance.currentUser!.uid,
//           );
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => Navigation(),
//             ),
//           );
//           return;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login failed or code invalid')),
//           );
//         }
//       }
//     } catch (e) {
//       print(e.toString());
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   bool isSelected1 = true;
//   bool isSelected2 = false;
//   String path = "student";

//   // Method to handle checkbox selection
//   void handleCheckboxSelection(int index) {
//     setState(() {
//       if (index == 1) {
//         path = "student";
//         isSelected1 = true;
//         isSelected2 = false; // Unselect the other checkbox
//       } else if (index == 2) {
//         path = "school";
//         isSelected2 = true;
//         isSelected1 = false; // Unselect the other checkbox
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Spacer(),
//           Expanded(
//             flex: 3,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset("asset/locked.png", width: 80),
//                 SizedBox(height: 8),
//                 Text(
//                   "Kode Akses",
//                   style: TextStyle(
//                     color: Color.fromRGBO(53, 53, 53, 1),
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "Masukan Kode yang sudah diberikan",
//                   style: TextStyle(
//                     color: Color.fromRGBO(53, 53, 53, 1),
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             flex: 4,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Row(
//                         children: [
//                           Image.asset("asset/siswa.png", width: 25),
//                           Text("  Siswa"),
//                           Checkbox(
//                             value: isSelected1,
//                             onChanged: (value) {
//                               handleCheckboxSelection(1);
//                             },
//                           ),
//                         ],
//                       ),
//                       SizedBox(width: 16),
//                       Row(
//                         children: [
//                           Image.asset("asset/guru.png", width: 25),
//                           Text("  Guru"),
//                           Checkbox(
//                             value: isSelected2,
//                             onChanged: (value) {
//                               handleCheckboxSelection(2);
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   // Gunakan Form dan validator pada TextFormField
//                   Form(
//                     key: _formKey, // Form Key
//                     child: TextFormField(
//                       onChanged: (v) {},
//                       controller: _controller,
//                       style: TextStyle(color: Color.fromRGBO(53, 53, 53, 1)),
//                       decoration: InputDecoration(
//                         hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
//                         alignLabelWithHint: true,
//                         hintText: "Cont. PWD105123271",
//                         prefixIcon: Icon(
//                           Icons.lock_rounded,
//                           size: 20,
//                           color: Color.fromRGBO(103, 164, 114, 1),
//                         ),

//                         border: OutlineInputBorder(),
//                       ),
//                       // Menambahkan validator
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Kode akses tidak boleh kosong';
//                         } else if (value.length <= 7) {
//                           return 'Kode akses harus lebih dari 7 karakter';
//                         }
//                         return null; // Valid
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 48),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ButtonGoogleLong(
//                       handleSignIn,
//                       "Masuk Dengan Google",
//                       false,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ButtonGoogleLong extends StatefulWidget {
//   final Function? callback; // Notice the variable type
//   final String title;
//   final bool disabled;
//   const ButtonGoogleLong(this.callback, this.title, this.disabled, {super.key});
//   @override
//   State<ButtonGoogleLong> createState() => _ButtonGoogleLongState();
// }

// class _ButtonGoogleLongState extends State<ButtonGoogleLong> {
//   var _isLoading = false;

//   Future<void> _onSubmit() async {
//     setState(() => _isLoading = true);
//     await widget.callback!();
//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: (widget.disabled || _isLoading) ? null : _onSubmit,
//       style: ElevatedButton.styleFrom(
//         fixedSize: const Size.fromHeight(48),
//         padding: const EdgeInsets.only(
//           top: 16,
//           bottom: 16,
//           left: 32,
//           right: 32,
//         ),
//         backgroundColor: Color.fromRGBO(103, 164, 114, 1),
//       ),
//       child:
//           _isLoading
//               ? SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     color: Theme.of(context).primaryColor,
//                     strokeCap: StrokeCap.round,
//                   ),
//                 ),
//               )
//               : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset("asset/Google.png", color: Colors.white),
//                   Spacer(),
//                   Text(widget.title, style: TextStyle(color: Colors.white)),
//                   Spacer(),
//                 ],
//               ),
//     );
//   }
// }
