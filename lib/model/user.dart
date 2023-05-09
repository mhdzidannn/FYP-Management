class UserBaseDetail {
  final String? uid;

  UserBaseDetail({this.uid});
}

class UserGeneralInfo {
  late List listOfUID;

  UserGeneralInfo({
    required this.listOfUID,
  });

  UserGeneralInfo.fromMapUser(Map<String, dynamic>? data) {
    listOfUID = data?['UID'];
  }

  UserGeneralInfo.fromMapDealer(Map<String, dynamic>? data) {
    listOfUID = data?['UID'];
  }
}
