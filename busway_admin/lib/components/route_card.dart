import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RouteCard extends StatefulWidget {
  final DocumentReference route;
  final int index;
  final Function(bool, int) selectedCallback;
  final bool selected;
  const RouteCard({
    Key? key,
    required this.route,
    required this.index,
    required this.selectedCallback,
    required this.selected,
  }) : super(key: key);

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  DocumentSnapshot? routeData;

  final List<int> times = [];
  List at = [];
  List<DocumentSnapshot> stops = [];
  Future<bool> _fetch() async {
    if (routeData != null) {
      return true;
    }
    routeData = await widget.route.get();
    for (var i = 0; i < routeData!["times"].length; i++) {
      times.add(routeData!["times"][i]);
      stops.add(await routeData!["stops"][i].get());
    }
    at = routeData!['at'];
    if (routeData!["is_active"]) {
      widget.selectedCallback(true, widget.index);
    }
    return true;
  }

  String toTime(int time) {
    final hour = time ~/ 60;
    final minute = time % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  _next() async {
    if (at.length == 1) {
      if (at[0] == times.length - 1) {
        await routeData!.reference.update({
          "at": [0]
        });
        setState(() {
          at[0] = 0;
        });
      } else {
        await routeData!.reference.update({
          "at": [at[0]] + [at[0] + 1]
        });
        setState(() {
          at = [at[0]] + [at[0] + 1];
        });
      }
    } else {
      await routeData!.reference.update({
        "at": [at[1]]
      });
      setState(() {
        at = [at[1]];
      });
    }
  }

  _previous() async {
    if (at.length == 1) {
      if (at[0] == 0) {
        await routeData!.reference.update({
          "at": [times.length - 1]
        });
        setState(() {
          at = [times.length - 1];
        });
      } else {
        await routeData!.reference.update({
          "at": [at[0] - 1] + [at[0]]
        });
        setState(() {
          at = [at[0] - 1] + [at[0]];
        });
      }
    } else {
      await routeData!.reference.update({
        "at": [at[0]]
      });
      setState(() {
        at = [at[0]];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: FutureBuilder<bool>(
          future: _fetch(),
          builder: (context, snapshot) {
            // print(snapshot.error);
            if (snapshot.hasData) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: widget.selected
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 35,
                              ),
                              IconButton(
                                  onPressed: _previous,
                                  icon: Icon(Icons.arrow_drop_up)),
                              IconButton(
                                  onPressed: _next,
                                  icon: Icon(Icons.arrow_drop_down))
                            ],
                          )
                        : SizedBox(),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(
                      fillColor: MaterialStateProperty.all(Colors.deepPurple),
                      value: widget.selected,
                      onChanged: (value) {
                        setState(() {
                          widget.selectedCallback(value!, widget.index);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Card(
                      elevation: 5,
                      color: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.all(15),
                        collapsedIconColor: Colors.yellow,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(toTime(times.first),
                                    style: const TextStyle(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 20),
                                Text(stops.first['name'],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: const [
                                SizedBox(
                                  width: 60,
                                  height: 45,
                                ),
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(toTime(times.last),
                                    style: const TextStyle(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 20),
                                Text(stops.last['name'],
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        childrenPadding: const EdgeInsets.all(20),
                        children: generateStops,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const LoadingPlaceHolder();
          }),
    );
  }

  List<Widget> get generateStops {
    return [
      for (var i = 0; i < stops.length; i++)
        Column(
          children: [
            Row(
              children: [
                Text(
                  toTime(times[i]),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.circle,
                    color: () {
                      if (at[0] == i) {
                        if (at.length == 1) {
                          return Colors.lightGreen;
                        } else {
                          return Colors.white;
                        }
                      } else if (at[0] > i) {
                        return Colors.white;
                      } else {
                        return Colors.yellow;
                      }
                    }(),
                    size: 9,
                  ),
                ),
                Text(
                  stops[i]['name'],
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            i == times.length - 1
                ? SizedBox()
                : Row(
                    children: [
                      const SizedBox(width: 48),
                      SizedBox(
                        width: 2,
                        height: 20,
                        child: Container(
                          color: () {
                            if (at[0] == i) {
                              if (at.length == 2) {
                                return Colors.lightGreen;
                              } else {
                                return Colors.yellow;
                              }
                            } else if (at[0] > i) {
                              return Colors.white;
                            } else {
                              return Colors.yellow;
                            }
                          }(),
                        ),
                      ),
                    ],
                  )
          ],
        )
    ];
  }
}

class LoadingPlaceHolder extends StatelessWidget {
  const LoadingPlaceHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        child: Container(
          height: 120,
          width: 10,
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(10)),
        ),
        baseColor: Colors.white,
        highlightColor: Colors.grey.shade200);
  }
}
