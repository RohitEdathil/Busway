import 'package:busway/components/route_card.dart';
import 'package:busway/components/wide_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RouteSearch extends StatefulWidget {
  const RouteSearch({Key? key}) : super(key: key);

  @override
  State<RouteSearch> createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final db = FirebaseFirestore.instance;
  bool _isSearching = false;
  String error = '';
  List<DocumentReference> results = [];
  void _search() async {
    setState(() {
      _isSearching = true;
      error = '';
      results = [];
    });
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      setState(() {
        error = 'Both fields are required';
        _isSearching = false;
      });
      return;
    }

    if (_fromController.text == _toController.text) {
      setState(() {
        error = 'From and To cannot be the same';
        _isSearching = false;
      });
      return;
    }
    final from = await db
        .collection('stops')
        .where("name", isEqualTo: _fromController.text.trim().toLowerCase())
        .get();
    final to = await db
        .collection('stops')
        .where("name", isEqualTo: _toController.text.trim().toLowerCase())
        .get();
    if (from.docs.isEmpty || to.docs.isEmpty) {
      setState(() {
        _isSearching = false;
        error = 'Unknown stop';
      });
      return;
    }
    final fromRef = from.docs[0].reference;
    final toRef = to.docs[0].reference;
    final routeResult = await db
        .collection('routes')
        .where('stops', arrayContains: fromRef)
        .get();

    final tempResult = <DocumentReference>[];
    for (final route in routeResult.docs) {
      final stops = route.data()['stops'] as List<dynamic>;
      if (stops.contains(toRef) &&
          stops.indexOf(fromRef) < stops.indexOf(toRef)) {
        tempResult.add(route.reference);
      }
    }

    if (tempResult.isEmpty) {
      setState(() {
        _isSearching = false;
        error = 'No routes found';
      });
      return;
    }
    setState(() {
      results = tempResult;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Text(
                "Search for routes between bus stops",
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                  label: Text("From"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                  label: Text("To"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _isSearching
                ? Shimmer.fromColors(
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    baseColor: Colors.white,
                    highlightColor: Colors.grey.shade200)
                : WideButton(callback: _search, text: "Find Routes"),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
            ListView(
              children: [
                for (var result in results)
                  RouteCard(route: result, key: Key(result.id))
              ],
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            )
          ],
        ),
      ),
    );
  }
}
