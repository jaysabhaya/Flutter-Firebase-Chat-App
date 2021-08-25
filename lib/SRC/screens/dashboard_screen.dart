import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_auth/SRC/const_dialog.dart';
import 'package:flutter_google_auth/SRC/screens/chat.dart';
import 'package:flutter_google_auth/SRC/screens/login_screen.dart';
import 'package:flutter_google_auth/resources/indicators.dart';
import 'package:flutter_google_auth/shared_preference/prefs_keys.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../chatData.dart';
import '../constants.dart';
import '../global.dart';

List<dynamic> friendList = [];

class DashboardScreen extends StatefulWidget {
  static const String id = "dashboard_screen";
  final String currentUserId ;
  DashboardScreen({Key key, this.currentUserId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  _DashboardScreenState({Key key});
  String currentUserId ='';
  bool isLoading = false;
  bool addNewFriend = false;
   Map userdata;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];
  List<QueryDocumentSnapshot> listOfdata = [];
  final friendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    addcurrentUser();
    if(widget.currentUserId != null && widget.currentUserId != '')
    {
        currentUserId =widget.currentUserId;
    }
    getFriendList();
    
  }


  Future<void> getFriendList() async {
     userdata = json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA));
      if(currentUserId != '')
      {
        await FirebaseFirestore.instance.collection('users').where('UID',isNotEqualTo: json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'])
        .get().then((value) => listOfdata = value.docs);
                        //       FirebaseFirestore.instance
                        //     .collection('users')
                        //     .doc(currentUserId)
                        //     .get()
                        //     .then((DocumentSnapshot documentSnapshot) {
                        //   if (documentSnapshot.exists) {
                        //     print('Document data: ${documentSnapshot.data()}');
                        //     setState(() {
                        //       friendList = documentSnapshot.data()['friends'] ?? [];
                        //       // print('Document data:' + friendList[0]);
                        //     });
                        //   } else {
                        //     print('Document does not exist on the database');
                        //   }
                        // });
      }
      else
      {
        
        // List<QueryDocumentSnapshot> allUser =
         await FirebaseFirestore.instance.collection('users').where('UID',isNotEqualTo: json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).get().then((value) => listOfdata = value.docs);

      }
      setState(() {});


  }

  
