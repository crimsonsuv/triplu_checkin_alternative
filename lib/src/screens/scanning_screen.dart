import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/assets.dart';
import '../../utils/extensions.dart';
import 'package:flutter/services.dart';
import '../../models/check_in.dart';
import '../../services/services.dart';
import '../../utils/bottom_sheet_fix.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanningScreen extends StatefulWidget {
  ScanningScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _ScanningScreenState extends State<ScanningScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final qrCode = new BehaviorSubject<String>(seedValue: '');
  final isSheetShown = new BehaviorSubject<bool>(seedValue: false);
  static final apiCall = new BehaviorSubject<bool>(seedValue: false);
  final ticketData = new BehaviorSubject<CheckIn>(seedValue: null);

  Observable<String> get qrCodeObsrvr => qrCode.stream;

  //For Releasing variables after screen de-allocation
  @override
  void dispose() async {
    super.dispose();
    await qrCode.drain();
    qrCode.close();
    await isSheetShown.drain();
    isSheetShown.close();
    await apiCall.drain();
    apiCall.close();
    await ticketData.drain();
    ticketData.close();
  }

  //Performing Checking once QR code is detected
  _checkIn(String url) {
    print("api called with url ${url}");
    apiCall.add(true);
    checkIn(url, context).then((CheckIn data) {
      apiCall.add(false);
      if (data != null) {
        ticketData.add(data);
      } else {
        ticketData.add(null);
      }
    });
  }

  @override
  void initState() {

    ticketData.add(null); // Clearing Ticket data

    //Listning to any changes happening to qrCode
    qrCodeObsrvr.listen((checksum) {
      if (checksum != null && checksum.length > 0 && !apiCall.value) {
        print('Got QR now Fetching Data');
        SharedPreferences.getInstance().then((prefs) {
          String apiKey = prefs.getString('api_key');
          String ticketCheckInUrl =
              "https://www.triply.fun/tc-api/$apiKey/check_in/${checksum}";
          _checkIn(ticketCheckInUrl);
        });
      }
    });
    super.initState();
  }

  //Showing Bottom sheet when QR Code is detected
  void _showModal(context) {
    Future<void> future = showModalBottomSheetApp<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: 122,
                      color: Colors.transparent,
                    ),
                    Container(
                        height: 250.0,
                        color: Colors.transparent,
                        //could change this to Color(0xFF737373),
                        //so you don't have to change MaterialApp canvasColor
                        child: StreamBuilder<CheckIn>(
                            initialData: null,
                            stream: ticketData,
                            builder: (context, snapshot) {
                              return (snapshot.data == null)
                                  ? Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: new BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(10.0),
                                              topRight:
                                                  const Radius.circular(10.0))),
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            right: 0,
                                            bottom: 100,
                                            child: Center(
                                              child: (apiCall.value)
                                                  ? SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  kColor_green_theme)),
                                                    )
                                                  : Text('Data not available'),
                                            ),
                                          ),
                                          Positioned(
                                            top: 15,
                                            right: 15,
                                            height: 20,
                                            width: 20,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: Image.asset(
                                                ic_cross_grey,
                                                fit: BoxFit.cover,
                                                height: 20,
                                                width: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))
                                  : Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: new BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(10.0),
                                              topRight:
                                                  const Radius.circular(10.0))),
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20,
                                                            left: 20,
                                                            right: 20),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          width: 62,
                                                          child: Image.asset(
                                                            (snapshot.data
                                                                    .status)
                                                                ? ic_green_tick
                                                                : ic_red_cross,
                                                            fit: BoxFit.contain,
                                                            height: 60,
                                                            width: 60,
                                                          ),
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 40),
                                                          child: Column(
                                                            children: <Widget>[
                                                              Text(
                                                                '${snapshot.data.name}',
                                                                style: textStyle(
                                                                    kColor_dark_text,
                                                                    FontWeight
                                                                        .w500,
                                                                    21),
                                                              ),
                                                              Text(
                                                                (snapshot
                                                                            .data
                                                                            ?.customFields
                                                                            .length >
                                                                        3)
                                                                    ? '${snapshot.data?.customFields[3][1]}'
                                                                    : 'no entry',
                                                                style: textStyle(
                                                                    Colors
                                                                        .black26,
                                                                    FontWeight
                                                                        .w400,
                                                                    15),
                                                              )
                                                            ],
                                                          ),
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10)),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    child: Text(
                                                      (snapshot.data
                                                          .status)? 'successful check-in' : 'failed check-in',
                                                      style: textStyle(
                                                          kColor_dark_text,
                                                          FontWeight.normal,
                                                          17),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 15)),
                                                  Container(
                                                    height: 1,
                                                    color: Colors.black12,
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 15)),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 30),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                            width: 140,
                                                            child: Text(
                                                              'Stop',
                                                              style: textStyle(
                                                                Colors.black45,
                                                                FontWeight.w500,
                                                                17,
                                                              ),
                                                            )),
                                                        Container(
                                                            width: 4,
                                                            child: Text(
                                                              ':',
                                                              style: textStyle(
                                                                Colors.black45,
                                                                FontWeight.w500,
                                                                17,
                                                              ),
                                                            )),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15)),
                                                        Expanded(
                                                          child: Container(
                                                              width: 80,
                                                              child: Text(
                                                                '${snapshot.data?.customFields[0][1]}',
                                                                style:
                                                                    textStyle(
                                                                  kColor_dark_text,
                                                                  FontWeight
                                                                      .w500,
                                                                  17,
                                                                ),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 15)),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 30),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                            width: 140,
                                                            child: Text(
                                                              'Payment Status',
                                                              style: textStyle(
                                                                Colors.black45,
                                                                FontWeight.w500,
                                                                17,
                                                              ),
                                                            )),
                                                        Container(
                                                            width: 4,
                                                            child: Text(
                                                              ':',
                                                              style: textStyle(
                                                                Colors.black45,
                                                                FontWeight.w500,
                                                                17,
                                                              ),
                                                            )),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15)),
                                                        Expanded(
                                                          child: Container(
                                                              width: 80,
                                                              child: Text(
                                                                (snapshot.data
                                                                            ?.paymentDate ==
                                                                        '')
                                                                    ? 'Unpaid'
                                                                    : 'Paid',
                                                                style:
                                                                    textStyle(
                                                                  kColor_dark_text,
                                                                  FontWeight
                                                                      .w500,
                                                                  17,
                                                                ),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 15)),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 30),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                            width: 140,
                                                            child: Text(
                                                              'Time of Check-in',
                                                              style: textStyle(
                                                                Colors.black45,
                                                                FontWeight.w500,
                                                                17,
                                                              ),
                                                            )),
                                                        Container(
                                                            width: 4,
                                                            child: Text(
                                                              ':',
                                                              style: textStyle(
                                                                Colors.black45,
                                                                FontWeight.w500,
                                                                17,
                                                              ),
                                                            )),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15)),
                                                        Expanded(
                                                          child: Container(
                                                              width: 80,
                                                              child: Text(
                                                                'Fname Lname',
                                                                style:
                                                                    textStyle(
                                                                  kColor_dark_text,
                                                                  FontWeight
                                                                      .w500,
                                                                  17,
                                                                ),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 15,
                                            right: 15,
                                            height: 20,
                                            width: 20,
                                            child: GestureDetector(
                                              onTap: () {
                                                ticketData.add(null);
                                                Navigator.pop(context);
                                              },
                                              child: Image.asset(
                                                ic_cross_grey,
                                                fit: BoxFit.cover,
                                                height: 20,
                                                width: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ));
                            })),
                  ],
                ),
              ),
            ),
          );
        });
    future.then((void value) => _closeModal(value));
  }

  //once Bottom Sheet is closed following function will be called
  void _closeModal(void value) {
    isSheetShown.add(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: QrCamera(  //Performing QR Code scanning using Phone Camera
                      onError: (context, error) => Text(
                            error.toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                      qrCodeCallback: (code) {
                        if (!isSheetShown.value && qrCode.value != code.toString()) {
                          qrCode.add(code);
                          _showModal(context);
                          isSheetShown.add(true);
                        }
                      },
                    ),
                    flex: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Place the QR code inside area',
                      style: textStyle(Colors.white, FontWeight.normal, 16),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    Image.asset(
                      qr_window,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              )),
          Positioned(
            top: 32,
            left: 20,
            right: 20,
            child: Text('Ticket Scanning',
                textAlign: TextAlign.center,
                style: textStyle(
                  Colors.white,
                  FontWeight.w400,
                  21,
                )),
          ),
          Positioned(
            top: 28,
            left: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 35,
                    height: 35,
                    child: Image.asset(
                      ic_close_small,
                      fit: BoxFit.cover,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
