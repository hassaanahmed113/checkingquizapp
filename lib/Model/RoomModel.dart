class RoomModel {
  String currentUserid;
  String opponentUserid;
  int currentuserCorrect;
  int currentuserWrong;
  int opponentuserCorrect;
  int opponentuserWrong;
  String opponentname;
  String currentname;

  RoomModel({
    required this.currentUserid,
    required this.opponentUserid,
    required this.currentuserCorrect,
    required this.currentuserWrong,
    required this.opponentuserCorrect,
    required this.opponentuserWrong,
    required this.opponentname,
    required this.currentname,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentUserid': currentUserid,
      'opponentUserid': opponentUserid,
      'currentuserCorrect': currentuserCorrect,
      'currentuserWrong': currentuserWrong,
      'opponentuserCorrect': opponentuserCorrect,
      'opponentuserWrong': opponentuserWrong,
      'opponentname': opponentname,
      'currentname': currentname
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> json) => RoomModel(
        currentUserid: json["currentUserid"],
        opponentUserid: json["opponentUserid"],
        currentuserCorrect: json["currentuserCorrect"],
        currentuserWrong: json["currentuserWrong"],
        opponentuserCorrect: json["opponentuserCorrect"],
        opponentuserWrong: json["opponentuserWrong"],
        opponentname: json["opponentname"],
        currentname: json["currentname"],
      );
}
