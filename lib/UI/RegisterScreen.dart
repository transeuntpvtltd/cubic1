import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cubic/Custom%20Models/MemberModel.dart';
import 'package:cubic/UI/MainScreen.dart';
import 'package:cubic/UI/PaymentScreen.dart';
import 'package:cubic/Widgets/Button.dart';
import 'package:cubic/Widgets/FamilyMember.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../amplifyconfiguration.dart';

import '../models/ModelProvider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

TextEditingController email = new TextEditingController();
String dob = "";

var widgets = <Widget>[];

List<String> genders = <String>[
  'Select Gender',
  'Male',
  'Female',
  'Prefer not to say'
];

String selectedGender = 'Select Gender';

TextStyle defaultStyle = TextStyle(color: Colors.black);
TextStyle linkStyle = TextStyle(color: const Color(0XFF0000FF));
OtpFieldController otpFieldController = new OtpFieldController();

late Timer timer;
bool clicked = false;
int seconds = 60;
final FirebaseAuth _auth = FirebaseAuth.instance;
String otpCode = '';
String verificat = '';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  List<FamilyMember> members = [];
  final _formKey = GlobalKey<FormState>();
  String phoneNo = '', verificationId = '';
  bool codeSent = false;
  String phone_number = '';
  bool verified = false;

  var namecontroller = TextEditingController();
  var dobcontroller = TextEditingController();
  var adharcontroller = TextEditingController();
  var relationcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();

    MemberModel firstModel = new MemberModel(
        name: namecontroller.text.toString(),
        relation: "Self",
        adhar: adharcontroller.text.toString(),
        gender: selectedGender,
        dob: dobcontroller.text.toString());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // A flexible child that will grow to fit the viewport but
          // still be at least as big as necessary to fit its contents.
          Container(
            color: const Color(0xFFFFBD59), // Red
            width: 73.0,
          ),
          Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 50),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        (FirebaseAuth.instance.currentUser?.emailVerified
                                     ==
                                true)
                            ? Column(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: IntlPhoneField(
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: const Color(0xFF208FEE),
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          labelText: 'Phone Number',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(),
                                          ),
                                        ),
                                        initialCountryCode: 'IN',
                                        onChanged: (phone) {
                                          phone_number =
                                              phone.completeNumber.toString();
                                        },
                                      )),
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 20, 0),
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Button(
                                              text: 'Send OTP',
                                              onPress: () {
                                                //get the credentials of the new linking account

                                               linkEmailPhone(phone_number);

                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              title: Text(
                                                                'Verify OTP',
                                                              ),
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    OTPTextField(
                                                                      length: 6,
                                                                      controller:
                                                                          otpFieldController,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      fieldWidth:
                                                                          30,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15),
                                                                      textFieldAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      fieldStyle:
                                                                          FieldStyle
                                                                              .underline,
                                                                      onCompleted:
                                                                          (pin) async {
                                                                        otpCode =
                                                                            pin;


                                                                        AuthCredential pauthCreds = PhoneAuthProvider.credential(
                                                                            verificationId: verificationId, smsCode: otpCode);

                                                                        if(pauthCreds.token != null) {
                                                                          signIn(pauthCreds);
                                                                        }
                                                                        else{
                                                                          Fluttertoast.showToast(msg: 'Wrong OTP');
                                                                        }
                                                                      },
                                                                    ),
                                                                    Padding(padding: EdgeInsets.all(20), child:
                                                                    Button(
                                                                        text:
                                                                            'Verify',
                                                                        onPress:
                                                                            () async {
                                                                              AuthCredential pauthCreds = PhoneAuthProvider.credential(
                                                                                  verificationId: verificationId, smsCode: otpCode);

                                                                              if(pauthCreds.token != null) {
                                                                                signIn(pauthCreds);
                                                                              }
                                                                              else{
                                                                                Fluttertoast.showToast(msg: 'Wrong OTP');
                                                                              }
                                                                        },
                                                                        color: const Color(
                                                                            0xFF208FEE),
                                                                        borderColor:
                                                                            const Color(
                                                                                0xFF208FEE),
                                                                        textColor:
                                                                            Colors.white))
                                                                  ]),
                                                            ));
                                              },
                                              color: new Color(0xFF208FEE),
                                              borderColor:
                                                  new Color(0xFF208FEE),
                                              textColor: Colors.white)))
                                ],
                              )
                            : Column(
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () async {
                                        //get the credentials of the new linking account
                                        final GoogleSignIn _googleSignIn =
                                            GoogleSignIn();

                                        final GoogleSignInAccount? googleUser =
                                            await _googleSignIn.signIn();
                                        final GoogleSignInAuthentication
                                            googleAuth =
                                            await googleUser!.authentication;

                                        final AuthCredential gcredential =
                                            GoogleAuthProvider.credential(
                                          accessToken: googleAuth.accessToken,
                                          idToken: googleAuth.idToken,
                                        );

                                        //now link these credentials with the existing user
                                        FirebaseAuth.instance.currentUser!
                                            .linkWithCredential(gcredential);
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Image.asset(
                                              'Assets/rectangle.png',
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Image.asset(
                                                'Assets/google_logo.png',
                                                width: 50,
                                                height: 50,
                                              ),
                                              Text('Add your Google Account')
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: Text(
                                        'If you add your google account above, it will get linked to you registration number which will make your experience smoother',
                                        style: TextStyle(
                                            color: const Color(0xFF696969)),
                                      ))
                                ],
                              ),
                        Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                    borderRadius: BorderRadius.circular(7)),
                                child: Center(
                                  child: TextFormField(
                                    controller: namecontroller,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(left: 10.0),
                                        hintText: 'Name',
                                        border: InputBorder.none),
                                  ),
                                )),
                            Container(
                              margin:
                                  EdgeInsets.only(left: 20, right: 20, top: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(7)),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField2(
                                        validator: (value) {
                                          if (value == 'Select Item' ||
                                              value == 'Select Gender') {
                                            return 'Please select gender';
                                          }
                                        },
                                        hint: Text(
                                          'Select Item',
                                        ),
                                        items: genders
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        value: selectedGender,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedGender = newValue!;
                                          });
                                        })),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Date of Birth',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          left: 20, right: 20, top: 20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.black, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Center(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter Date of Birth';
                                            }
                                            return null;
                                          },
                                          controller: dobcontroller,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.only(left: 10.0),
                                              border: InputBorder.none),
                                          onTap: () {
                                            showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900, 1),
                                              lastDate: DateTime.now(),
                                            ).then((pickedDate) {
                                              setState(() {
                                                var date = DateTime.parse(
                                                    pickedDate.toString());
                                                var formattedDate =
                                                    "${date.day}-${date.month}-${date.year}";
                                                dobcontroller.text =
                                                    formattedDate;
                                                dob = formattedDate;
                                              });
                                            });
                                          },
                                        ),
                                      )),
                                )
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                    borderRadius: BorderRadius.circular(7)),
                                child: Center(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: adharcontroller,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(left: 10.0),
                                        hintText: 'Aadhar No.',
                                        border: InputBorder.none),
                                  ),
                                ))
                          ],
                        ),
                        ListView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          addAutomaticKeepAlives: true,
                          itemCount: members.length,
                          itemBuilder: (_, i) => members[i],
                        ),
                        Padding(
                            padding: EdgeInsets.all(15),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () {
                                    onAddForm();
                                  },
                                  child: Text('Add Family Member',
                                      style: TextStyle(fontSize: 16.0))),
                            )),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 20, left: 20, right: 20),
                            child: RichText(
                              text: TextSpan(
                                style: defaultStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'By clicking, you accept our '),
                                  TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                          color: const Color(0XFF0000FF)),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {}),
                                ],
                              ),
                            )),
                        Button(
                            text: 'Register',
                            onPress: () async {

                              if (_formKey.currentState!.validate() &&
                                  phone_number.length >= 10 &&
                                  FirebaseAuth.instance.currentUser?.phoneNumber != null) {
                                //   // If the
                                //
                                //
                                //form is valid, display a snackbar. In the real world,
                                //   // you'd often call a server or save the information in a database.
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(content: Text('Registering')));
                                //
                                //       // Add the following line to add API plugin to your app
                                //       if (!Amplify.isConfigured) {
                                //     Amplify.addPlugin(AmplifyAPI(
                                //         modelProvider:
                                //         ModelProvider.instance));
                                //
                                //     await Amplify.configure(amplifyconfig);
                                //   }
                                //
                                //   try {

                                //     final request = ModelMutations.create(user);
                                //     final response = await Amplify.API
                                //         .mutate(request: request)
                                //         .response;
                                //
                                //     User? createdUser = response.data;
                                //     if (createdUser == null) {
                                //       print('errors: ' + response.errors.toString());
                                //       return;
                                //     }
                                //     print('Mutation result: ' + createdUser.id);
                                //   } on ApiException catch (e) {
                                //     print('Mutation failed: $e');
                                //   } on AmplifyAlreadyConfiguredException {
                                //     print(
                                //         "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
                                //   }

                                List data = <MemberModel>[];
                                data.add(firstModel);

                                for (int i = 0; i < members.length; i++) {
                                  data.add(members[i].memberModel);
                                }

                                print("amey $data");

                                CollectionReference users = FirebaseFirestore
                                    .instance
                                    .collection('Users');

                                users.doc(FirebaseAuth.instance.currentUser!.uid)
                                    .set({
                                      'id': phone_number,
                                      'emaild_id': FirebaseAuth.instance.currentUser!.email.toString(),
                                      'contact_no': phone_number,
                                      'members':
                                          data.map((i) => i.toMap()).toList(),
                                    })
                                    .then((value) => print("User Added"))
                                    .catchError((error) =>
                                        print("Failed to add user: $error"));

                                // FirebaseFirestore.instance.collection('users').doc('OKuHZlpVrS84oVn0mLpx').collection('members').add(data.);

                                // for (int i = 0; i < data.length; i++) {
                                //   MemberModel member = data[i];
                                //   FirebaseFirestore.instance
                                //       .collection('users')
                                //       .doc('tETfb31NFNO3XhhRnPhc')
                                //       .collection('members')
                                //       .add({
                                //         'name': member.name,
                                //         'relation': member.relation,
                                //         'adhar': member.adhar,
                                //         'dob': member.dob,
                                //         'subscribed': member.subscribed,
                                //         'deleted': member.deleted,
                                //         'gender': member.gender
                                //       })
                                //       .then((value) => print(data[i]))
                                //       .catchError((error) =>
                                //           print("Failed to add user: $error"));
                                // }

                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            PaymentScreen()));
                              }
                              else {
                                Fluttertoast.showToast(
                                    msg: 'Verify contact number');
                              }
                              // }
                            },
                            color: const Color(0XFF208FEE),
                            borderColor: const Color(0XFF208FEE),
                            textColor: Colors.white)
                      ],
                    ))),
          )
        ],
      ),
    );
  }

  // void addMemberFields() {
  //
  //     TextEditingController nameController = TextEditingController(),
  //         genderController = TextEditingController(),
  //         dobController = TextEditingController(),
  //         adharController = TextEditingController();
  //
  //
  //     setState(() {

  void onDelete(MemberModel memberModel) {
    setState(() {
      var find = members.firstWhere(
        (it) => it.memberModel == memberModel,
      );
      members.removeAt(members.indexOf(find));
    });
  }

  void onAddForm() {
    setState(() {
      var _member = MemberModel();
      members.add(FamilyMember(
          memberModel: _member, onDelete: () => onDelete(_member)));
    });
  }

  linkEmailPhone(String phoneNo) async {
    //get currently logged in user

    //get the credentials of the new linking account

    final PhoneVerificationCompleted verified = (AuthCredential authCreds) {
      signIn(authCreds);
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: authException.message.toString());
    };

    final PhoneCodeSent smsSent = (String verId, int? sms) {
      this.verificationId = verId;
      Fluttertoast.showToast(msg: 'Code sent');
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {

    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  signIn(AuthCredential authCreds) async {
    //now link these credentials with the existing user
    FirebaseAuth.instance.currentUser!.linkWithCredential(authCreds);
    Fluttertoast.showToast(msg: 'Mobile number added successfully');
    Navigator.pop(context);
    verified = true;
  }

  // Future<void> phoneSignIn({required String phoneNumber}) async {
  //   seconds = 60;
  //   timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (seconds > 0) {
  //       setState(() {
  //         seconds--;
  //       });
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     timeout: const Duration(seconds: 60),
  //     phoneNumber: phoneNumber,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       timer.cancel();
  //       List<String> pin = [];
  //
  //       for (int i = 0; i < credential.smsCode!.length; i++) {
  //         pin.add((credential.smsCode).toString()[i]);
  //       }
  //
  //       setState(() {
  //         otpFieldController.set(pin);
  //       });
  //       Navigator.of(context,
  //           rootNavigator: true)
  //           .pop();      },
  //     verificationFailed: (FirebaseAuthException e) {
  //       timer.cancel();
  //       Fluttertoast.showToast(
  //           msg: e.message.toString(),
  //           gravity: ToastGravity.BOTTOM,
  //           toastLength: Toast.LENGTH_LONG);
  //       Navigator.of(context,
  //           rootNavigator: true)
  //           .pop();      },
  //     codeSent: (String verificationI, int? resendToken) async {
  //       verificat = verificationI;
  //       Fluttertoast.showToast(
  //           msg: 'Code sent successfully',
  //           gravity: ToastGravity.BOTTOM,
  //           toastLength: Toast.LENGTH_LONG);
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       Fluttertoast.showToast(
  //           msg: 'Time out. Try again',
  //           gravity: ToastGravity.BOTTOM,
  //           toastLength: Toast.LENGTH_LONG);
  //     },
  //   );
  // }
}
