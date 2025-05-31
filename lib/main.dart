import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'dart:io';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PdfTtsScreen(),
    );
  }
}

class PdfTtsScreen extends StatefulWidget {
  const PdfTtsScreen({super.key});

  @override
  State<PdfTtsScreen> createState() => _PdfTtsScreenState();
}

class _PdfTtsScreenState extends State<PdfTtsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  File? _pdfFile;
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;
  bool _isPlaying = false;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _pdfFile = file;
          _currentSentenceIndex = 0;
          _isPlaying = false;
        });
        
        // Extract text from PDF
        final bytes = await file.readAsBytes();
        final pdfDocument = sf.PdfDocument(inputBytes: bytes);
        String fullText = '';
        
        // Extract text from each page
        for (var i = 0; i < pdfDocument.pages.count; i++) {
          final page = pdfDocument.pages[i];
          final text = sf.PdfTextExtractor(pdfDocument).extractText(startPageIndex: i);
          fullText += text + ' ';
        }
        
        // Split text into sentences
        final sentences = _splitIntoSentences(fullText);
        
        setState(() {
          _sentences = sentences;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking PDF: $e')),
      );
    }
  }

  List<String> _splitIntoSentences(String text) {
    // Split text into sentences using common sentence endings
    final sentences = text
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim()
        .split(RegExp(r'(?<=[.!?])\s+')) // Split on sentence endings followed by whitespace
        .where((sentence) => sentence.trim().isNotEmpty) // Remove empty sentences
        .map((sentence) => sentence.trim()) // Trim whitespace
        .toList();
    
    return sentences;
  }

  Future<void> _goToPreviousSentence() async {
    if (_currentSentenceIndex > 0) {
      setState(() {
        _currentSentenceIndex--;
      });
      if (_isPlaying) {
        await _flutterTts.speak(_sentences[_currentSentenceIndex]);
      }
    }
  }

  Future<void> _goToNextSentence() async {
    if (_currentSentenceIndex < _sentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
      });
      if (_isPlaying) {
        await _flutterTts.speak(_sentences[_currentSentenceIndex]);
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_sentences.isEmpty) return;

    if (_isPlaying) {
      await _flutterTts.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_currentSentenceIndex >= _sentences.length) {
        _currentSentenceIndex = 0;
      }
      
      await _flutterTts.speak(_sentences[_currentSentenceIndex]);
      setState(() {
        _isPlaying = true;
      });
      
      // Move to next sentence when current one is done
      _flutterTts.setCompletionHandler(() async {
        if (_currentSentenceIndex < _sentences.length - 1) {
          setState(() {
            _currentSentenceIndex++;
          });
          // Automatically start reading the next sentence
          await _flutterTts.speak(_sentences[_currentSentenceIndex]);
        } else {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corax'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: _pickPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_pdfFile != null) ...[
            Expanded(
              child: SfPdfViewer.file(
                _pdfFile!,
                controller: _pdfViewerController,
                enableTextSelection: true,
                enableDoubleTapZooming: true,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDocumentLinkAnnotation: true,
                canShowPaginationDialog: true,
                canShowTextSelectionMenu: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _goToPreviousSentence,
                    tooltip: 'Previous sentence',
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _togglePlayPause,
                    tooltip: _isPlaying ? 'Pause' : 'Resume',
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: _goToNextSentence,
                    tooltip: 'Next sentence',
                  ),
                  if (_sentences.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Sentence ${_currentSentenceIndex + 1} of ${_sentences.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Text('Select a PDF file to begin'),
              ),
            ),
        ],
      ),
    );
  }
}
