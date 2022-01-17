import 'package:busway_admin/components/route_card.dart';
import 'package:busway_admin/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseFirestore db;
  late final User user;
  DocumentSnapshot? data;
  DocumentSnapshot? userData;
  int? selected = -1;
  @override
  initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    user = FirebaseAuth.instance.currentUser!;
  }

  Future<bool> _fetch() async {
    if (userData != null) {
      return true;
    }
    userData =
        (await db.collection('users').where('id', isEqualTo: user.uid).get())
            .docs[0];
    data = await userData!["bus"].get();
    return true;
  }

  _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(PageTransition(
        child: LoginScreen(), type: PageTransitionType.leftToRightWithFade));
  }

  _selectedCallback(bool value, int index) async {
    print(value);
    print(index);
    if (selected == -1) {
      await data!["routes"][index].update({"is_active": value});
      setState(() {
        selected = index;
      });
    } else if (selected == null) {
      await data!["routes"][index].update({"is_active": true});
      setState(() {
        selected = index;
      });
    } else if (selected == index) {
      await data!["routes"][index].update({"is_active": false});
      setState(() {
        selected = null;
      });
    } else {
      await data!["routes"][selected].update({"is_active": false});
      await data!["routes"][index].update({"is_active": true});
      setState(() {
        selected = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetch(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 0,
                    title: Text(
                      "Hi, " + userData!["name"],
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.power_settings_new_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          onPressed: () => _logout(),
                        ),
                      )
                    ],
                  ),
                  body: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(30),
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                "Bus Name",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        color: Theme.of(context).cardColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                              ),
                              Divider(
                                height: 30,
                                thickness: 3,
                                color: Theme.of(context).cardColor,
                              ),
                              Text(
                                data!["name"],
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Theme.of(context).cardColor),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return RouteCard(
                              key: ValueKey(index),
                              route: data!["routes"][index],
                              index: index,
                              selected: selected == index,
                              selectedCallback: _selectedCallback,
                            );
                          },
                          itemCount: data!["routes"].length,
                        )
                      ],
                    ),
                  ),
                )
              : const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        });
  }
}
