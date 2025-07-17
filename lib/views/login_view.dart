import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _kvkkAccepted = false;
  bool _kvkkRead = false;
  String? _errorText;

  Future<void> _showKvkkDialog() async {
    bool okudum = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('KVKK Kanunu'),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KİŞİSEL VERİLERİN KORUNMASI KANUNU (KVKK)\n\n'
                        'Bu uygulamayı kullanarak kişisel verilerinizin işlenmesini, saklanmasını ve gerektiğinde paylaşılmasını kabul etmiş olursunuz. Kişisel verileriniz, yalnızca hizmetin sunulması ve yasal yükümlülüklerin yerine getirilmesi amacıyla kullanılacaktır.\n\n'
                        'Daha fazla bilgi için lütfen resmi KVKK metnine başvurunuz.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Checkbox(
                            value: okudum,
                            onChanged: (value) {
                              setState(() {
                                okudum = value ?? false;
                              });
                            },
                          ),
                          const Text('Okudum')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: okudum
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {
      _kvkkRead = okudum;
      if (!_kvkkRead) _kvkkAccepted = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Otomatik KVKK dialogu açılmasın, sadece metne tıklanınca açılsın
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showKvkkDialog();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF7C3AED),
        elevation: 0,
        title: const Text('Giriş Yap', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Text(
                  'BRIDGE TRANS AI',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorText != null) ...[
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Text('E-posta veya Kullanıcı Adı'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'E-posta',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Şifre'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _kvkkAccepted,
                        onChanged: _kvkkRead
                            ? (value) {
                                setState(() {
                                  _kvkkAccepted = value ?? false;
                                });
                              }
                            : null,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showKvkkDialog,
                          child: const Text.rich(
                            TextSpan(
                              text: 'KVKK Kanunu kapsamında kişisel verilerimin işlenmesini kabul ediyorum.',
                              style: TextStyle(
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _kvkkAccepted
                          ? () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              if (email == '123' && password == '123') {
                                setState(() {
                                  _errorText = null;
                                });
                                context.go('/');
                              } else {
                                setState(() {
                                  _errorText = 'E-posta veya şifre yanlış!';
                                });
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7C3AED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.go('/forgot-password');
                        },
                        child: const Text(
                          'Şifremi Unuttum?',
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 