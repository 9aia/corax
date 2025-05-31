---
description: A high-level summary of the project.
---

# Project Overview

## Description

**Corax** is a simple, offline-first mobile app that enhances PDF reading with on-device text-to-speech (TTS) and synchronized text highlighting. Designed for focus and ease, it reads PDFs aloud while visually guiding the user through the text. With intuitive controls and no internet required, Corax offers a smooth, immersive reading experience anywhere.

## Goals

* **Enable Audio Access to PDFs**: Make e-books and documents more accessible by providing high-quality, on-device TTS playback.
* **Ensure Offline Usability**: Prioritize a fully functional offline experience, ideal for travel, limited connectivity, or focused reading.
* **Optimize for Mobile Simplicity**: Deliver a clean, distraction-free interface with essential controls for navigating and listening to PDFs, focusing on core features without complexity.

## Scope

Corax focuses on a tightly scoped feature set to ensure performance and reliability:

* **PDF File Support**: Import and play standard PDF e-books from local device storage.
* **TTS Playback**: Read aloud extracted text using the device's built-in TTS engine.
* **Offline First**: All features must work without requiring an internet connection.
* **Session Persistence**: Resume from last listened position per document.
* **Basic Playback Controls**: Play, pause, rewind, and jump to sections, jump to the next/previous page, via a minimalistic UI.
* **Voice Settings**: Choose between available system TTS voices and adjust playback speed or pitch.

**The project does not include:**

* **Cloud Sync or Backups**: No online syncing or account-based storage.
* **Third-Party TTS Integration**: Only uses system-native TTS engines (e.g., Android Speech Services).
* **Advanced PDF Features**: Does not support scanned PDFs, annotations, embedded audio, or DRM-protected content.
* **Library Management**: No bookshelf, tagging, or complex sorting — basic file-based access only.
* **Cross-Platform Sync**: No synchronization across devices.
* **Annotation or Highlighting**: The app does not offer in-text interaction features like notes or highlights.

## Requirements

To use Corax effectively, users will need:

* **Modern Smartphone**: Android (initial target) with minimum SDK support (e.g., API 26+)
* **Local PDFs**: Users must manually import or download their own PDF e-books.
* **Permissions**: File access permission is required to import and read PDFs.
* **TTS Engine Installed**: The app uses the device's native TTS engine; no bundled voice libraries.
