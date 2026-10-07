import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/live_background.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const LoginScreen({super.key, required this.onThemeToggle});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Admin Credentials Special Check
    if (email == '24ceuoz014@ddu.ac.in' && password == 'Parva@1603') {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (_) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome Super Admin! Access granted.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(onThemeToggle: widget.onThemeToggle),
          ),
        );
        return;
      }
    }

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(onThemeToggle: widget.onThemeToggle),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        const webClientId =
            '565718048353-rnc2801bifk4djstv2373iern8esld1i.apps.googleusercontent.com';

        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // User canceled login
          return;
        }

        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (accessToken == null && idToken == null) {
          throw 'No Tokens found.';
        }

        final credential = GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: accessToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => HomeScreen(onThemeToggle: widget.onThemeToggle)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: LiveBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 850;
              return Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 12,
                    child: IconButton(
                      tooltip: isDark
                          ? 'Switch to light theme'
                          : 'Switch to dark theme',
                      onPressed: widget.onThemeToggle,
                      icon: Icon(isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 40 : 22,
                        vertical: 54,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: wide
                            ? Row(
                                children: [
                                  Expanded(child: _buildWelcomePanel(context)),
                                  const SizedBox(width: 54),
                                  SizedBox(
                                      width: 390,
                                      child: _buildAuthForm(context)),
                                ],
                              )
                            : _buildAuthForm(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePanel(BuildContext context) {
    return SizedBox(
      height: 510,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=1400&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFF31594E)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x16000000), Color(0xB5000000)],
                ),
              ),
            ),
            Positioned(
              left: 34,
              right: 34,
              bottom: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRAVEL,\nWITHOUT THE\nTEMPLATE.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      height: 1.02,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Keep your plans loose. Let the good parts find you.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 15,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.explore_rounded, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'TravelMaster',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(
          _isLogin ? 'Welcome back.' : 'Make room\nfor somewhere new.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                height: 1.08,
                fontWeight: FontWeight.w800,
              ),
        ).animate(key: ValueKey(_isLogin)).fadeIn(duration: 250.ms),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Your next trip is closer than you think.'
              : 'Create an account and start finding your way.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 28),
        _buildTextField(
          controller: _emailController,
          label: 'Email address',
          icon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePassword,
          suffix: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(_obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(_isLogin ? 'Sign in' : 'Create account'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _googleSignIn,
            icon: Image.asset('assets/images/google_logo.png', height: 19),
            label: const Text('Continue with Google'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(onThemeToggle: widget.onThemeToggle),
                ),
              );
            },
            icon: const Icon(Icons.explore_rounded, color: Colors.deepOrange, size: 20),
            label: const Text(
              'Explore Packages as Guest →',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isLogin = !_isLogin),
            child: Text(
              _isLogin
                  ? 'New here? Create an account'
                  : 'Already have an account? Sign in',
              style:
                  TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}
