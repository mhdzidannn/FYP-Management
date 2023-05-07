class UserBaseDetail {
  final String? uid;

  UserBaseDetail({this.uid});
}

class UserGeneralInfo {
  List listOfUID = [];

  UserGeneralInfo({
    required this.listOfUID,
  });

  UserGeneralInfo.fromMapUser(Map<String, dynamic> data) {
    listOfUID = data['listOfUID'];
  }

  UserGeneralInfo.fromMapDealer(Map<String, dynamic> data) {
    listOfUID = data['listOfUID'];
  }
}
