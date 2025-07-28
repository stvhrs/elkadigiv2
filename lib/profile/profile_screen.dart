import 'package:elka/login_google.dart';
import 'package:elka/main.dart';
import 'package:elka/model/user.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/registration.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

class ButtonLoading3 extends StatefulWidget {
  final Function? callback; // Notice the variable type
  final String title;
  final bool disabled;
  const ButtonLoading3(this.callback, this.title, this.disabled, {super.key});
  @override
  State<ButtonLoading3> createState() => _ButtonLoadingState3();
}

class _ButtonLoadingState3 extends State<ButtonLoading3> {
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
        fixedSize: const Size.fromHeight(45),
        backgroundColor: Color.fromRGBO(244, 109, 109, 1),
      ),
      child:
          _isLoading
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Transform.flip(
                      flipX: true,
                      child: Icon(Icons.logout, color: Colors.white, size: 18),
                    ),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus Akun"),
          content: Text(
            "Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (FirebaseAuth.instance.currentUser != null) {
                    final GoogleSignIn googleSignIn = GoogleSignIn();

                    await googleSignIn.signOut();
                    await FirebaseAuth.instance.signOut();
                    box.clear();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  }
                } catch (e) {
                  return null;
                }
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Profil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          Consumer<NavigationProvider>(
            builder: (context, data, c) {
              return Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 15,
                  top: 16,
                ),
                child: Container(
                  padding: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        trailing:
                            FirebaseAuth.instance.currentUser == null
                                ? SizedBox()
                                : GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => Registration(
                                              data.currentUser!.userType ==
                                                      UserType.SISWA
                                                  ? "student"
                                                  : "school",
                                              data.currentUser!.id,
                                              isEditMode: true,
                                              existingUser: data.currentUser,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Icon(IconsaxPlusLinear.user_edit),
                                ),
                        title: Text(
                          data.currentUser!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color.fromRGBO(75, 75, 75, 1),
                          ),
                        ),
                        subtitle: Text(
                          list[listid.indexOf(data.currentUser!.kelasId)],

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color.fromRGBO(172, 172, 172, 1),
                          ),
                        ),
                        leading: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: CachedNetworkImage(
                            imageUrl:
                                FirebaseAuth.instance.currentUser!.photoURL!,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(244, 244, 244, 1),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          textAlign: TextAlign.center,
                          data.selectedSchool!.sekolah,

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      showDeleteAccountDialog(context);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Color.fromRGBO(244, 109, 109, 1),
                          size: 16,
                        ),
                        Text(
                          "   Hapus Akun",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(244, 109, 109, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonLoading3(
              () async {
                try {
                  if (FirebaseAuth.instance.currentUser != null) {
                    final GoogleSignIn googleSignIn = GoogleSignIn();

                    await googleSignIn.signOut();
                    await FirebaseAuth.instance.signOut();
                    box.clear();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  }
                } catch (e) {
                  return null;
                }
                // Trigger the authentication flow
              },
              "Log out",
              false,
            ),
          ),
        ],
      ),
    );
  }
}
