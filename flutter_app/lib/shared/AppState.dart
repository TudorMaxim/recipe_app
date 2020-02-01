import 'package:exam_app/domain/Entity.dart';
import 'package:exam_app/repository/Repository.dart';
import 'package:exam_app/service/HttpClient.dart';

class AppState {
  bool connected = false;
  bool isFetching = false;

  Repository repository = new Repository();
  HttpClient service = new HttpClient();
  List<Entity> items = new List();

  var subscription;
}