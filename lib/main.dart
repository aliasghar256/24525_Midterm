import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

//Defining the Class for an individual Mission Post
class missionEntry {
  //Needed to add these as I was facing an infinite loading error.
  final String? mission_name;
  final String? mission_id;
  final List<String>? manufacturers;
  final List<String>? payload_ids;
  final String? wikipedia;
  final String? website;
  final String? twitter;
  final String? description;

  const missionEntry({
    required this.mission_name,
    required this.mission_id,
    required this.manufacturers,
    required this.payload_ids,
    required this.wikipedia,
    required this.website,
    required this.twitter,
    required this.description,
  });
  factory missionEntry.fromJson(Map<String, dynamic> json) {
    return missionEntry(
      mission_name: json['mission_name'],
      mission_id: json['mission_id'],
      manufacturers: json['manufacturers'].cast<String>(),
      payload_ids: json['payload_ids'].cast<String>(),
      wikipedia: json['wikipedia'],
      website: json['website'],
      twitter: json['twitter'],
      description: json['description'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Missions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MissionPage(title: 'Space Missions'),
    );
  }
}

class MissionPage extends StatefulWidget {
  const MissionPage({super.key, required this.title});

  final String title;

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  List<missionEntry> missionList = [];
  bool isLoading = true;

  Future<List<missionEntry>> fetchMissions() async {
    final response =
        await http.get(Uri.parse('https://api.spacexdata.com/v3/missions'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      isLoading = false;
      missionList = jsonResponse
          .map((mission) => missionEntry.fromJson(mission))
          .toList();
      return (missionList);
    } else {
      throw Exception('Error Loading missions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.green[900],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        body: Center(
            child: FutureBuilder<List<missionEntry>>(
                future: fetchMissions(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return ListView.builder(
                      itemCount: snap.data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.all(8),
                            child:
                                MissionPost(missionentry: snap.data![index]));
                      },
                    );
                  } else if (snap.hasError) {
                    return Text('Error Loading Missions');
                  }
                  return CircularProgressIndicator();
                })));
  }

  // Widget missionListWidget() {
  //   return ListView.builder(
  //     itemCount: missionList.length,
  //     itemBuilder: (context, index) {
  //       return Container(
  //           margin: EdgeInsets.all(8),
  //           child: MissionPost(missionentry: missionList[index]));
  //     },
  //   );
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchMissions();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Space Missions'),
  //       backgroundColor: Colors.green[900],
  //       titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  //     ),
  //     body: isLoading
  //         ? Center(child: CircularProgressIndicator())
  //         : missionListWidget(),
  //   );
  // }
}

//We make a stateful mission post as it's state can change depending upon the pressing of a button.
class MissionPost extends StatefulWidget {
  final missionEntry missionentry;
  const MissionPost({super.key, required this.missionentry});

  @override
  State<MissionPost> createState() => _MissionPostState();
}

//We now assemble the composition of the mission post.
//Since I need rounded corners and a shadow I use card
class _MissionPostState extends State<MissionPost> {
  bool viewMoreClicked = false;
  //Random Color Function
  // Function to generate a random color
  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${widget.missionentry.mission_name}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 7), // Spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    "${widget.missionentry.description}",
                    overflow: viewMoreClicked
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      viewMoreClicked = !viewMoreClicked;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Use min size for the row
                    children: [
                      // Icon based on expanded state
                      Icon(
                        viewMoreClicked
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.green,
                      ),
                      // Text based on expanded state
                      Text(
                        viewMoreClicked ? 'Less' : 'More',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ],
            ), // Spacing

            // Payload IDs Section (Wrap with pill-shaped containers)
            if (widget.missionentry.payload_ids != null &&
                widget.missionentry.payload_ids!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center the Wrap containing the pills
                  Center(
                    child: Wrap(
                      spacing: 8.0, // Space between pills
                      runSpacing: 4.0, // Space between lines
                      children: widget.missionentry.payload_ids!.map((id) {
                        final color = getRandomColor(); // Get random color
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0), // Padding for pill shape
                          decoration: BoxDecoration(
                            color: color, // Background color
                            borderRadius: BorderRadius.circular(
                                20.0), // Rounded corners for pill shape
                          ),
                          child: Text(
                            id,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600), // Text color
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