void addcurrentUser()async
{
      await Firebase.initializeApp();
  var logInUser = json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA));
  currentUserId = logInUser['UID'].toString();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading:userdata != null && userdata['profile_url'].toString().contains('http') ? Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(60.0)),
                    clipBehavior: Clip.hardEdge,
          child: widgetShowImages(userdata['profile_url'], 5),),
      ) : null,
      title: Text(userdata != null && userdata['displayName'] != null ? userdata['displayName'] : '',style: TextStyle(fontSize: 16),),
      centerTitle: true,

      backgroundColor: themeColor,
      actions: [
        InkWell(
          onTap: ()async{
                  showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              activeButtonOne: true,
              activeButtonTwo: true,
              title: 'Confirm',
              descriptions: 'Are you sure you want to logout',
              buttonOneText: 'Yes',
              buttonTwoText: 'No',

              onPressedOne: () {
                        try {
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId:'605130044652-sji4ltpm0lbjthqqrajomvukfgth5308.apps.googleusercontent.com',
      );
       Indicators().indicatorPopupWillNotPop(context);
      _googleSignIn.signOut();
          PrefObj.preferences.remove(PrefKeys.IS_LOGIN);
          PrefObj.preferences.remove(PrefKeys.USER_DATA);
              Indicators().hideIndicator(context);
             Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
                (route) => false,
              );
      
    } catch (error) {
      print(error);
    }
              },
              onPressedTwo: () => Navigator.pop(context),
            );
          });

          },
          child: Icon(Icons.logout)),
          SizedBox(width: 10,),
      ],
    ),
      // ChatWidget.getAppBar(),
      backgroundColor: Colors.white,
      body: WillPopScope(
        child:currentUserId != null && currentUserId != '' ? showFriendList(currentUserId) :SizedBox(),
        onWillPop: onBackPress,
      ),
    );
  }

  Future<bool> onBackPress() {
    ChatData.openDialog(context);
    return Future.value(false);
  }

  Widget showAddFriend() {
    return Container(
      child: RaisedButton(
        child: Text('Add New Friend'),
        onPressed: _showAddFriendDialog,
      ),
    );
  }

  _showAddFriendDialog() async {
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  controller: friendController,
                  decoration: new InputDecoration(
                      labelText: 'user Email', hintText: 'ankeshkumar@live.in'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('Add'),
                onPressed: () {
                  print(friendController.text);
                  //if(friendController.text!='')
                  _addNewFriend();
                })
          ],
        ),
      ),
    );
  }

  void _addNewFriend() {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: friendController.text)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((result) {
          bool alreadyExist = false;
          for (var fr in friendList) {
            if (fr == result.data()['UID']) alreadyExist = true;
          }
          if (alreadyExist == true) {
            showToast("already friend", true);
          } else {
            friendList.add(result.data()['UID']);
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .update({"friends": friendList}).whenComplete(
                    () => showToast("friend successfully added", false));
          }
          friendController.text = "";
          Navigator.pop(context);
        });
      } else {
        showToast("No user found with this email.", true);
        Navigator.pop(context);
      }
    });
  }

  showToast(var text, bool error) {
    if (error == false) getFriendList();

    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: error ? Colors.red : Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget showFriendList(var currentUserId) {
    return Stack(
      children: <Widget>[
        // List
        // Container(
        //   width: double.infinity,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.end,
        //     children: [
        //       showAddFriend(),
        //     ],
        //   ),
        // ),

                               listOfdata.isEmpty ? SizedBox() : Container(
                                 child: ListView.builder(
                        itemCount: listOfdata.length,
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context,int index){
                           print(listOfdata[index]['profile_url']);
                          
                          // bool status = FirebaseFirestore.instance.collection('users').doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).
                       return   Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(

                child: listOfdata[index]['profile_url'] != null
                    ? widgetShowImages(listOfdata[index]['profile_url'], 50)
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: colorPrimaryDark,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                                                      child: Container(
                              child: Text(listOfdata[index]['displayName'].toString(),
                                style: TextStyle(color: primaryColor,fontSize: 14),

                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                            ),
                          ),
                          Container(
                        child: FutureBuilder<String>(
                          future: _returnStatus(listOfdata[index],index),
                          builder: (context,AsyncSnapshot snapshotStatus){

                            if(!snapshotStatus.hasData || snapshotStatus.data == null)
                            {
                              return Indicators().indicatorWidget(istext: false,size: 20);
                            }
                            else
                            {
                              return GestureDetector(
                                onTap: (){

                                  if(snapshotStatus.data == 'Accept')
                                  {
                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return CustomDialogBox(
                                                                activeButtonOne: true,
                                                                activeButtonTwo: true,
                                                                title: 'Confirmation',
                                                                descriptions: 'Would you like to move forwardc with them',
                                                                buttonOneText: 'Yes',
                                                                buttonTwoText: 'No',
                                                                onPressedOne: ()async{

                                                                  Indicators().indicatorPopupWillNotPop(context);
                                                                      FirebaseFirestore.instance.collection('users').doc(listOfdata[index]['UID']).collection('my_request').get().
                                                                      then((value) async{
                                                                        print(value.docs);
Indicators().hideIndicator(context);
                                                                                    value.docs.forEach((element) async{
                                                                                      
                                                                                        if(element.get('UID') == json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'])
                                                                                        {

                                                                                                 element.reference.update({'status':true});
                                                                                                 List alldocID =[];
                                                                                                 listOfdata.forEach((element) {
                                                                                                    alldocID.add(element.id);
                                                                                                 });

                                                                                                FirebaseFirestore.instance.collection('users').doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).collection('Accept_invitation').get().then((value) {
                                                                                                            value.docs.forEach((element) {
                                                                                                              print(element.get('UID'));
                                                                                                                  if(alldocID.contains(element.get('UID')))
                                                                                                                  {
                                                                                                                          element.reference.update({'status':true});
                                                                                                                          setState(() {});
                                                                                                                          Navigator.pop(context);
                                                                                                                          return;
                                                                                                                  } 
                                                                                                                  
                                                                                                            });
                                                                                                });
                                                                                        }
                                                                                    });
                                                                                     
                                                                      });
                                                                       
                                                                },   
                                                              );
                                                            });
                                  }

                                },
                                                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color:snapshotStatus.data == 'Pending' ? Colors.yellow.withOpacity(0.5) :snapshotStatus.data == 'Accept' ? themeColor.withOpacity(0.5) : snapshotStatus.data == 'Connected' ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),  
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.5),
                                    child: Text(snapshotStatus.data,style: TextStyle(fontSize: 10.5,color: Colors.white),),
                                  ),),
                              );
                            }

                          }),
                        // Text(
                          
                        //   'Confirm',
                        //     style: TextStyle(color: primaryColor,fontSize: 11.5),
                        // ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                        ],
                      ),
                      SizedBox(height: 4,),
                        Container(
                        child: Text(listOfdata[index]['email'].toString(),
                          style: TextStyle(color: primaryColor,fontSize: 11.5),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 0.0),
                ),
              ),


              // ConstrainedBox(

              //   constraints: new BoxConstraints(
              //     minHeight: 10.0,
              //     minWidth: 10.0,
              //     maxHeight: 30.0,
              //     maxWidth: 30.0,
              //   ),
              //   child: new DecoratedBox(
              //     decoration: new BoxDecoration(
              //         color: listOfdata[index].data().containsKey('status')
              //             ? Colors.greenAccent
              //             : Colors.transparent),
              //   ),
              // ),
            ],
          ),
          onPressed: () {
                 
                 
                   FirebaseFirestore.instance.collection('users').doc(listOfdata[index]['UID']).collection('my_request').get().then((value){
                 
                     if(value.docs.isEmpty)
                     {      
                           

                            showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return CustomDialogBox(
                                                                                                  activeButtonOne: true,
                                                                                                  activeButtonTwo: true,
                                                                                                  title: 'Request',
                                                                                                  descriptions: 'Please send request to talk more',
                                                                                                  buttonOneText: 'Send request',
                                                                                                  buttonTwoText: 'Cancel',
                                                                                                  onPressedTwo: () => Navigator.pop(context),
                                                                                                  onPressedOne: (){

                                                                                            
                                                                                                    Indicators().indicatorPopupWillNotPop(context);
                                                                                                    FirebaseFirestore.instance.collection('users').doc(listOfdata[index]['UID']).collection('Accept_invitation').
                                                                                                    doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).set({'UID':json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'],'displayName':json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['displayName'] ,'status':false}).then((value) {

                                                                                                      FirebaseFirestore.instance.collection('users').doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).collection('my_request').doc(listOfdata[index]['UID']).
                                                                                                      set({'UID':listOfdata[index]['UID'],'displayName':listOfdata[index]['displayName'] ,'status':false}).then((value){
                                                                                                                          Navigator.pop(context);
                                                                                                          Indicators().hideIndicator(context);
                                                                                                      ToastMSG(context, 'Request has been sent successfully');
                                                                                                      });


                                                                                                    });
                                          setState(() {});
                                                                                                  },

                                                                                                );
                                                                                              });
                     }
                     else
                     {
                            Indicators().indicatorPopupWillNotPop(context);
                               for(QueryDocumentSnapshot item in value.docs)
                                        {
                                            if(item['UID'] == json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'])
                                            {      
                                                Indicators().hideIndicator(context);
                                                  if(item['status'])
                                                  {

                                                 
                                                                                              Navigator.push(
                                                                                              context,
                                                                                              MaterialPageRoute(
                                                                                                  builder: (context) => Chat(
                                                                                                        currentUserId: currentUserId,
                                                                                                        peerId: listOfdata[index]['UID'],
                                                                                                        peerName: listOfdata[index]['displayName'],
                                                                                                        peerAvatar: listOfdata[index]['profile_url'],
                                                                                                      )));
                                                                                                      break;
                                                  }
                                                  else
                                                  {
                                                   
                                                    
                                                                                              showDialog(
                                                                                              context: context,
                                                                                              builder: (BuildContext context) {
                                                                                                return CustomDialogBox(
                                                                                                  activeButtonOne: true,
                                                                                                  activeButtonTwo: true,
                                                                                                  title: 'Request',
                                                                                                  descriptions: 'Please send request to talk more',
                                                                                                  buttonOneText: 'Send request',
                                                                                                  buttonTwoText: 'Cancel',
                                                                                                  onPressedTwo: () => Navigator.pop(context),
                                                                                                  onPressedOne: (){

                                                                                            
                                                                                                    Indicators().indicatorPopupWillNotPop(context);
                                                                                                    FirebaseFirestore.instance.collection('users').doc(listOfdata[index]['UID']).collection('Accept_invitation').
                                                                                                    doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).set({'UID':json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'],'displayName':json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['displayName'] ,'status':false}).then((value) {

                                                                                                      FirebaseFirestore.instance.collection('users').doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).collection('my_request').doc(listOfdata[index]['UID']).
                                                                                                      set({'UID':listOfdata[index]['UID'],'displayName':listOfdata[index]['displayName'] ,'status':false}).then((value){
                                                                                                                          Navigator.pop(context);
                                                                                                          Indicators().hideIndicator(context);
                                                                                                      ToastMSG(context, 'Request has been sent successfully');
                                                                                                      });


                                                                                                    });
                                                                                                      setState(() {});
                                                                                                  },

                                                                                                );
                                                                                              });
                                                                                              
                                                                                              break;
                                                  } 
                                            }
                                        }
                                        // Indicators().hideIndicator(context);
                     }

                   
                });

          // if(listOfdata[index].data().containsKey('isfriend'))
          // {
          //                     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => Chat(
          //                 currentUserId: currentUserId,
          //                 peerId: listOfdata[index]['UID'],
          //                 peerName: listOfdata[index]['displayName'],
          //                 peerAvatar: listOfdata[index]['profile_url'],
          //               )));
          // }
          // else
          // {


          // }

          },
          color: viewBg,
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
                        }
                            
                        
                      ),
                               ),
