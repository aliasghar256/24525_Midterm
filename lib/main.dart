import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Missions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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
    final response = await http.get(Uri.parse(
        'https://api.spacexdata.com/v3/missions')); //API endpoint for SpaceX missions
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      setState(() {
        missionList = jsonResponse
            .map((launch) => missionEntry.fromJson(launch))
            .toList();
        isLoading = false;
      });
      return jsonResponse
          .map((mission) => new missionEntry.fromJson(mission))
          .toList();
    } else {
      throw Exception('Error Loading missions');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(),
      ),
    );
  }
}

//Defining the Class for an individual Mission Post
class missionEntry {
  final String mission_name;
  final String mission_id;
  final List<String> manufacturers;
  final List<String> payload_ids;
  final String wikipedia;
  final String website;
  final String twitter;
  final String description;

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

//We make a stateful mission post as it's state can change depending upon the pressing of a button.
class MissionPost extends StatefulWidget {
  const MissionPost({super.key});

  @override
  State<MissionPost> createState() => _MissionPostState();
}

//We now assemble the composition of the mission post.
//Since I need rounded corners and a shadow I use card
class _MissionPostState extends State<MissionPost> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mission Name
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${widget.missionEntry.missionName}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8), // Spacing

            // Mission Description
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    "${widget.missionEntry.description}",
                    overflow:
                        expanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                      expanded = !expanded;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Use min size for the row
                    children: [
                      // Icon based on expanded state
                      Icon(
                        expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      // Text based on expanded state
                      Text(
                        expanded ? 'Read Less' : 'Read More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  color: Colors.teal[900],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ],
            ), // Spacing

            // Payload IDs Section (Wrap with pill-shaped containers)
            if (widget.missionEntry.payloadIds != null &&
                widget.missionEntry.payloadIds!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payload IDs:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  // Center the Wrap containing the pills
                  Center(
                    child: Wrap(
                      spacing: 8.0, // Space between pills
                      runSpacing: 4.0, // Space between lines
                      children: widget.missionEntry.payloadIds!.map((id) {
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
                            style: TextStyle(color: Colors.white), // Text color
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
