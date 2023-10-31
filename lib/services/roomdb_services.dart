import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquizapp/Model/RoomModel.dart';

class RoomdbServices {
  Future<DocumentReference?> addRoom(RoomModel room) async {
    final roomCollection = FirebaseFirestore.instance.collection('room');

    try {
      // Add the room to Firestore and return the DocumentReference
      DocumentReference docRef = await roomCollection.add(room.toMap());
      return docRef;
    } catch (e) {
      print('Error adding item: $e');
      return null;
    }
  }

  Future<void> updateRoom(RoomModel room, roomId) async {
    final roomCollection = FirebaseFirestore.instance.collection('room');

    try {
      QuerySnapshot querySnapshot = await roomCollection.get();

      for (var doc in querySnapshot.docs) {
        // Update each document that matches the condition
        final rooom = RoomModel(
            currentUserid: room.currentUserid,
            opponentUserid: room.opponentUserid,
            currentuserCorrect: room.currentuserCorrect,
            currentuserWrong: room.currentuserWrong,
            opponentuserCorrect: room.opponentuserCorrect,
            opponentuserWrong: room.opponentuserWrong,
            opponentname: room.opponentname,
            currentname: room.currentname);
        log(rooom.toString());
        roomCollection.doc(roomId).update(rooom.toMap());
      }
    } catch (e) {
      print('Error updating items: $e');
    }
  }

  Stream<RoomModel?> streamRoomDataById(String documentId) {
    final roomCollection = FirebaseFirestore.instance.collection('room');

    return roomCollection.doc(documentId).snapshots().map((roomSnapshot) {
      if (roomSnapshot.exists) {
        // Convert the document data to a RoomModel object using the toMap method
        return RoomModel.fromMap(roomSnapshot.data() as Map<String, dynamic>);
      } else {
        // Document with the specified documentId was not found
        return null;
      }
    });
  }
}
