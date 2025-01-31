import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AddAnnouncement extends StatefulWidget {
  final user_data;
  final build_data;
  const AddAnnouncement({super.key, this.user_data, this.build_data});

  @override
  State<AddAnnouncement> createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  String? _fileUrl;
  bool _isLoading = false;
  double uploadProgress = 0.0;
  late Cloudinary cloudinary;

  @override
  void initState() {
    super.initState();
    // Initialize Cloudinary with your credentials
    cloudinary = Cloudinary.signedConfig(
      apiKey: dotenv.env['CloudinaryApiKey'] ?? "",
      apiSecret: dotenv.env['ColudinaryApiSecret'] ?? "",
      cloudName: dotenv.env['ColudinaryCloudName'] ?? "",
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> uploadFile() async {
    try {
      if (_selectedFile == null) {
        throw Exception('Please choose a file first');
      }

      final fileExtension = _selectedFile!.path.split('.').last.toLowerCase();
      final resourceType = (fileExtension == 'pdf')
          ? CloudinaryResourceType.raw
          : CloudinaryResourceType.image;

      final response = await cloudinary.upload(
          file: _selectedFile!.path,
          resourceType: resourceType,
          folder: "announcements",
          progressCallback: (count, total) {
            setState(() {
              uploadProgress = count / total;
            });
          });

      if (response.isSuccessful) {
        setState(() {
          _fileUrl = response.secureUrl;
          uploadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_selectedFile != null && _fileUrl == null) {
          await uploadFile();
        }

        String currentUser =
            '${widget.user_data['firstName']} ${widget.user_data['lastName']}';
        final fileExtension = _selectedFile?.path.split('.').last.toLowerCase();

        await FirebaseFirestore.instance
            .collection('buildings')
            .doc(widget.build_data.id)
            .collection('announcements')
            .add({
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'fileUrl': _fileUrl,
          'fileName': _selectedFile?.path.split('/').last,
          'fileType': fileExtension,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': currentUser,
          'createdByDesignation': widget.user_data[
              'designation'], // Map the designations accordingly as per the schema
          'createdById': widget.user_data.id.toString(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Create Announcement',
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                  const SizedBox(height: 40),
                  _buildInputField(
                    controller: _subjectController,
                    label: 'Subject',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 30),
                  _buildFilePicker(),
                  const SizedBox(height: 40),
                  Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitAnnouncement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE94560),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              shadowColor: Colors.black.withOpacity(0.5),
                              elevation: 10,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Post Announcement',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                icon: Icon(icon, color: const Color(0xFFE94560)),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attach Photo or PDF (Optional)",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file, color: Color(0xFFE94560)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedFile != null
                              ? _selectedFile!.path.split('/').last
                              : "Tap to select file",
                          style: TextStyle(
                            color: _selectedFile == null
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 10),
                if (_selectedFile!.path.endsWith('.pdf'))
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        _selectedFile!.path.split('/').last,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                else
                  Image.file(
                    _selectedFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
