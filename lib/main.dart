import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

void main() => runApp(const CameraApp());

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  bool _isLoading = false;
  String? _savedPath;
  final picker = ImagePicker();
  final List<String> _filters = ['Оригинал', 'Черно-белый', 'Сепия', 'Негатив'];
  String _selectedFilter = 'Оригинал';

  // Проверка и запрос разрешений
  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;
    
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!photosStatus.isGranted) {
      await Permission.photos.request();
    }
  }

  // Получение изображения
  Future<void> _getImage(ImageSource source) async {
    await _checkPermissions();
    
    setState(() => _isLoading = true);
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _savedPath = null;
        });
        _applyFilter();
      }
    } catch (e) {
      // Вместо print используем debugPrint для отладки
      debugPrint('Ошибка: $e');
      _showSnackBar('Ошибка при выборе изображения');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Сохранение изображения
  Future<void> _saveImage() async {
    if (_image == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_$timestamp.jpg';
      final newFile = await _image!.copy('${directory.path}/$fileName');
      
      setState(() {
        _savedPath = newFile.path;
      });
      
      _showSnackBar('Фото сохранено: $fileName');
    } catch (e) {
      // Вместо print используем debugPrint для отладки
      debugPrint('Ошибка сохранения: $e');
      _showSnackBar('Ошибка при сохранении');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Применение фильтров
  Future<void> _applyFilter() async {
    if (_image == null || _selectedFilter == 'Оригинал') return;
    
    setState(() => _isLoading = true);
    
    try {
      final bytes = await _image!.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image != null) {
        switch (_selectedFilter) {
          case 'Черно-белый':
            image = img.grayscale(image);
            break;
          case 'Сепия':
            image = img.sepia(image);
            break;
          case 'Негатив':
            image = img.invert(image);
            break;
        }
        
        final newBytes = img.encodeJpg(image);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(newBytes);
        
        setState(() => _image = tempFile);
      }
    } catch (e) {
      // Вместо print используем debugPrint для отладки
      debugPrint('Ошибка фильтра: $e');
      _showSnackBar('Ошибка при применении фильтра');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Показать уведомление
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Диалог подтверждения сохранения
  Future<void> _showSaveDialog() async {
    if (_image == null) return;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сохранение фото'),
        content: const Text('Сохранить фото в память устройства?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveImage();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Работа с камерой'),
        actions: [
          if (_savedPath != null)
            IconButton(
              onPressed: () => _showSnackBar('Фото сохранено по пути: $_savedPath'),
              icon: const Icon(Icons.info_outline),
              tooltip: 'Информация о сохранении',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Заголовок состояния
              Text(
                _image == null ? 'Фото не выбрано' : 'Выбранное фото',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              const SizedBox(height: 20),
              
              // Отображение изображения
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_image != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _image!,
                      width: min(MediaQuery.of(context).size.width * 0.9, 350),
                      height: min(MediaQuery.of(context).size.width * 0.9, 350),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.error, size: 50, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_camera, size: 80, color: Colors.grey),
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Панель фильтров
              if (_image != null) ...[
                Text(
                  'Фильтры',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filters.map((filter) {
                    return ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                          _applyFilter();
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
              
              // Кнопки управления
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _getImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Сделать фото'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _getImage(ImageSource.gallery),
                      icon: const Icon(Icons.image),
                      label: const Text('Выбрать из галереи'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  
                  if (_image != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showSaveDialog,
                        icon: const Icon(Icons.save),
                        label: const Text('Сохранить фото'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Информация о сохранении
              if (_savedPath != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Фото успешно сохранено!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _savedPath!.split('/').last,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Статус разрешений
              FutureBuilder(
                future: Future.wait([
                  Permission.camera.status,
                  Permission.photos.status,
                ]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final cameraStatus = snapshot.data![0];
                    final photosStatus = snapshot.data![1];
                    
                    return Column(
                      children: [
                        const Text(
                          'Статус разрешений:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cameraStatus.isGranted ? Icons.check_circle : Icons.error,
                              color: cameraStatus.isGranted ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            const Text('Камера'),
                            const SizedBox(width: 20),
                            Icon(
                              photosStatus.isGranted ? Icons.check_circle : Icons.error,
                              color: photosStatus.isGranted ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            const Text('Галерея'),
                          ],
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}