//         Container(
//                 margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
//                 child: StreamBuilder<QuerySnapshot>(
//                   // ignore: deprecated_member_use
//                   stream:FirebaseFirestore.instance.collection('user').get().asStream(),
//                   //  FirebaseFirestore.instance
//                   //     .collection(ChatDBFireStore.getDocName())
//                   //     .where('UID', whereIn: friendList)
//                   //     .snapshots(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(themeColor),
//                         ),
//                       );
//                     } else {

// print(snapshot.data.docs);

//                     }
//                   },
//                 ),
//               )
            // : Container()
      ],
    );
  }

  Future<String> _returnStatus(QueryDocumentSnapshot listOfdata,int index)async
  {
      
     String test;
     await FirebaseFirestore.instance.collection('users').doc(listOfdata['UID']).collection('Accept_invitation').
     get().then((value) async{
      //  test = value.docs.contains(element);
      if(value.docs.isEmpty)
      {
        test ='Invite';
        await FirebaseFirestore.instance.collection('users').doc(listOfdata['UID']).collection('my_request').get().then((value){
                  value.docs.forEach((element) {
                      if(element.data()['UID'] == json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'])
                      {
                          if(element.data()['status'])
                          {
                              test = 'Connected';
                          }
                          else
                          {
                              test ='Accept';
                          }
                        
                        return test;
                      }
                  });
          });

          
          return test;
      }
      else 
      {
            test ='Invite';
            value.docs.forEach((element) {
                if(element.data()['status'] && element.data()['UID'] == json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'])
                {
                  test ='Connected';
                  return 'Connected';
                }
                else if(element.data()['UID'] == json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID'])
                {
                   test ='Pending';
                  return 'Pending';
                }
                else
                {
                   test ='Invite';
                  return 'Invite';
                }
            });
          
          return test;
      }
       
       
     });
     return test;
     


          //  FirebaseFirestore.instance.collection('users').doc(listOfdata[index]['UID']).collection('Request_pending').
          //       doc(listOfdata[index]['UID']).set({'UID':listOfdata[index]['UID'],'displayName':listOfdata[index]['displayName'] ,'status':false}).then((value) {

          //         FirebaseFirestore.instance.collection('users').doc(json.decode(PrefObj.preferences.getString(PrefKeys.USER_DATA))['UID']).collection('my_request').doc(listOfdata[index]['UID']).
          //         set({'UID':listOfdata[index]['UID'],'displayName':listOfdata[index]['displayName'] ,'status':false}).then((value){
          //                              Navigator.pop(context);
          //          ToastMSG(context, 'Request has been sent successfully');
          //         });


          //       });
  }
    // Show Images from network
  static Widget widgetShowImages(String imageUrl, double imageSize) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: imageSize,
      width: imageSize,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets / 2,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
