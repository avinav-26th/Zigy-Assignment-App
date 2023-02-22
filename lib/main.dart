import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart'
    as http; // 'as' is used to give a local name to the imported library, so to avoid any possible future conflicts

import 'widgets/detail_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Zigy Assignment App",
      home: MyHomePage(),
    );
  }
}

Map? responseMap; //to store the json response in a map after calling api
List? reqresDataList; //to store the map-data in list format

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future apiCall() async {
  //this function call the api in get-mode, just to get the sample data from reqres website
    try {
      http.Response apiResponse =
          await http.get(Uri.parse("https://reqres.in/api/users?page=2"));
      await Future.delayed(const Duration(milliseconds: 1500));
      if (apiResponse.statusCode == 200) {
        //statusCode 200 means that call is successful
        setState(() {
          responseMap = json.decode(apiResponse.body);
          reqresDataList = responseMap!['data'];  //storing the map-data to list
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Oops! Some error occurred."),
      ));
    }
  }

  @override
  void initState() {
    //this is to call the apiCall() function for the first time when the app starts
    apiCall();
    super.initState();
  }

  String? postCallInputFirstName, postCallInputLastName, postCallInputMail, postCallInputAvatar;

  void postCall() async {
    //this method is to demonstrate the post-call mode and how to send data to the Api
    try {
      http.Response postCallResponse =
          await http.post(Uri.parse("https://reqres.in/api/users"), body: {
            //in this body-section, we send the data to the api called
        'email': postCallInputMail,
        'first_name': postCallInputFirstName,
        'last_name': postCallInputLastName,
            'avatar': postCallInputAvatar,
      });
      setState(() {
        reqresDataList?.add(json.decode(postCallResponse.body));
        //this is the most crucial step as this is the part where linking is done. Since the reqres provides us with a sample data so I cannot actually upload the data to the api, but here what I'm doing is that after getting the data from api in get-mode and storing it in the 'reqresDataList', I'm adding the new data send to api via post-mode
      });
      if (kDebugMode) {
        print(postCallResponse.body);
        //this is to check that the post-mode is acctually working as every time we send data, we receive that same data along with a unique id provided by the api, which confirms the functioning
        print(reqresDataList);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Oops! Some error occurred."),
        ));
      }
    }
  }

  void getFeed(BuildContext context) {
    //this function is to take user-input for the post-mode data
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 380,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Dialog(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'What do people call you?',
                        labelText: 'First name',
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          postCallInputFirstName = value;
                        });
                      },
                    ),
                  ),
                  Dialog(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'What do people call you?',
                        labelText: 'Last name',
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          postCallInputLastName = value;
                        });
                      },
                    ),
                  ),
                  Dialog(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.mail),
                        hintText: 'What do people call you?',
                        labelText: 'e-mail',
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          postCallInputMail = value;
                          postCallInputAvatar = "https://reqres.in/img/faces/7-image.jpg";
                          //always setting this image as the temporary image, uploading image feature will be implemented in the next version
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      postCall();
                    },
                    child: const Text('Submit'),
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar customAppBar = AppBar(
      title: const Text(
        "Zigy Assignment App",
        style: TextStyle(
          color: Colors.lightBlue,
          fontSize: 30,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => getFeed(context),
          icon: const Icon(
            Icons.add,
            color: Colors.blue,
            size: 35,
          ),
        ),
      ],
    );

    return SafeArea(
      child: Scaffold(
        appBar: customAppBar,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: reqresDataList == null
              ? const Center(
                  child: SpinKitSpinningLines(
                    color: Colors.blue,
                    size: 200,
                    duration: Duration(seconds: 2),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: reqresDataList?.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        DetailCard(
                          //this is a widget written in another dart-file so passing the necessary values to it
                          reqresDataList![index]['avatar'].toString(),
                          reqresDataList![index]['first_name'].toString(),
                          reqresDataList![index]['last_name'].toString(),
                          reqresDataList![index]['email'].toString(),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
