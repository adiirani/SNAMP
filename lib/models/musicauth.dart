import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class YTMusicAuth extends StatefulWidget {
  final Function(Map<String, String>) onAuthSuccess;

  const YTMusicAuth({Key? key, required this.onAuthSuccess}) : super(key: key);

  @override
  _YTMusicAuthState createState() => _YTMusicAuthState();
}

class _YTMusicAuthState extends State<YTMusicAuth> {
  static const String AUTH_COOKIES_KEY = 'yt_music_auth_cookies';
  late InAppWebViewController _controller;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<Map<String, String>> _extractCookies() async {
    final url = await _controller.getUrl();
    List<Cookie> cookies = await CookieManager.instance().getCookies(url: url!);
    
    // Map all cookies by name and value
    final Map<String, String> cookieMap = {
      for (var cookie in cookies) cookie.name: cookie.value,
    };
    
    return cookieMap;
  }

  Future<void> _saveCookies(Map<String, String> cookies) async {
    if (_isDisposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AUTH_COOKIES_KEY, json.encode(cookies));
      
      // Debug print cookies
      debugPrint('Saved YouTube Music cookies:');
      debugPrint(prefs.getString(AUTH_COOKIES_KEY));

      if (!_isDisposed) {
        widget.onAuthSuccess(cookies);
      }
    } catch (e) {
      debugPrint('Error saving cookies: $e');
    }
  }

  Future<bool> _handleBackPress() async {
    if (_isDisposed) return true;
    
    try {
      final cookies = await _extractCookies();
      await _saveCookies(cookies);
      if (!_isDisposed && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error handling back press: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save authentication. Please try again.')),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SIGN IN TO YTM'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleBackPress(),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://accounts.google.com/ServiceLogin?ltmpl=music&service=youtube&passive=true&continue=https%3A%2F%2Fwww.youtube.com%2Fsignin%3Faction_handle_signin%3Dtrue%26next%3Dhttps%253A%252F%252Fmusic.youtube.com%252F'),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _isLoading = false;
                });
                if (!_isDisposed && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading page: $message')),
                  );
                }
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  cacheEnabled: true,
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class YTMusicAuthManager {
  static const String AUTH_COOKIES_KEY = 'yt_music_auth_cookies';

  static Future<Map<String, String>?> getStoredCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cookiesJson = prefs.getString(AUTH_COOKIES_KEY);
      if (cookiesJson != null) {
        Map<String, dynamic> decoded = json.decode(cookiesJson);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting stored cookies: $e');
      return null;
    }
  }

  static Future<bool> clearCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AUTH_COOKIES_KEY);
      return true;
    } catch (e) {
      debugPrint('Error clearing cookies: $e');
      return false;
    }
  }
}