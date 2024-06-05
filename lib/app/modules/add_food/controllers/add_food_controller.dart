import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddFoodController extends GetxController {
  final image =
      XFile("").obs; //digunakan untuk menampung file gambar dari resep.

//reference ke firestore collection
  CollectionReference ref = FirebaseFirestore.instance.collection('Food');

//TextEditingController untuk setiap textfield
  TextEditingController namaController = TextEditingController();
  TextEditingController waktuPembuatanController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController resepController = TextEditingController();

//pilihan filter berdasarkan jenis
  final selectJenis = [
    "Makanan",
    "Minuman",
    "Kuah",
  ];

//variable untuk menampung filter yang dipilih
  final selectedJenis = "Makanan".obs;

//fungsi ini akan digunakan untuk mendapatkan gambar dari penyimpanan local handpone
  Future getImage(bool gallery) async {
    //deklarasikan picker
    ImagePicker picker = ImagePicker();
    XFile? pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await picker.pickImage(
        source: ImageSource.camera,
      );
    }
    //jika user memilih sebuah gambar maka pickedfile di assign kedalam image variable
    if (pickedFile != null) {
      image.value = pickedFile;
    }
  }

//method ini digunakan untuk mengupload file foto yang diambil ke dalam cloud_storage
//akan mengembalikan string berupa path dari foto yang diupload di cloud_storage
  Future<String> uploadFile(File image) async {
    final storageReference =
        FirebaseStorage.instance.ref().child('Menus/${image.path}');
    await storageReference.putFile(image);
    String returnURL = "";
    await storageReference.getDownloadURL().then(
      (fileURL) {
        returnURL = fileURL;
      },
    );
    return returnURL;
  }

//method ini digunakan untuk menyimpan resep dan mengupload gambar
  Future<void> saveImages(
    File images,
    String nama,
    int waktuPembuatan,
    String deskripsi,
    String jenis,
    String resep,
  ) async {
    //tampilkan loading indicator
    Get.bottomSheet(
      Container(
          height: 80,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              CircularProgressIndicator(),
              Text("Loading"),
            ],
          )),
    );
    //upload file ke cloud_storage dan simpan pada imageURL
    String imageURL = await uploadFile(images);
    final refDoc = ref.doc();
    //upload data resep ke dalam firestore dan simpan url gambar yang sudah diuplo
    final data = {
      "id": refDoc.id,
      "nama": nama,
      "deskripsi": deskripsi,
      "waktu_pembuatan": waktuPembuatan,
      "jenis": jenis,
      "resep": resep,
      "images": imageURL
    };
    refDoc.set(data);
    Get.back();
  }
}
