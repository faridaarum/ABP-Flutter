import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TakeFotoPenilaianPage extends StatefulWidget {
  const TakeFotoPenilaianPage({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<TakeFotoPenilaianPage> {
  CameraController? cameraController;
  List? cameras;
  int? selectedCameraIndex;

  @override
  void initState() {
    super.initState();

    availableCameras().then((value) {
      cameras = value;
      if (cameras!.isNotEmpty) {
        selectedCameraIndex = 0;
        initCamera(cameras![selectedCameraIndex!]).then((_) {});
      } else {
        debugPrint("Tidak ada kamera");
      }
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initCamera(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController!.dispose();
    }

    cameraController = CameraController(cameraDescription, ResolutionPreset.high);
    cameraController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (cameraController!.value.hasError) {
      debugPrint("Kamera Error");
    }

    try {
      await cameraController!.initialize();
    } catch (e) {
      debugPrint("kamera error $e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE5E5E5),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: Text(
          'Tambah Bukti Foto',
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_sharp,
            size: 30,
            color: Color.fromARGB(255, 24, 79, 199),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            cameraPreview(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        height: 160,
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // backButton(),

            cameraControl(context),

            // cameraToogle(),
          ],
        ),
      ),
    );
  }

  Widget backButton() {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () {},
      child: const Icon(Icons.chevron_left),
      backgroundColor: Colors.black,
    );
  }

  Widget cameraPreview() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Text("Loading ..");
    }
    /*return MaterialApp(
      home: CameraPreview(cameraController!),
    );*/
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * cameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    final double mirror = selectedCameraIndex == 1 ? math.pi : 0;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(mirror),
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(cameraController!),
        ),
      ),
    );
  }

  Widget cameraToogle() {
    if (cameras == null || cameras!.isEmpty) {
      return const Spacer();
    }

    CameraDescription selectedCamera = cameras![selectedCameraIndex!];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
        child: Align(
      alignment: Alignment.center,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          onSwitchCamera();
        },
        child: Icon(getCameraLensIcon(lensDirection), color: Colors.white, size: 24),
        backgroundColor: Colors.blue,
      ),
    ));
  }

  Widget cameraControl(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            onCapture(context);
          },
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 10,
                color: Color.fromARGB(255, 24, 79, 199),
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Icon(Icons.camera),
            ),
          ),
        ),
      ),
    );
  }

  getCameraLensIcon(lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return CupertinoIcons.photo_camera;
      default:
        return Icons.device_unknown;
    }
  }

  onSwitchCamera() {
    selectedCameraIndex = selectedCameraIndex! < cameras!.length - 1 ? selectedCameraIndex! + 1 : 0;
    CameraDescription selectedCamera = cameras![selectedCameraIndex!];
    initCamera(selectedCamera);
  }

  onCapture(context) async {
    try {
      await cameraController!.takePicture().then((value) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => PreviewScreen(
        //       imgFile: File(value.path),
        //     ),
        //   ),
        // );
      });
    } catch (e) {
      debugPrint('error $e');
    }
  }
}
