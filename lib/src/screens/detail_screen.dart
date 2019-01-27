import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/assets.dart';
import '../../utils/extensions.dart';
import '../../services/services.dart';
import '../../models/ticket_checkins.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/check_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tickets_info.dart';
import '../../utils/bottom_sheet_fix.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}


class DetailScreen extends StatefulWidget {
  final TicketInfo ticketData;

  DetailScreen({Key key, this.ticketData}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>{

  String ticketCheckinsUrl = '';

  static final apiCallCheckin = new BehaviorSubject<bool>(seedValue: false);
  static final apiCallTicketsCheckins = new BehaviorSubject<bool>(seedValue: false);
  static final ticketCheckinsArr = BehaviorSubject<List<TicketCheckins>>(seedValue: []);
  final checkInticketData = new BehaviorSubject<CheckIn>(seedValue: null);
  final checksum = new BehaviorSubject<String>(seedValue: '');

  Observable<String> get checksumObsrvr => checksum.stream;

  _ticketCheckins(String url) {
    apiCallTicketsCheckins.add(true);
    ticketCheckins(url, context).then((List<TicketCheckins> data) {
      apiCallTicketsCheckins.add(false);
      if(data != null){
        if (data.isNotEmpty && data.length > 0) {
          ticketCheckinsArr.add(data);
        } else {
          ticketCheckinsArr.add([]);
        }
      } else {
        ticketCheckinsArr.add([]);
      }
    });
  }

  @override
  void initState() {
    ticketCheckinsArr.add([]);
    super.initState();
    // TODO: implement initState
    SharedPreferences.getInstance().then((prefs) {
      String apiKey = prefs.getString('api_key');
      String url =
          "https://www.triply.fun/tc-api/$apiKey/ticket_checkins/${widget.ticketData.data.checksum}";
      ticketCheckinsUrl = url;
      _ticketCheckins(ticketCheckinsUrl);
    });

    checkInticketData.add(null);
    checksumObsrvr.listen((checksum) {
      if (checksum != null && checksum.length > 0 && !apiCallCheckin.value) {
        SharedPreferences.getInstance().then((prefs) {
          String apiKey = prefs.getString('api_key');
          String ticketCheckInUrl =
              "https://www.triply.fun/tc-api/$apiKey/check_in/$checksum";
          _checkIn(ticketCheckInUrl);
        });
      }
    });

  }

  @override
  void dispose() async{
    super.dispose();
    await apiCallTicketsCheckins.drain();
    apiCallTicketsCheckins.close();
    await ticketCheckinsArr.drain();
    ticketCheckinsArr.close();
    await apiCallCheckin.drain();
    apiCallCheckin.close();
    await checkInticketData.drain();
    checkInticketData.close();
    await checksum.drain();
    checksum.close();
  }

  _checkIn(String url) {
    print("api called with url $url");
    apiCallCheckin.add(true);
    checkIn(url, context).then((CheckIn data) {
      apiCallCheckin.add(false);
      if (data != null) {
        checkInticketData.add(data);
      } else {
        checkInticketData.add(null);
      }
    });
  }


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
                            stream: checkInticketData,
                            builder: (context, snapshot){
                              return (snapshot.data == null) ?

                              Container(
                                  decoration: new BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(10.0),
                                          topRight: const Radius.circular(10.0))),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        right: 0,
                                        bottom: 100,
                                        child: Center(
                                          child: (apiCallCheckin.value) ? SizedBox(
                                            height: 40,
                                            width: 40,
                                            child:  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kColor_green_theme)) ,
                                          ) : Text('Data not available'),
                                        ),
                                      ),
                                      Positioned(
                                        top: 15,
                                        right: 15,
                                        height: 20,
                                        width: 20,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
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
                                          topLeft: const Radius.circular(10.0),
                                          topRight: const Radius.circular(10.0))),
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
                                                padding: const EdgeInsets.only(
                                                    top: 20, left: 20, right: 20),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.only(left: 5),
                                                      width: 62,
                                                      child: Image.asset(
                                                        (snapshot.data.status) ? ic_green_tick : ic_red_cross,
                                                        fit: BoxFit.contain,
                                                        height: 60,
                                                        width: 60,
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                          padding:
                                                          EdgeInsets.only(right: 40),
                                                          child: Column(
                                                            children: <Widget>[
                                                              Text(
                                                                '${snapshot.data.name}',
                                                                style: textStyle(
                                                                    kColor_dark_text,
                                                                    FontWeight.w500,
                                                                    21),
                                                              ),
                                                              Text(
                                                                ((snapshot.data?.customFields.length ?? 0) > 3) ?'${snapshot.data?.customFields[3][1]}':'no entry',
                                                                style: textStyle(
                                                                    Colors.black26,
                                                                    FontWeight.w400,
                                                                    15),
                                                              )
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: 10)),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Text(
                                                  (snapshot.data
                                                      .status)? 'successful check-in' : 'failed check-in',
                                                  style: textStyle(kColor_dark_text,
                                                      FontWeight.normal, 17),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: 15)),
                                              Container(
                                                height: 1,
                                                color: Colors.black12,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: 15)),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
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
                                                        EdgeInsets.only(left: 15)),
                                                    Expanded(
                                                      child: Container(
                                                          width: 80,
                                                          child: Text(
                                                            '${snapshot.data?.customFields[0][1]}',
                                                            style: textStyle(
                                                              kColor_dark_text,
                                                              FontWeight.w500,
                                                              17,
                                                            ),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: 15)),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
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
                                                        EdgeInsets.only(left: 15)),
                                                    Expanded(
                                                      child: Container(
                                                          width: 80,
                                                          child: Text(
                                                            (snapshot.data?.paymentDate == '') ? 'Unpaid':'Paid',
                                                            style: textStyle(
                                                              kColor_dark_text,
                                                              FontWeight.w500,
                                                              17,
                                                            ),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: 15)),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
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
                                                        EdgeInsets.only(left: 15)),
                                                    Expanded(
                                                      child: Container(
                                                          width: 80,
                                                          child: Text(
                                                            'Fname Lname',
                                                            style: textStyle(
                                                              kColor_dark_text,
                                                              FontWeight.w500,
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
                                          onTap: (){
                                            checkInticketData.add(null);
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
                            }
                        )
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    _ticketCheckins(ticketCheckinsUrl);
  }

  final makeBody = Container(
    child: StreamBuilder<List<TicketCheckins>>(
      initialData: [],
      stream: ticketCheckinsArr,
      builder: (context, snapshot){
        print(snapshot.data.length);
        return snapshot.data.length > 0 ?
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: snapshot.data.length,
          padding: EdgeInsets.only(bottom: 20),
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            alignment: Alignment.centerLeft,
                            child: Text(snapshot.data[index].data.dateChecked, style: textStyle(Colors.black26, FontWeight.w400, 16),),
                            height: 30,
                          ),
                        ),
                      ],
                    )
                ),
              ],
            );
          },
        ):
        (apiCallTicketsCheckins.value) ?  Container() : Container(child: Text('No check-in yet', style: textStyle(Colors.black26, FontWeight.w400, 16),),);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 0),
                constraints: BoxConstraints.expand(),
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Container(
                      child:Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                width: 50,
                                child: FlatButton(onPressed: () => Navigator.pop(context), child: Image.asset(ic_back,fit: BoxFit.contain, height: 20, width: 20,)),
                              ),
                              Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(right: 40),
                                    child: Column(
                                      children: <Widget>[
                                        Text('${widget.ticketData.data?.buyerFirst} ${widget.ticketData.data?.buyerLast}', style: textStyle(kColor_dark_text, FontWeight.w500, 21),),
                                        Text((widget.ticketData.data?.customFields.length > 3) ?'${widget.ticketData.data?.customFields[3][1]}':'no entry', style: textStyle(Colors.black26, FontWeight.w400, 15),)
                                      ],
                                    ),
                                  )
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              children: <Widget>[
                                Container(width: 130,child: Text('Stop', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Container(width: 4,child: Text(':', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Expanded(
                                  child: Container(width: 80,child: Text('${widget.ticketData.data?.customFields[0][1]}', style: textStyle(kColor_dark_text, FontWeight.w500, 17,),)),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              children: <Widget>[
                                Container(width: 130,child: Text('Number', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Container(width: 4,child: Text(':', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Expanded(
                                  child: Container(width: 80,child: Text('${widget.ticketData.data?.checksum}', style: textStyle(kColor_dark_text, FontWeight.w500, 17,),)),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              children: <Widget>[
                                Container(width: 130,child: Text('Payment Status', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Container(width: 4,child: Text(':', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Expanded(
                                  child: Container(width: 80,child: Text( (widget.ticketData.data?.paymentDate == '') ? 'Unpaid':'Paid', style: textStyle(kColor_dark_text, FontWeight.w500, 17,),)),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              children: <Widget>[
                                Container(width: 130,child: Text('Purchased', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Container(width: 4,child: Text(':', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Expanded(
                                  child: Container(width: 80,child: Text('${widget.ticketData.data?.paymentDate}', style: textStyle(kColor_dark_text, FontWeight.w500, 17,),)),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 15)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              children: <Widget>[
                                Container(width: 130,child: Text('Buyer Name', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Container(width: 4,child: Text(':', style: textStyle(Colors.black45, FontWeight.w500, 17,),)),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Expanded(
                                  child: Container(width: 80,child: Text((widget.ticketData.data?.customFields.length > 1) ?'${widget.ticketData.data?.customFields[1][1]}':'', style: textStyle(kColor_dark_text, FontWeight.w500, 17,),)),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 25)),
                          Container(alignment: Alignment.center,child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Checkins', style: textStyle(kColor_dark_text, FontWeight.w500, 21,),),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 5),),
                              StreamBuilder<bool>(
                                initialData: false,
                                stream: apiCallTicketsCheckins,
                                builder: (context, snapshot){
                                  return snapshot.data ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            kColor_green_theme)),
                                  ) : Container();
                                },
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                    Expanded(child: makeBody),
                    Padding(padding: EdgeInsets.only(bottom: 20)),
                    GestureDetector(
                      onTap: (){
                        _showModal(context);
                        checksum.add(widget.ticketData.data?.checksum);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kColor_green_theme,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child:Text(
                          'CHECK-IN',
                          style:
                          textStyle(Colors.white, FontWeight.normal, 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
