import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

//Future<bool> checkVerified(context) async {
//  SharedPreferences pref = await SharedPreferences.getInstance();
//  var phone = await pref.get("verified_phone");
//  if (phone == null) {
//    return Navigator.of(context)
//        .push(MaterialPageRoute(builder: (context) => new PhoneVerif()));
//  } else {
//    return Navigator.of(context).push(MaterialPageRoute(
//        builder: (context) => new SignUp(
//          phone: phone,
//        )));
//  }
//}

Future<dynamic> checkLogin() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  var isLoggedIn = await pref.get('is_loggedIn') == null ? false : true;
  if(isLoggedIn == false){
    return isLoggedIn;
  }
  var type = await getUserType();
  var name = await getName();
  var email = await getEmail();
  var userId = await getUserId();
  var avatar = await getAvatar();
  var pw    = await getPw();
  var token = await getToken();
  return {'user_type':type,'email':email,'id':userId,'status':isLoggedIn,'name':name,'avatar':avatar,'pw':pw,'token':token};
}
Future<void> storeVCode(data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setInt('vcode', data['vcode']);
  pref.setInt('vuid',  data['id']);
}
Future<bool> getNotfStatus() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  var status = await pref.getBool('notf');
  if(status != true){
    return false;
  }
  return status;
}
Future<bool> setNotfStatus(bool status) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool('notf', status);
  return status;
}

Future<bool> verifyCode(code) async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  var vcode =  pref.getInt('vcode');
  if(vcode == int.parse(code)){
    return true;
  }
  return false;
}

Future<dynamic> getVCodeInfo() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  var vuid = pref.getInt('vuid');
  var vcode = pref.getInt('vcode');
  return {'vcode':vcode,'vuid':vuid};
}


Future<dynamic> userLogin(state) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool('is_loggedIn', true);
  pref.setBool('remember_me', state['remember_me']);
  pref.setString('user_type', state['type']);
  pref.setString('name', state['name']);
  pref.setString('avatar', state['avatar']);
  pref.setString('email', state['email']);
  pref.setString('phone', state['phone']);
  pref.setString('pw', state['pw']);
  pref.setString('token', state['access_token']);
  pref.setString('user_id', "${state['id']}");
}


Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('token');
}

Future<Map<String,dynamic>> xFirstTimexLogin() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
var nt = await pref.getBool('notFirstTime');
var lg = await  pref.getBool('is_loggedIn');
  var result ={'notFirstTime': nt,
              'isLoggedIn' : lg
  };
  return result;
}
Future<void> sFirstTime() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
   pref.setBool('notFirstTime',true);

}
Future<String> getPw() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('pw');
}

Future<String> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('user_id');
}
Future<String> getUserType() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('user_type');
}

Future<String> getPhone() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('user_id');
}
Future<String> getName() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('name');
}
Future<String> getAvatar() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('avatar');
}

Future<String> getEmail() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.get('email');
}



Future<dynamic> userLogout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
 await pref.remove('user_type');
 await pref.remove('is_loggedIn');
 bool rMe =  await pref.getBool('remember_me') ?? false;
 if(!rMe) {
   await pref.remove('email');
   await pref.remove('pw');
 }
  await pref.remove('user_id');
  await pref.remove('name');
  return true;
}
