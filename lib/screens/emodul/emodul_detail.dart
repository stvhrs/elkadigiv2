import 'dart:async';
import 'dart:io';
import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/video_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elka/model/emodul_model.dart';

// Hive setup
class PdfCache {
  final String filePath;
  final DateTime timestamp;

  PdfCache(this.filePath, this.timestamp);

  Map<dynamic, dynamic> toMap() => {
    'filePath': filePath,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  static PdfCache? fromCache(dynamic cachedData) {
    if (cachedData is Map) {
      return PdfCache(
        cachedData['filePath'],
        DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']),
      );
    }
    return null;
  }
}

class EmodulDetail extends StatefulWidget {
  final EmodulModel path;

  const EmodulDetail({super.key, required this.path});

  @override
  State<EmodulDetail> createState() => _EmodulDetailState();
}

class _EmodulDetailState extends State<EmodulDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  String? _cachedFilePath;
  bool _isLoading = false;
  bool _hasError = false;
  double _downloadProgress = 0.0;
  final PdfViewerController _pdfController = PdfViewerController();
  final int cacheDurationMs = 4 * 24 * 60 * 60 * 1000; // 4 days in milliseconds

  void _onLinkClicked(String url) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VideoPage(url),
        transitionsBuilder:
            (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPdf();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );
  }

  Future<T?> _fetchWithCache<T>({
    required String cacheKey,
    required Future<T?> Function() fetchFreshData,
    required T? Function(dynamic) fromCache,
    required Map<dynamic, dynamic> Function(T) toMap,
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
          debugPrint("Fetching $cacheKey from cache");
          final result = fromCache(cachedData);
          debugPrint("[CACHE HIT] Successfully fetched $cacheKey from cache");
          return result;
        }
      }

      debugPrint("Fetching fresh data for $cacheKey");
      final freshData = await fetchFreshData();
      if (freshData != null) {
        await box.put(cacheKey, toMap(freshData));
        await box.put('${cacheKey}_timestamp', currentTime);
        debugPrint("[FRESH DATA] Successfully cached $cacheKey");
      }
      return freshData;
    } catch (e) {
      debugPrint("Error fetching $cacheKey: $e");
      rethrow;
    }
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _downloadProgress = 0.0;
      });

      final cachedPdf = await _fetchWithCache<PdfCache>(
        cacheKey: widget.path.pdfUrl,
        fetchFreshData: _downloadPdf,
        fromCache: PdfCache.fromCache,
        toMap: (pdf) => pdf.toMap(),
      );

      if (cachedPdf != null && await File(cachedPdf.filePath).exists()) {
        setState(() {
          _cachedFilePath = cachedPdf.filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Error loading PDF: $e');
    }
  }

  Future<PdfCache> _downloadPdf() async {
    final tempDir = await getTemporaryDirectory();
    final localPath =
        '${tempDir.path}/cached_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final dio = Dio();
    await dio.download(
      widget.path.pdfUrl,
      localPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            _downloadProgress = received / total * 100;
            _animationController.value = _downloadProgress / 100;
          });
        }
      },
    );

    return PdfCache(localPath, DateTime.now());
  }

  Future<void> _refreshPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _downloadProgress = 0.0;
      });

      final freshPdf = await _fetchWithCache<PdfCache>(
        cacheKey: widget.path.pdfUrl,
        fetchFreshData: _downloadPdf,
        fromCache: PdfCache.fromCache,
        toMap: (pdf) => pdf.toMap(),
        forceRefresh: true,
      );

      if (freshPdf != null) {
        setState(() {
          _cachedFilePath = freshPdf.filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _hasError = true);
      debugPrint('Error refreshing PDF: $e');
    }
  }

  Future<void> _downloadAndShare() async {
    try {
      final pdfFile = File(_cachedFilePath!);

      await Printing.sharePdf(
        bytes: await pdfFile.readAsBytes(),
        filename: "${widget.path.namaBuku}.pdf",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share PDF: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircleAvatar(
        backgroundColor: context.read<NavigationProvider>().color,
        child: IconButton(
          onPressed: _downloadAndShare,
          icon: Icon(Icons.download_rounded, color: Colors.white),
        ),
      ),

      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _refreshPdf,
            icon: Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
        backgroundColor: context.read<NavigationProvider>().color,
        title: Text(widget.path.namaBuku),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load PDF'),
            TextButton(onPressed: _refreshPdf, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_isLoading || _cachedFilePath == null) {
      return Center(
        child: SizedBox(
          width: 300,
          child: AnimatedBuilder(
            animation: _heightAnimation,
            builder:
                (context, _) => Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: widget.path.imgUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: _heightAnimation.value,
                        child: CachedNetworkImage(
                          imageUrl: widget.path.imgUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: Text(
                        '${_downloadProgress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Helper.localColor(widget.path.namaBuku),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 3,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      );
    }

    return SfPdfViewerTheme(
      data: SfPdfViewerThemeData(
        progressBarColor: context.read<NavigationProvider>().color,
        scrollHeadStyle: PdfScrollHeadStyle(
          backgroundColor: Helper.lightenColor(
            context.read<NavigationProvider>().color,
            0.7,
          ),
        ),

        backgroundColor: Colors.white,
      ),

      child: SfPdfViewer.file(
        canShowHyperlinkDialog: false,
        onDocumentLoaded: (v) {},
        File(_cachedFilePath!),
        onHyperlinkClicked: (s) {
          _onLinkClicked(s.uri);
        },
        controller: _pdfController,
      ),
    );
  }
}
