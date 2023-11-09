import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: constant_identifier_names
const APP_NAME = "Big Eye";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> copyFile(File sourceFile, String newPath) async {
    return await sourceFile.copy(newPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(APP_NAME),
        actions: [
          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationVersion: '1.0.0',
                applicationName: APP_NAME,
                children: [
                  SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text:
                                "This application is designed with the primary goal of preserving the rich narratives shared on WhatsApp. Created solely for educational purposes, it holds no commercial intent. The app operates entirely offline, ensuring that all data remains securely within your device. Our commitment to user privacy and safety is unwavering. We encourage you to thoroughly review our Terms & Conditions, which are accessible via this ",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'link',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                    Uri.parse(
                                        'https://koda-christian.github.io/bigeye'),
                                    mode: LaunchMode.inAppBrowserView,
                                  ),
                          ),
                          const TextSpan(
                            text:
                                ". This document provides a detailed overview of our practices and your rights as a user. By using our app, you agree to abide by these terms and conditions. We believe transparency is key in building trust, and we are committed to maintaining open and clear communication with our users.",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome to the Big Eye app.\nTo start saving WhatsApp stories, please click the button bellow.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(3.0),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  bool permGranted =
                      await Permission.manageExternalStorage.isGranted;
                  if (!permGranted) {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Access to Files"),
                          content: SingleChildScrollView(
                            child: const Text(
                                "This application does not collect, share, or transmit any personal information. It does not use any third-party services or networks. The app requires access to all files on your device to perform its core functionality, which is to save WhatsApp stories. This access is strictly limited to the app's functionality and is not used for any other purposes. The app does not create any accounts and does not store any data on your device. By granting this permission, you are allowing the app to copy files from WhatsApp folder to a folder named 'Big Eye Stories'. No other permissions are requested or used by this app. By using this app, you agree to its terms and conditions. Please, click the informations icon to read the terms and conditions."),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                permGranted = await Permission
                                    .manageExternalStorage
                                    .request()
                                    .isGranted;
                                Navigator.pop(context);
                              },
                              child: const Text("Allow access"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  if (permGranted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        content: Center(
                          child: Text(
                            "Saving...",
                            style:
                                TextStyle(color: Colors.yellow, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                    final Directory sourceDir = Directory(
                        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/');
                    final Directory targetDir =
                        Directory('/storage/emulated/0/$APP_NAME Stories/');
                    if (sourceDir.existsSync()) {
                      if (!targetDir.existsSync()) {
                        targetDir.createSync(recursive: true);
                      }
                      final List<FileSystemEntity> files = sourceDir.listSync();
                      for (final file in files) {
                        if (!path.basename(file.path).startsWith('.')) {
                          await copyFile(File(file.path),
                              '${targetDir.path}/${path.basename(file.path)}');
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          content: Center(
                            child: Text(
                              "🎉 Stories saved ! Please check your gallery.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                          content: Center(
                            child: Text(
                              "Sorry, we could not find WhatsApp content at the usual folder: /storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/ .",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        content: Center(
                          child: Text(
                            "Please, allow the app to access files to process.",
                            style:
                                TextStyle(color: Colors.yellow, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Save stories",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
