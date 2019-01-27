import 'dart:async' show Future;
import '../models/check_credentials.dart';
import '../models/check_in.dart';
import '../models/event_essentials.dart';
import '../models/ticket_checkins.dart';
import '../models/tickets_info.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../utils/rounded_dialogs.dart';
import '../utils/extensions.dart';
import '../utils/colors.dart';


void _showAlert(BuildContext context, String title, String body) {

  showDialog( context: context,
      builder: (context) => CustomAlertDialog(
        title: Text(title, textAlign: TextAlign.center,),
        content: Text(body, textAlign: TextAlign.center,),
        actions: <Widget>[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('CLOSE', style: textStyle(kColor_green_theme, FontWeight.normal, 14),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          ),
        ],
      )
  );
}


Future<CheckCredentials> checkCredential(String url, BuildContext context) async {
  print("url got ${url}");
  if(url == '') {
    return null;
  }
  try{
    final response = await http.get(url);
    if(response.statusCode == 200){
      return checkCredentialsFromJson(response.body);
    } else{
      _showAlert(context, 'Error', 'Internal Error Occured');
      return null;
    }
  } catch (e){
    _showAlert(context, 'Error', e.toString());
    return null;
  }
}

Future<EventEssentials> eventEssentials(String url, BuildContext context) async {
  print("url got ${url}");
  if(url == '') {
    return null;
  }
  try{
    final response = await http.get(url);
    if(response.statusCode == 200){
      return eventEssentialsFromJson(response.body);
    } else{
      _showAlert(context, 'Error', 'Internal Error Occured');
      return null;
    }
  } catch (e){
    _showAlert(context, 'Error', e.toString());
    return null;
  }
}

Future<List<TicketCheckins>> ticketCheckins(String url, BuildContext context) async {
  print("url got ${url}");
  if(url == '') {
    return null;
  }
  try{
    final response = await http.get(url);
    if(response.statusCode == 200){
      return ticketCheckinsFromJson(response.body);
    } else{
      _showAlert(context, 'Error', 'Internal Error Occured');
      return null;
    }
  } catch (e){
    _showAlert(context, 'Error',  e.toString());
    return null;
  }
}

Future<List<TicketInfo>> ticketInfo(String url, BuildContext context) async {
  print("url got ${url}");
  if(url == '') {
    return null;
  }
  try{
    final response = await http.get(url);
    if(response.statusCode == 200){
      return ticketInfoFromJson(response.body);
    } else{
      _showAlert(context, 'Error', 'Internal Error Occured');
      return null;
    }
  } catch (e){
    _showAlert(context, 'Error',  e.toString());
    return null;
  }

}

Future<CheckIn> checkIn(String url, BuildContext context) async {
  print("url got ${url}");
  if(url == '') {
    return null;
  }
  try{
    final response = await http.get(url);
    if (response.body == 'Ticket existiert nicht'){
      _showAlert(context, 'Info', 'Ticket existiert nicht');
      return null;
    } else if(response.statusCode != 200){
      _showAlert(context, 'Error', 'Internal Error Occured');
      return null;
    } else{
      return checkInFromJson(response.body);
    }
  } catch (e){
    _showAlert(context, 'Error',  e.toString());
    return null;
  }
}
