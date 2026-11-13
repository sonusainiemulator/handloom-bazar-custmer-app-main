import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoDescription extends StatefulWidget {
  final String? url;

  const VideoDescription({super.key, this.url});

  @override
  State<VideoDescription> createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
          "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'intent' ||
                uri.scheme == 'market' ||
                uri.scheme == 'vnd.youtube') {
              launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _webViewController = controller;
    _loadVideo();
  }

  String? _extractYouTubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:watch\?.*v=|embed\/|shorts\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  String? _extractDailymotionId(String url) {
    final regExp = RegExp(
      r'(?:dailymotion\.com\/(?:video|embed\/video)\/|dai\.ly\/)([a-zA-Z0-9]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  String? _extractVimeoId(String url) {
    final regExp = RegExp(
      r'vimeo\.com\/(?:video\/)?([0-9]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  void _loadVideo() {
    final rawUrl = widget.url?.trim() ?? '';
    if (rawUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final ytId = _extractYouTubeId(rawUrl);
    if (ytId != null) {
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; background-color: #000; }
    html, body { width: 100%; height: 100%; overflow: hidden; display: flex; align-items: center; justify-content: center; }
    .video-container { position: relative; width: 100%; height: 100%; }
    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe 
      src="https://www.youtube-nocookie.com/embed/$ytId?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1" 
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';
      _webViewController.loadHtmlString(html, baseUrl: "https://www.youtube-nocookie.com");
      return;
    }

    final dmId = _extractDailymotionId(rawUrl);
    if (dmId != null) {
      final embedUrl = "https://www.dailymotion.com/embed/video/$dmId?autoplay=1";
      _webViewController.loadRequest(Uri.parse(embedUrl));
      return;
    }

    final vimeoId = _extractVimeoId(rawUrl);
    if (vimeoId != null) {
      final embedUrl = "https://player.vimeo.com/video/$vimeoId?autoplay=1";
      _webViewController.loadRequest(Uri.parse(embedUrl));
      return;
    }

    // Direct MP4 or external web video link
    if (rawUrl.toLowerCase().endsWith('.mp4') ||
        rawUrl.toLowerCase().endsWith('.webm') ||
        rawUrl.toLowerCase().endsWith('.mkv')) {
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; background: #000; }
    html, body { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden; }
    video { width: 100%; height: 100%; object-fit: contain; }
  </style>
</head>
<body>
  <video src="$rawUrl" controls autoplay playsinline></video>
</body>
</html>
''';
      _webViewController.loadHtmlString(html);
      return;
    }

    // Fallback direct URL load
    try {
      _webViewController.loadRequest(Uri.parse(rawUrl));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _openExternal() async {
    final rawUrl = widget.url?.trim() ?? '';
    if (rawUrl.isEmpty) return;
    final uri = Uri.tryParse(rawUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: WebViewWidget(controller: _webViewController),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                if (_hasError)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white70, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          "Failed to load video",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.accent_color,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _openExternal,
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text("Open in Browser / YouTube"),
                        )
                      ],
                    ),
                  ),
                // Top Action Bar with Back & External Open
                Positioned(
                  top: 10,
                  left: app_language_rtl.$! ? null : 10,
                  right: app_language_rtl.$! ? 10 : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.arrow_left,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: app_language_rtl.$! ? null : 10,
                  left: app_language_rtl.$! ? 10 : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      tooltip: "Open externally",
                      icon: const Icon(Icons.open_in_new,
                          color: Colors.white, size: 20),
                      onPressed: _openExternal,
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
