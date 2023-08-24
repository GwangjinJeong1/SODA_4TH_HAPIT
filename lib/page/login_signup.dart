import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onPressed;
  const LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;

  bool isLoading = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      setState(() {
        isLoading = false;
      });

      // 로그인 성공 시에 SignPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("이메일을 찾을 수 없습니다."),
          ),
        );
      } else if (e.code == 'wrong-password') {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("비밀번호를 다시 확인해주세요."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: SvgPicture.asset('public/images/logo.svg'),
                ),
                SizedBox(
                  width: 277,
                  child: TextFormField(
                    controller: _email,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return '이메일을 다시 확인해주세요.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "이메일",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 15, 14, 1)),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 15, 14, 1)),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(153, 159, 155, 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: 277,
                  child: TextFormField(
                    controller: _password,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return '비밀번호를 다시 확인해주세요.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 15, 14, 1)),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 15, 14, 1)),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(153, 159, 155, 1),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 250),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        checkColor: Colors.white,
                        activeColor: Colors.blue,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      const Text(
                        "자동로그인",
                        style: TextStyle(
                            color: Color.fromRGBO(14, 15, 14, 1),
                            fontFamily: 'SpoqaHanSansNeo-Regular',
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: 219,
                  height: 51,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        signInWithEmailAndPassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            const Color.fromRGBO(100, 215, 251, 1)),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "로그인",
                            style: TextStyle(
                              color: Color.fromRGBO(14, 15, 14, 1),
                              fontFamily: 'SpoqaHanSansNeo-Medium',
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                SizedBox(
                  width: 219,
                  height: 51,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: (const Color.fromRGBO(237, 237, 237, 1)),
                    ),
                    onPressed: widget.onPressed,
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: Color.fromRGBO(14, 15, 14, 1),
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//-----------------------회원가입
class SignUP extends StatefulWidget {
  final void Function()? onPressed;
  final user = FirebaseAuth.instance.currentUser;
  SignUP({super.key, required this.onPressed});

  @override
  State<SignUP> createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final String _profileImageUrl =
      'public/images/profile.svg'; // Default image URL

  createUserWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // 사용자 정보를 저장
        await userDocRef.set({
          'userId': user.uid,
          'nickname': _nicknameController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'email': _email.text,
          'profile': _profileImageUrl, // Save profile image URL
        });

        // 홈 페이지로 이동하면서 닉네임 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WelcomePage(nickname: _nicknameController.text),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 150),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 53, right: 400),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginAndSignUp()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: SvgPicture.asset('public/images/profile.svg'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: SizedBox(
                    width: 277,
                    child: TextFormField(
                      controller: _nicknameController,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return '닉네임을 입력해주세요.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "닉네임",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(14, 15, 14, 1)),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(14, 15, 14, 1)),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(153, 159, 155, 1),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: SizedBox(
                    width: 277,
                    child: TextFormField(
                      controller: _email,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return '이메일을 다시 확인해주세요.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "이메일",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(14, 15, 14, 1)),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(14, 15, 14, 1)),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(153, 159, 155, 1),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: SizedBox(
                    width: 277,
                    child: TextFormField(
                      controller: _password,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return '비밀번호를 다시 확인해주세요.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(14, 15, 14, 1)),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(14, 15, 14, 1)),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(153, 159, 155, 1),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 219,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: (const Color.fromRGBO(237, 237, 237, 1)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await createUserWithEmailAndPassword();
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomePage(
                                nickname: _nicknameController.text)),
                      );
                    },
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: Color.fromRGBO(14, 15, 14, 1),
                        fontFamily: 'SpoqaHanSansNeo-Medium',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//--------------------회원가입 이후

class WelcomePage extends StatelessWidget {
  final String nickname;

  const WelcomePage({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SvgPicture.asset('public/images/celeb.svg'),
                Padding(
                  padding: const EdgeInsets.only(left: 100, top: 70),
                  child: SvgPicture.asset('public/images/char.svg'),
                ),
              ],
            ),
            Text(
              "$nickname님, 가입이 완료되었어요!",
              style: const TextStyle(
                color: Color.fromRGBO(14, 15, 14, 1),
                fontFamily: 'SpoqaHanSansNeo-Medium',
                fontSize: 18,
              ),
            ),
            const Text(
              "해핏에 오신걸 환영해요 :->",
              style: TextStyle(
                color: Color.fromRGBO(14, 15, 14, 1),
                fontFamily: 'SpoqaHanSansNeo-Medium',
                fontSize: 18,
              ),
            ), // 사용자의 닉네임 표시
            Padding(
              padding: const EdgeInsets.only(top: 84, bottom: 100),
              child: SizedBox(
                height: 42,
                width: 143,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color.fromRGBO(100, 215, 251, 1)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginAndSignUp()),
                    );
                  },
                  child: const Text(
                    "로그인하기",
                    style: TextStyle(
                      color: Color.fromRGBO(14, 15, 14, 1),
                      fontFamily: 'SpoqaHanSansNeo-Medium',
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
