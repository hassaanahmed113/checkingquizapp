import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterquizapp/Model/OpponentModel.dart';
import 'package:flutterquizapp/Model/RoomModel.dart';
import 'package:flutterquizapp/Provider/quiz_provider.dart';
import 'package:flutterquizapp/Utils/app_colors.dart';
import 'package:flutterquizapp/Utils/custom_widgets.dart';
import 'package:flutterquizapp/result_screen.dart';
import 'package:flutterquizapp/services/db_services.dart';
import 'package:flutterquizapp/services/dbuser_services.dart';
import 'package:flutterquizapp/services/firebaseauth_services.dart';
import 'package:flutterquizapp/services/roomdb_services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CustomWidget cus = CustomWidget();
  DBServices db = DBServices();
  int value = 0;
  DbuserServices dbopponent = DbuserServices();
  RoomdbServices roomDb = RoomdbServices();
  final user = FirebaseAuth.instance.currentUser;
  String roomId = '';
  String useropponentId = '';
  String useropponentName = '';
  String currentname = '';
  late Future<void> roomInitialization;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomInitialization = _initializeRoom();
  }

  Future<void> _initializeRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      final roomId1 = userSnapshot['roomId'];

      if (roomId1 != null && roomId1.isNotEmpty) {
        setState(() {
          roomId = roomId1;
        });
      } else {
        // If a room doesn't exist for the user, create a new room
        RoomModel newRoom = RoomModel(
          currentUserid: user.uid,
          opponentUserid: dbopponent.opponentId,
          currentuserCorrect: dbopponent.currentusercorrect,
          currentuserWrong: dbopponent.currentuserwrong,
          opponentuserCorrect: dbopponent.opponentcorrect,
          opponentuserWrong: dbopponent.opponentwrong,
          opponentname: useropponentName,
          currentname: '',
        );
        DocumentReference? roomRef = await RoomdbServices().addRoom(newRoom);

        if (roomRef != null) {
          setState(() {
            roomId = roomRef.id;
          });
          print('Room ID: $roomId');
        } else {
          print('Error adding the room.');
        }
      }
    }
  }

  Future<void> updateOpponentRoomId(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      final roomId1 = userSnapshot['roomId'];

      if (roomId1 != null && roomId1.isNotEmpty) {
        final pro = Provider.of<QuizProvider>(context, listen: false);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();
        currentname = userSnapshot['name'];

        roomDb.updateRoom(
            RoomModel(
                currentUserid: user.uid,
                opponentUserid: useropponentId,
                currentuserCorrect: pro.correct,
                currentuserWrong: pro.wrong,
                opponentuserCorrect: dbopponent.opponentcorrect,
                opponentuserWrong: dbopponent.opponentwrong,
                opponentname: useropponentName,
                currentname: currentname),
            roomId);
      } else {
        // Query for users who are not the current user
        QuerySnapshot usersQuery = await FirebaseFirestore.instance
            .collection('user')
            .where('id', isNotEqualTo: user.uid)
            .get();

        for (QueryDocumentSnapshot userDoc in usersQuery.docs) {
          useropponentName = userDoc['name'];
          useropponentId = userDoc['id'];

          // Update each user's roomId
          await FirebaseFirestore.instance
              .collection('user')
              .doc(userDoc.id)
              .update({
            'roomId': roomId,
          });
        }
        final pro = Provider.of<QuizProvider>(context, listen: false);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();
        currentname = userSnapshot['name'];

        roomDb.updateRoom(
            RoomModel(
                currentUserid: user.uid,
                opponentUserid: useropponentId,
                currentuserCorrect: pro.correct,
                currentuserWrong: pro.wrong,
                opponentuserCorrect: dbopponent.opponentcorrect,
                opponentuserWrong: dbopponent.opponentwrong,
                opponentname: useropponentName,
                currentname: currentname),
            roomId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return value - 1 != 2
        ? Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: cus.textCus(
                  "QUIZ APP", 23, FontWeight.bold, AppColor().textColor),
              actions: [
                Consumer<FirebaseServicesProvider>(
                  builder: (context, firebaseprovider, child) {
                    return Consumer<QuizProvider>(
                      builder: (context, quizProvider, child) {
                        return IconButton(
                            onPressed: () {
                              firebaseprovider.signoutFunction(context);

                              quizProvider.answers.clear();
                              quizProvider.providedanswers.clear();
                              quizProvider.correct = 0;
                              quizProvider.wrong = 0;

                              final user = FirebaseAuth.instance.currentUser;

                              FirebaseFirestore.instance
                                  .collection("user")
                                  .doc(user!.uid)
                                  .update({'correct': 0, 'wrong': 0});
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ));
                      },
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      child: FutureBuilder<void>(
                        future: roomInitialization,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // Room has been initialized, you can join it now
                            updateOpponentRoomId(roomId);
                            return const CircularProgressIndicator(
                              color: Colors.transparent,
                            );
                          } else if (snapshot.hasError) {
                            // Handle initialization error
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Waiting for initialization to complete
                            return const CircularProgressIndicator(
                              color: Colors.transparent,
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                        height: 100,
                        child: StreamBuilder<RoomModel?>(
                          stream: roomId.isNotEmpty
                              ? roomDb.streamRoomDataById(roomId)
                              : null,
                          builder: (context, snapshot) {
                            if (!roomId.isNotEmpty) {
                              // Handle the case where roomId is not set yet
                              return const CircularProgressIndicator(
                                color: Colors.transparent,
                              );
                            }

                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              final room = snapshot.data;

                              if (room == null) {
                                return const Text('Document not found');
                              }

                              // Use the room data as needed
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  cus.textCus(
                                      "Opponent: ${room.opponentname} ",
                                      20,
                                      FontWeight.bold,
                                      AppColor().blackColor),
                                  cus.textCus("Correct: ", 20, FontWeight.bold,
                                      AppColor().blackColor),
                                  cus.textCus("${room.opponentuserCorrect}", 20,
                                      FontWeight.bold, AppColor().correctColor),
                                  cus.textCus(" Wrong: ", 20, FontWeight.bold,
                                      AppColor().blackColor),
                                  cus.textCus("${room.opponentuserWrong}", 20,
                                      FontWeight.bold, AppColor().wrongColor)
                                ],
                              );
                            }

                            return const CircularProgressIndicator(
                              color: Colors.transparent,
                            );
                          },
                        )),
                    cus.sizeboxCus(30),
                    StreamBuilder<List<QuestionModel>>(
                        stream: db.getItems(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No items found.');
                          }
                          return Expanded(
                              flex: 1,
                              child: Consumer<QuizProvider>(
                                  builder: (context, quizprovider, child) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    final item = snapshot.data![0 + value];
                                    quizprovider.providedanswers
                                        .add(item.answer);

                                    final item1 = item.option.length;
                                    return Column(
                                      children: [
                                        Text(
                                            "Question ${value + 1}: ${item.question}"),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: item1,
                                          itemBuilder: (context, index) {
                                            final item2 = item.option[index];
                                            return Column(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      quizprovider
                                                          .valueChange();
                                                      quizprovider.answers.add(
                                                          item.option[index]);

                                                      quizprovider
                                                          .calculateResult(
                                                              value + 0);
                                                      value += 1;
                                                      final user = FirebaseAuth
                                                          .instance.currentUser;

                                                      FirebaseFirestore.instance
                                                          .collection("user")
                                                          .doc(user!.uid)
                                                          .update({
                                                        'totalSelectedAnswer':
                                                            value + 0,
                                                      });

                                                      roomDb.updateRoom(
                                                          RoomModel(
                                                              currentUserid:
                                                                  user.uid,
                                                              opponentUserid:
                                                                  useropponentId,
                                                              currentuserCorrect:
                                                                  quizprovider
                                                                      .correct,
                                                              currentuserWrong:
                                                                  quizprovider
                                                                      .wrong,
                                                              opponentuserCorrect:
                                                                  dbopponent
                                                                      .opponentcorrect,
                                                              opponentuserWrong:
                                                                  dbopponent
                                                                      .opponentwrong,
                                                              opponentname:
                                                                  useropponentName,
                                                              currentname:
                                                                  currentname),
                                                          roomId);

                                                      setState(() {});
                                                    },
                                                    child: Text(
                                                        "${index + 1}: $item2")),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }));
                        }),
                  ]),
            ),
          )
        : ResultScreen(roomId);
  }
}
