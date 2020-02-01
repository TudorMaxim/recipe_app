import 'dart:convert';
import 'dart:io';
import 'package:exam_app/domain/Entity.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  String url = 'http://10.0.2.2:2201';

  getAll(String type) async {
    var response = await http.get('$url/recipes/$type',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        }
    );
    logRequest("GET", "$url/recipes/$type", response.statusCode);

    List <Entity> items = List();
    var body = json.decode(response.body);
    body.forEach((item) => items.add(Entity.fromMap(item)));

    return {
      'status': response.statusCode,
      'body': items
    };
  }

  getTypes() async {
    var response = await http.get('$url/types',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        }
    );
    logRequest("GET", "$url/types", response.statusCode);

    List <String> items = List();
    var body = json.decode(response.body);

//    body.forEach((item) => items.add(item.toString()));
//    items = body;

    return {
      'status': response.statusCode,
      'body': body
    };
  }

  getLow() async {
    var response = await http.get('$url/low',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        }
    );
    logRequest("GET", "$url/low", response.statusCode);

    List <Entity> items = List();
    var body = json.decode(response.body);
    body.forEach((item) => items.add(Entity.fromMap(item)));

    return {
      'status': response.statusCode,
      'body': items
    };
  }

  rate(Entity recipe) async {
    String id = recipe.id.toString();
    var response = await http.post('$url/increment',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: json.encode({'id': id})
    );
    logRequest("POST", "$url/increment", response.statusCode);

    return {
      'status': response.statusCode,
      'body': json.decode(response.body)
    };
  }

  add(Entity item) async {
    var response = await http.post('$url/recipe',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: json.encode(item.toMap())
    );
    logRequest("POST", "$url/recipe", response.statusCode);

    return {
      'status': response.statusCode,
      'body': json.decode(response.body)
    };
  }

  delete(int itemId) async {
    String id = itemId.toString();
    var response = await http.delete('$url/recipe/$id');
    logRequest("DELETE", "$url/product/$id", response.statusCode);

    return {
      'status': response.statusCode,
      'body': json.decode(response.body)
    };
  }

  update(Entity item) async {
    String id = item.id.toString();
    var response = await http.patch('$url/product/$id',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: json.encode(item.toMap())
    );
    logRequest("PATCH", "$url/product/$id", response.statusCode);

    return {
      'status': response.statusCode,
      'body': json.decode(response.body)
    };
  }

  logRequest(String method, String route, int status) {
    //var body = new JsonEncoder.withIndent("    ").convert(responseBody);
    print("$method on $route: $status");
//    print("Body: ");
    //print(body);
  }
}