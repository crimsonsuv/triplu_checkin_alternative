import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/assets.dart';
import '../../utils/extensions.dart';
import '../../models/event_essentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tickets_info.dart';
import '../../services/services.dart';
import 'package:rxdart/rxdart.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  ListScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String apiKey = '';
  List<TicketInfo> unfilteredData = [];

  //final pageCount = new BehaviorSubject<int>();
  static final listApIURL = new BehaviorSubject<String>(seedValue: '');
  static final infoApIURL = new BehaviorSubject<String>(seedValue: '');
  final apiCall = new BehaviorSubject<bool>(seedValue: false);
  final ticketInforArr = BehaviorSubject<List<TicketInfo>>(seedValue: []);
  final searchText = BehaviorSubject<String>(seedValue: '');

  // Observable<int> get pageCountObsrvr => pageCount.stream;
  Observable<String> get listApiUrlObsrvr => listApIURL.stream;

  Observable<String> get searchTextObsrvr => searchText.stream;

  @override
  void dispose() async {
    super.dispose();
    await listApIURL.drain();
    listApIURL.close();
    await infoApIURL.drain();
    infoApIURL.close();
    await apiCall.drain();
    apiCall.close();
    await ticketInforArr.drain();
    ticketInforArr.close();
    await searchText.drain();
    searchText.close();
  }

  _ticketInfo(String url) {
    apiCall.add(true);
    if (url == '') {
      return;
    }
    ticketInfo(url, context).then((List<TicketInfo> data) {
      apiCall.add(false);
      data.removeLast();
      if (data.length > 0) {
        var fetchedData = ticketInforArr.value;
        fetchedData.addAll(data);
        ticketInforArr.add(fetchedData);
        unfilteredData = ticketInforArr.value;
      } else {}
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    ticketInforArr.add([]);

    listApiUrlObsrvr.listen((url) {
      if (url != null && url.length > 0) {
        _ticketInfo(url);
      }
    });

    searchTextObsrvr.listen((searchText) {
      if (searchText.length > 0) {
        ticketInforArr.add(unfilteredData
            .where((data) =>
        data.data.buyerFirst
            .toLowerCase()
            .contains(searchText.toLowerCase()) ||
            data.data.buyerLast
                .toLowerCase()
                .contains(searchText.toLowerCase()) ||
            data.data.checksum
                .toLowerCase()
                .contains(searchText.toLowerCase()))
            .toList());
      } else {
        ticketInforArr.add(unfilteredData);
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      apiKey = prefs.getString('api_key');
      String infoUrl = "https://www.triply.fun/tc-api/$apiKey/event_essentials";
      infoApIURL.add(infoUrl);

      String listUrl =
          "https://www.triply.fun/tc-api/$apiKey/tickets_info/150/1/";
      listApIURL.add(listUrl);

      // pageCountObsrvr.listen((page) {
      //String listUrl =
      // "https://www.triply.fun/tc-api/$apiKey/tickets_info/150/$page/";
      //});
      //pageCount.add(1);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0),
            constraints: BoxConstraints.expand(),
            child: Column(
              children: <Widget>[
                Container(
                  height: 141,
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 40)),
                      StreamBuilder(
                          initialData: false,
                          stream: apiCall,
                          builder: (context, snapshot) {
                            return snapshot.data
                                ? Center(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        kColor_green_theme)),
                              ),
                            )
                                : Container(
                              margin:
                              EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerLeft,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: kColor_green_theme,
                                      width: 1.0)),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: TextField(
                                      autocorrect: false,
                                      onChanged: (value) {
                                        searchText.add(value);
                                      },
                                      style: textStyle(Colors.black38,
                                          FontWeight.w500, 16),
                                      decoration: new InputDecoration(
                                        hintText: 'Search...',
                                        hintStyle: textStyle(
                                            Colors.black38,
                                            FontWeight.w600,
                                            16),
                                        border: InputBorder.none,
                                        contentPadding:
                                        const EdgeInsets.all(10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      Padding(padding: EdgeInsets.only(top: 15)),
                      StreamBuilder(
                          initialData: '',
                          stream: infoApIURL,
                          builder: (context, snapshotVal) {
                            return FutureBuilder<EventEssentials>(
                                future:
                                eventEssentials(snapshotVal.data, context),
                                builder: (context, snapshot) {
                                  return (snapshot.hasData)
                                      ? Text(
                                    "${snapshot.data?.checkedTickets}/${snapshot.data?.soldTickets}",
                                    style: textStyle(kColor_dark_text,
                                        FontWeight.w500, 16),
                                  )
                                      : Text("");
                                });
                          }),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: StreamBuilder<List<TicketInfo>>(
                            initialData: [],
                            stream: ticketInforArr,
                            builder: (context, snapshot) {
                              return (snapshot.data != null)
                                  ? Container(
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: 20),
                                    itemBuilder: (context, int index) {
//                                      if (index == snapshot.data.length - 1 && searchText.value.length == 0){
//                                        pageCount.add(pageCount.value + 1);
//                                      }
                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            height: 1,
                                            color: Colors.black12,
                                          ),
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailScreen(
                                                            ticketData:
                                                            snapshot.data[
                                                            index]),
                                                  ));
                                            },
                                            child: Container(
                                                padding:
                                                EdgeInsets.all(0),
                                                margin: EdgeInsets.all(0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            20),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "${snapshot.data[index]?.data?.buyerFirst} ${snapshot.data[index]?.data?.buyerLast}",
                                                          style: textStyle(
                                                              kColor_dark_text,
                                                              FontWeight
                                                                  .w400,
                                                              16),
                                                        ),
                                                        height: 74,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      child: Image.asset(
                                                        ic_forward,
                                                        fit: BoxFit
                                                            .contain,
                                                        height: 10,
                                                        width: 6,
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(
                                                            left: 10))
                                                  ],
                                                )),
                                          ),
                                        ],
                                      );
                                    },
                                    itemCount: snapshot.data.length),
                              )
                                  : Container();
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
