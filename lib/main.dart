import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
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
        setState(() {
          _pdfFile = File(result.files.single.path!);
          _currentSentenceIndex = 0;
          _isPlaying = false;
        });
        // TODO: Extract text from PDF and split into sentences
        // This would require additional PDF parsing logic
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking PDF: $e')),
      );
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
        title: const Text('PDF Reader with TTS'),
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
              child: SfPdfViewer.file(_pdfFile!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _togglePlayPause,
                  ),
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
