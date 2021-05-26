import 'dart:developer';
import 'package:BloomZon/UI/LoginOrSignup/Signup.dart';
import 'package:BloomZon/bloc/browser/browser_cubit.dart';
import 'package:BloomZon/constant/constant.dart';
import 'package:BloomZon/helpers/authhelper.dart';
import 'package:BloomZon/utils/DxNetwork.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'LoginOrSignup/Login.dart';


class BzWebView extends StatefulWidget {

  final data; //expect subscription model for this WebView

  BzWebView({this.data});
  @override
  _BzWebViewState createState() => _BzWebViewState();
}

class _BzWebViewState extends State<BzWebView> {
  InAppWebViewController _webViewController;
  int currentIndex = 0;
  DateTime currentBackPressTime;
  double progress = 0;
  Codec<String, String> stringToB64 = utf8.fuse(base64); //instantiate the encoder
  bool isLoading;
  var _logged;
  BrowserCubit bwCubit = new BrowserCubit(0);
  void getLogStatus() async {
   var  data = await checkLogin();
    setState(() {
      _logged = data;
    });
   bwCubit.setState(1);
  }
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getLogStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: WillPopScope(child: BlocBuilder(
        cubit: bwCubit,
        builder: (context,state){
          if(state == 1) {
            var params = '';
            if(_logged != null && _logged != false){
                params =  "&mdxEmail=${_logged['email']}&mdxPw=${_logged['pw']}";
              }
            return Stack(
              children: <Widget>[
                InAppWebView(
                  initialUrl: "${widget
                      .data['url']}&xmd=a103650ce9d64de3bc4df68a3df53e418617fc39$params",
                  // shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
                  //   if(Platform.isAndroid || shouldOverrideUrlLoadingRequest.iosWKNavigationType == IOSWKNavigationType.LINK_ACTIVATED)
                  //   {
                  //     controller.loadUrl(url: shouldOverrideUrlLoadingRequest.url, headers: {"Authorization":"Bearer $token}"});
                  //     return ShouldOverrideUrlLoadingAction.CANCEL;
                  //   }
                  //   return ShouldOverrideUrlLoadingAction.ALLOW;
                  // },

                  initialOptions: InAppWebViewGroupOptions(

                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    _webViewController = controller;
                    loading(true);
                    if (url == "${DxNet.baseUrl}users/login" ||
                        url == "${DxNet.baseUrl}login") {
                      // _webViewController.goBack();
                      userLogout().then((value) =>
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => new loginScreen()))
                      ); //go back to homepage

                    }
                    if (url == "${DxNet.baseUrl}users/registration" ||
                        url == "${DxNet.baseUrl}registration") {
                      // _webViewController.goBack();
                      userLogout().then((value) =>
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => new Signup()))
                      ); //go back to homepage

                    }
                  },
                  onLoadStop: (InAppWebViewController controller,
                      String url) async {
                    loading(false);
                  },
                  onProgressChanged: (InAppWebViewController controller,
                      int progress) {

                  },


                ),
                isLoading == true ? Constant.bzLoaderDefault : Container()

              ],
            );
          }
          return Center(child: Constant.bzLoaderDefault);
        },
      ),
          onWillPop: () async {
       var backStatus = goBackUrl();
       if(backStatus == true){
         exit(0);
       }
       return false;

      } ),


      appBar: AppBar(
        backgroundColor: Constant.whiteColor,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        title: InkWell(
          onTap: () => ()=>{
            _webViewController.loadUrl(url: "${DxNet.baseUrl}")
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Image(
          image: AssetImage("assets/blogo_text.png"),
          height: 40.0,
        ),
            SizedBox(width: 5.0),
              // Text(
              //   city,
              //   style: appBarLocationTextStyle,
              // ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.local_shipping,
              color: Constant.blackColor,
            ),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new BzWebView(data: {'url':"${DxNet.baseUrl}/track_your_order?"}))
              );
            },
          ),
        ],
      ),);
  }
  loading(bool status){
    if(status){
    setState(() {
      isLoading = true;
    });}
    else{
      setState(() {
        isLoading = false;
      });
    }
  }

  goBackUrl() async {
    if(_webViewController != null){
      bool canGo = await _webViewController.canGoBack();
          if(canGo){
            _webViewController.goBack();
            return false;
          }
    }

      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        Fluttertoast.showToast(
          msg: 'Press Back Once Again to Exit.',
          backgroundColor: Colors.black,
          textColor: Constant.whiteColor,
        );
        return false;
      }
      else {
        exit(0);

      }



  }
  void _login(InAppWebViewController ctr, BuildContext context,data) async {

    // await ctr.evaluateJavascript();
  }



}
