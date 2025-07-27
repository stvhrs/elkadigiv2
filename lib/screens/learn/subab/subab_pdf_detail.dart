import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elka/helper.dart';
import 'package:elka/main.dart';
import 'package:elka/model/emodul_model.dart';
import 'package:elka/provider/navigation_provider.dart';
import 'package:elka/screens/learn/subab/video_page.dart';
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
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

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

class SubabPdfDetail extends StatefulWidget {
  final EmodulModel path;

  const SubabPdfDetail({super.key, required this.path});

  @override
  State<SubabPdfDetail> createState() => _SubabPdfDetailState();
}

class _SubabPdfDetailState extends State<SubabPdfDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  String? _cachedFilePath;
  bool _isLoading = false;
  bool _hasError = false;
  double _downloadProgress = 0.0;
  final PdfViewerController _pdfController = PdfViewerController();
  Uint8List? _pdfBytes;
  
  final int cacheDurationMs = 4 * 24 * 60 * 60 * 1000; // 4 days in milliseconds
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? _filePath;

  void _onLinkClicked(String url) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) =>
                VideoPage( url,),
        transitionsBuilder:
            (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initHive().then((_) => _loadPdf());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );
  }

  Future<void> _initHive() async {
    _saveScore(1);
  }

  Future<T?> _fetchWithCache<T>({
    required String cacheKey,
    required Future<T?> Function() fetchFreshData,
    required T? Function(dynamic) fromCache,
    required Map<dynamic, dynamic> Function(T) toMap,
    bool forceRefresh = false,
  }) async {
    try {
      if (kIsWeb) {
        // On web, we can't use Hive for file caching, so just fetch fresh data
        return await fetchFreshData();
      }

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
      if (freshData != null && !kIsWeb) {
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

      if (kIsWeb) {
        // Web-specific handling
        final dio = Dio();
        final response = await dio.get(
          widget.path.pdfUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        
        setState(() {
          _pdfBytes = Uint8List.fromList(response.data);
          _isLoading = false;
        });
      } else {
        // Mobile handling
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
    if (kIsWeb) {
      throw Exception("_downloadPdf should not be called on web");
    }
    
    final tempDir = await getTemporaryDirectory();
    final localPath =
        '${tempDir.path}/cached_${DateTime.now().millisecondsSinceEpoch}.pdf';
    _filePath = localPath;
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

  Future<void> _saveScore(double score) async {
    final roundedScore = score.floor();
    await box.put(widget.path.pdfUrl+widget.path.namaBuku, roundedScore);
  }

  Future<void> _refreshPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _downloadProgress = 0.0;
      });

      if (kIsWeb) {
        final dio = Dio();
        final response = await dio.get(
          widget.path.pdfUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        
        setState(() {
          _pdfBytes = Uint8List.fromList(response.data);
          _isLoading = false;
        });
      } else {
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
      }
    } catch (e) {
      setState(() => _hasError = true);
      debugPrint('Error refreshing PDF: $e');
    }
  }

  Future<void> _downloadAndShare() async {
    try {
      if (kIsWeb) {
        // Web download
        final bytes = _pdfBytes;
        if (bytes != null) {
          final blob = html.Blob([bytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', '${widget.path.namaBuku}.pdf')
            ..click();
          html.Url.revokeObjectUrl(url);
        }
      } else {
        // Mobile share
        final pdfFile = File(_cachedFilePath!);
        await Printing.sharePdf(
          bytes: await pdfFile.readAsBytes(),
          filename: "${widget.path.namaBuku}.pdf",
        );
      }
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
        backgroundColor: context.read<NavigationProvider>().color,
        actions: [
          IconButton(
            onPressed: _refreshPdf,
            icon: Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
        title: Text(widget.path.namaBuku),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var prov = context.read<NavigationProvider>();

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

    if (_isLoading || (kIsWeb ? _pdfBytes == null : _cachedFilePath == null)) {
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
                          imageUrl:  context.read<NavigationProvider>().selectedSubject!
                          .imageUrl,
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
                          imageUrl:  context.read<NavigationProvider>().selectedSubject!
                          .imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: Text(
                        '${_downloadProgress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: context.read<NavigationProvider>().color,
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
            child: kIsWeb
                ? SfPdfViewer.memory(
                    _pdfBytes!,
                    onDocumentLoaded: (v) {
                      _filePath = widget.path.pdfUrl;
                    },
                    onHyperlinkClicked: (s) {
                      _onLinkClicked(s.uri);
                    },
                    controller: _pdfController,
                  )
                : SfPdfViewer.file(
                    File(_cachedFilePath!),
                    onDocumentLoaded: (v) {
                      _filePath = _cachedFilePath;
                    },
                    onHyperlinkClicked: (s) {
                      _onLinkClicked(s.uri);
                    },
                    controller: _pdfController,
                  ),
      
    );
  }
}