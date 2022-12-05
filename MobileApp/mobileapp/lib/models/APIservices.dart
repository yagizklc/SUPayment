import "package:http/http.dart" as http;
import "dart:convert" as convert;
class APIservices{
  static Uri projectURL = Uri.parse("http://192.168.56.1:5000/Project/Get");
  static Future fetchProjects() async {
    return await http.get(projectURL);
  }

}