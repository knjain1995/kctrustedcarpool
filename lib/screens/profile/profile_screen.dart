import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../cloud_functions/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _firestoreService = FirestoreService();

  TextEditingController _nameController = TextEditingController();
  String? profileImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    DocumentSnapshot? userDoc = await _firestoreService.getUserProfile();
    
    if (userDoc != null && userDoc.exists) {
      setState(() {
        _nameController.text = userDoc["name"] ?? "";
        profileImageUrl = userDoc["profileUrl"] ?? "";
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    setState(() => isLoading = true);
    await _firestoreService.saveUserProfile(
      _nameController.text,
      _auth.currentUser?.email ?? "",
      profileImageUrl,
    );
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String userId = _auth.currentUser?.uid ?? "unknown_user";

    Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() => profileImageUrl = downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}
