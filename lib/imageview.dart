import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  File? _image;
  img.Image? _originalImage;
  img.Image? _equalizedImage;
  final TransformationController _transformationController =
  TransformationController();
  double _scaleFactor = 1.0;
// mo anh
  Future<void> _openImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _originalImage = img.decodeImage(_image!.readAsBytesSync());
        _equalizedImage = null;
        _scaleFactor = 1.0;
        _transformationController.value = Matrix4.identity();
      });
    }
  }
// can bang
  void _equalizeHistogram() {
    if (_originalImage != null) {
      img.Image equalized = img.Image(_originalImage!.width, _originalImage!.height); // tao 1 hinh anh moi
      for (int x = 0; x < _originalImage!.width; x++) {
        for (int y = 0; y < _originalImage!.height; y++) {
          int pixel = _originalImage!.getPixel(x, y); // lay mau diem anh
          //chuyen doi pixel sang thang do xam
          int gray = img.getLuminance(pixel);

          equalized.setPixel(x, y, img.getColor(gray, gray, gray));
        }
      }
      //cap nhap lai trang thai
      setState(() {
        _equalizedImage = equalized;
      });
    }
  }
// luu anh
  Future<void> _saveImage() async {
    if (_equalizedImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/equalized_image.png';
      print(imagePath);
      await File(imagePath).writeAsBytes(img.encodePng(_equalizedImage!));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu hình ảnh đã chỉnh sửa vào $imagePath')));
    }
  }
  // imagePath la duong dan /data/data/<your_app_package>/files/equalized_image.png


  // Future<void> _saveImageToGallery() async {
  //   if (_equalizedImage != null) {
  //     // Request permission for Android (required for accessing storage)
  //     if (Platform.isAndroid) {
  //       var status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Cần có quyền lưu trữ để lưu hình ảnh.')));
  //         return;
  //       }
  //     }
  //
  //     // Lưu ảnh vào thư viện
  //     final Uint8List imageData = Uint8List.fromList(img.encodePng(_equalizedImage!));
  //     final result = await ImageGallerySaver.saveImage(imageData, quality: 100, name: "equalized_image");
  //     print(result);
  //
  //     if (result['isSuccess']) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Đã lưu hình ảnh vào thư viện thành công!')));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Không lưu được hình ảnh vào thư viện.')));
  //     }
  //   }
  // }
  // phong to
  void _zoomIn() {
    setState(() {
      _scaleFactor *= 1.2;
      _applyZoom();
    });
  }
// thu nho
  void _zoomOut() {
    setState(() {
      _scaleFactor /= 1.2;
      _applyZoom();
    });
  }

  void _applyZoom() {
    _transformationController.value = Matrix4.identity()..scale(_scaleFactor);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Trình xem ảnh")),
      ),
      body: Center(
        child: _image == null
            ? Text('Không có hin ảnh nào được chọn.')
            : InteractiveViewer(
          transformationController: _transformationController,
          child: _equalizedImage != null
              ? Image.memory(Uint8List.fromList(img.encodePng(_equalizedImage!)))
              : Image.memory(File(_image!.path).readAsBytesSync()),
        ),
      ),
      floatingActionButton: PopupMenuButton<int>(
        icon: Icon(Icons.menu),
        onSelected: (value) {
          switch (value) {
            case 1:
              _openImage();
              break;
            case 2:
              _saveImage();
              break;
            case 3:
              _zoomIn();
              break;
            case 4:
              _zoomOut();
              break;
            case 5:
              _equalizeHistogram();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: ListTile(
              leading: Icon(Icons.add_photo_alternate),
              title: Text('Mở ảnh'),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: ListTile(
              leading: Icon(Icons.save),
              title: Text('Lưu ảnh'),
            ),
          ),
          PopupMenuItem(
            value: 3,
            child: ListTile(
              leading: Icon(Icons.zoom_in),
              title: Text('Phong to'),
            ),
          ),
          PopupMenuItem(
            value: 4,
            child: ListTile(
              leading: Icon(Icons.zoom_out),
              title: Text('Thu nhỏ'),
            ),
          ),
          PopupMenuItem(
            value: 5,
            child: ListTile(
              leading: Icon(Icons.equalizer),
              title: Text('Biểu đồ xám'),
            ),
          ),
        ],
      ),
    );
  }
}
