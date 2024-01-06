import 'dart:convert';
import 'package:flutter_drawing_board/stable_api/api_endpoint.dart';
import 'package:http/http.dart' as http;

// ignore: constant_identifier_names
const API_OPTIONS_ENDPOINT = "sdapi/v1/options";

String? currentModel;

Future<String> getSDModel() async {
  if (currentModel != null) {
    return currentModel!;
  }

  const url = API_ENDPOINT + API_OPTIONS_ENDPOINT;

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add any other headers if needed
      },
    );

    if (response.statusCode == 200) {
      // retrieve the model from the body
      final body = jsonDecode(response.body);
      final model = body['sd_model_checkpoint'];

      // update the currentModel variable cache and return the model to the user
      currentModel = model;
      return model;
    } else {
      // Handle error response
      print('Failed to make POST request. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error during POST request: $error');
  }

  return "";
}

Future<bool> changeSDModel(String model) async {
  // if the current model is the one we want to change to then return true
  final actualModel = await getSDModel();
  if (actualModel == model) {
    return true;
  }

  const url = API_ENDPOINT + API_OPTIONS_ENDPOINT;

  Map<String, dynamic> body = {
    'sd_model_checkpoint': model,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add any other headers if needed
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error response
      print('Failed to make POST request. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error during POST request: $error');
  }

  return false;
}
