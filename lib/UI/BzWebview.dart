import 'dart:developer';
import 'package:bloomzon/UI/LoginOrSignup/Signup.dart';
import 'package:bloomzon/bloc/browser/browser_cubit.dart';
import 'package:bloomzon/constant/constant.dart';
import 'package:bloomzon/helpers/authhelper.dart';
import 'package:bloomzon/utils/DxNetwork.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'LoginOrSignup/Login.dart';
import 'LoginOrSignup/ChoseLoginOrSignup.dart';


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
  bool isLoading, showErrorPage;

  var _logged;
  BrowserCubit bwCubit = new BrowserCubit(0);
  void getLogStatus() async {
    var data;

    try {
       data = await checkLogin();
    }catch(e){
    print(e);
    }
    setState(() {
      _logged = data;
    });
    bwCubit.setState(1);
  }
  @override
  void initState() {
    super.initState();
    isLoading = true;
    showErrorPage = false;
    getLogStatus();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    bwCubit.close();
    super.dispose();
  }


  void showError(){
    setState(() {
      showErrorPage = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: WillPopScope(child: BlocBuilder(
        bloc: bwCubit,
        builder: (context,state){
          if(state == 1) {
            print(widget
                .data['url']);
            var params = '';
            if(_logged != null && _logged != false){
              params =  "&mdxEmail=${_logged['email']}&mdxPw=${_logged['pw']}&mdxPhone=${_logged['phone']}";
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
                    android: AndroidInAppWebViewOptions(
                      allowFileAccessFromFileURLs: true
                    ),
                      crossPlatform: InAppWebViewOptions(
                    userAgent:
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36",
                    debuggingEnabled: true,
                  )
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    print(_webViewController.getUrl());
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    print(url);
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
                  onLoadError: (
                      InAppWebViewController controller,
                      String url,
                      int i,
                      String s
                      ) async {
                    print('CUSTOM_HANDLER: $i, $s');
                    /** instead of printing the console message i want to render a static page or display static message **/
                    showError();
                  },
                  onProgressChanged: (InAppWebViewController controller,
                      int progress) {

                  },


                ),
                isLoading == true ? Constant.bzLoaderDefault : Container(),
                showErrorPage == true ? Center(
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,

                      child: Column(
                        children: [
                          Image.asset('assets/img/not_found.png'),
                          TextButton.icon(onPressed: ()=> _webViewController.goBack(), icon: Icon(Icons.arrow_back,color: Colors.black38,), label: Text("Go Back",style: TextStyle(color: Colors.black38,fontSize: 20),)),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: TextButton.icon(onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> new ChoseLogin())), icon: Icon(Icons.home_outlined,color: Colors.black38, size: 12,), label: Text("Login or Signup Page",style: TextStyle(color: Colors.black38,fontSize: 12),))
                          )
                        ],
                      )
                    )) : Container()

              ],
            );
          }
          return Center(child: Constant.bzLoaderDefault,
          );
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
    if(_logged != null && _logged != false){
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
    }else{
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> new ChoseLogin()));
    }
  }

  void _login(InAppWebViewController ctr, BuildContext context,data) async {

    // await ctr.evaluateJavascript();
  }



}
// class _BzWebViewState extends State<BzWebView> {
//   InAppWebViewController _webViewController;
//   int currentIndex = 0;
//   DateTime currentBackPressTime;
//   double progress = 0;
//   Codec<String, String> stringToB64 = utf8.fuse(base64); //instantiate the encoder
//   bool isLoading;
//   var _logged;
//   BrowserCubit bwCubit = new BrowserCubit(0);
//   void getLogStatus() async {
//    var  data = await checkLogin();
//     setState(() {
//       _logged = data;
//     });
//    bwCubit.setState(1);
//   }
//   @override
//   void initState() {
//     super.initState();
//     isLoading = true;
//     getLogStatus();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     bwCubit.close();
//     super.dispose();
//
//   }
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       // We're using a Builder here so we have a context that is below the Scaffold
//       // to allow calling Scaffold.of(context) so we can show a snackbar.
//       body: WillPopScope(child: BlocBuilder(
//         cubit: bwCubit,
//         builder: (context,state){
//           if(state == 1) {
//             var params = '';
//             if(_logged != null && _logged != false){
//                 params =  "&mdxEmail=${_logged['email']}&mdxPw=${_logged['pw']}";
//               }
//             return Stack(
//               children: <Widget>[
//                 InAppWebView(
//                   initialUrlRequest: URLRequest(url: Uri.parse("${widget
//                       .data['url']}&xmd=a103650ce9d64de3bc4df68a3df53e418617fc39$params")),
//                   // shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
//                   //   if(Platform.isAndroid || shouldOverrideUrlLoadingRequest.iosWKNavigationType == IOSWKNavigationType.LINK_ACTIVATED)
//                   //   {
//                   //     controller.loadUrl(url: shouldOverrideUrlLoadingRequest.url, headers: {"Authorization":"Bearer $token}"});
//                   //     return ShouldOverrideUrlLoadingAction.CANCEL;
//                   //   }
//                   //   return ShouldOverrideUrlLoadingAction.ALLOW;
//                   // },
//
//                   initialOptions: InAppWebViewGroupOptions(
//
//                   ),
//                   onWebViewCreated: (InAppWebViewController controller) {
//                     _webViewController = controller;
//
//                   },
//                   onLoadStart: (InAppWebViewController controller, Uri url) {
//                     _webViewController = controller;
//                     loading(true);
//                     if (url.path == "${DxNet.baseUrl}users/login" ||
//                         url.path == "${DxNet.baseUrl}login") {
//                       // _webViewController.goBack();
//                       userLogout().then((value) =>
//                           Navigator.pushReplacement(context, MaterialPageRoute(
//                               builder: (context) => new loginScreen()))
//                       ); //go back to homepage
//
//                     }
//                     if (url.path == "${DxNet.baseUrl}users/registration" ||
//                         url.path == "${DxNet.baseUrl}registration") {
//                       // _webViewController.goBack();
//                       userLogout().then((value) =>
//                           Navigator.pushReplacement(context, MaterialPageRoute(
//                               builder: (context) => new Signup()))
//                       ); //go back to homepage
//
//                     }
//                   },
//                   onLoadStop: (InAppWebViewController controller,
//                       Uri url) async {
//                     loading(false);
//                   },
//                   onProgressChanged: (InAppWebViewController controller,
//                       int progress) {
//
//                   },
//
//
//                 ),
//                 isLoading == true ? Constant.bzLoaderDefault : Container()
//
//               ],
//             );
//           }
//           return Container(
//             child: Center(child: Constant.bzLoaderDefault),
//           );
//         },
//       ),
//           onWillPop: () async {
//        var backStatus = goBackUrl();
//        if(backStatus == true){
//          exit(0);
//        }
//        return false;
//
//       } ),
//
//
//       appBar: AppBar(
//         backgroundColor: Constant.whiteColor,
//         automaticallyImplyLeading: false,
//         elevation: 0.0,
//         title: InkWell(
//           onTap: () => ()=>{
//             _webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse("${DxNet.baseUrl}")))
//           },
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//             Image(
//           image: AssetImage("assets/blogo_text.png"),
//           height: 40.0,
//         ),
//             SizedBox(width: 5.0),
//               // Text(
//               //   city,
//               //   style: appBarLocationTextStyle,
//               // ),
//             ],
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.local_shipping,
//               color: Constant.blackColor,
//             ),
//             onPressed: () {
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new BzWebView(data: {'url':"${DxNet.baseUrl}/track_your_order?"}))
//               );
//             },
//           ),
//         ],
//       ),);
//   }
//   loading(bool status){
//     if(status){
//     setState(() {
//       isLoading = true;
//     });}
//     else{
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   goBackUrl() async {
//     if(_webViewController != null){
//       bool canGo = await _webViewController.canGoBack();
//           if(canGo){
//             _webViewController.goBack();
//             return false;
//           }
//     }
//
//       DateTime now = DateTime.now();
//       if (currentBackPressTime == null ||
//           now.difference(currentBackPressTime) > Duration(seconds: 2)) {
//         currentBackPressTime = now;
//         Fluttertoast.showToast(
//           msg: 'Press Back Once Again to Exit.',
//           backgroundColor: Colors.black,
//           textColor: Constant.whiteColor,
//         );
//         return false;
//       }
//       else {
//         exit(0);
//
//       }
//
//
//
//   }
//   void _login(InAppWebViewController ctr, BuildContext context,data) async {
//
//     // await ctr.evaluateJavascript();
//   }
//
//
//
// }
