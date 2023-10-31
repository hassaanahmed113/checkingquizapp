import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterquizapp/Model/OpponentModel.dart';
import 'package:flutterquizapp/Model/RoomModel.dart';
import 'package:flutterquizapp/Model/user_model.dart';
import 'package:flutterquizapp/Provider/quiz_provider.dart';
import 'package:flutterquizapp/Utils/app_colors.dart';
import 'package:flutterquizapp/Utils/custom_widgets.dart';
import 'package:flutterquizapp/services/dbuser_services.dart';
import 'package:flutterquizapp/services/firebaseauth_services.dart';
import 'package:flutterquizapp/services/roomdb_services.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  String roomId;
  ResultScreen(this.roomId, {super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  CustomWidget cus = CustomWidget();
  DbuserServices dbopponent = DbuserServices();
  RoomdbServices roomDb = RoomdbServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                            .update({
                          'correct': 0,
                          'wrong': 0,
                          'totalSelectedAnswer': 0
                        });
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: // In your ResultScreen widget
            StreamBuilder<num>(
          stream: dbopponent
              .getTotalSelectedOpponentStream(), // Create a new stream getter in DbuserServices
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.blue);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final totalSelectedOpponent = snapshot.data ?? 0;

              if (totalSelectedOpponent < 3) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Wair opponent result in progress"),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    ],
                  ),
                );
              } else {
                // Your existing code for showing the opponent details
                return Consumer<QuizProvider>(
                  builder: (context, providerquiz, child) {
                    return Consumer<QuizProvider>(
                      builder: (context, providerquiz, child) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Wrap(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 400,
                                  child: Column(
                                    children: [
                                      StreamBuilder<RoomModel?>(
                                        stream: widget.roomId.isNotEmpty
                                            ? roomDb.streamRoomDataById(
                                                widget.roomId)
                                            : null,
                                        builder: (context, snapshot) {
                                          if (!widget.roomId.isNotEmpty) {
                                            // Handle the case where roomId is not set yet
                                            return const CircularProgressIndicator(
                                              color: Colors.transparent,
                                            );
                                          }

                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }

                                          if (snapshot.connectionState ==
                                              ConnectionState.active) {
                                            final room = snapshot.data;

                                            if (room == null) {
                                              return const Text(
                                                  'Document not found');
                                            }

                                            // Use the room data as needed
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                cus.textCus(
                                                    "Opponent: ${room.currentname} ",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().blackColor),
                                                cus.textCus(
                                                    "Correct: ",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().blackColor),
                                                cus.textCus(
                                                    "${room.currentuserCorrect}",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().correctColor),
                                                cus.textCus(
                                                    " Wrong: ",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().blackColor),
                                                cus.textCus(
                                                    "${room.currentuserWrong}",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().wrongColor)
                                              ],
                                            );
                                          }

                                          return const CircularProgressIndicator(
                                            color: Colors.transparent,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 400,
                                  child: Column(
                                    children: [
                                      StreamBuilder<RoomModel?>(
                                        stream: widget.roomId.isNotEmpty
                                            ? roomDb.streamRoomDataById(
                                                widget.roomId)
                                            : null,
                                        builder: (context, snapshot) {
                                          if (!widget.roomId.isNotEmpty) {
                                            // Handle the case where roomId is not set yet
                                            return const CircularProgressIndicator(
                                              color: Colors.transparent,
                                            );
                                          }

                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }

                                          if (snapshot.connectionState ==
                                              ConnectionState.active) {
                                            final room = snapshot.data;

                                            if (room == null) {
                                              return const Text(
                                                  'Document not found');
                                            }

                                            // Use the room data as needed
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                cus.textCus(
                                                    "Opponent: ${room.opponentname} ",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().blackColor),
                                                cus.textCus(
                                                    "Correct: ",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().blackColor),
                                                cus.textCus(
                                                    "${room.opponentuserCorrect}",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().correctColor),
                                                cus.textCus(
                                                    " Wrong: ",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().blackColor),
                                                cus.textCus(
                                                    "${room.opponentuserWrong}",
                                                    20,
                                                    FontWeight.bold,
                                                    AppColor().wrongColor)
                                              ],
                                            );
                                          }

                                          return const CircularProgressIndicator(
                                            color: Colors.transparent,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }
            }
          },
        ));
  }
}
