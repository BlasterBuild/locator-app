import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Person {
  final String name;
  final String photoUrl; // Photo URL (can be a network or asset image)

  const Person(this.name, this.photoUrl);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const List<Person> people = [
    Person('John Doe', 'assets/images/harshu.jpeg'),
    Person('Jane Smith', 'assets/images/harshu.jpeg'),
    Person('Alex Johnson', 'assets/images/harshu.jpeg'),
  ];
  Location _locationController = new Location();
  LatLng? _currentP = null;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.cyan, // Changing color of AppBar
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: Container( // Container for sidebar icon
            margin: const EdgeInsets.all(10), // Inserting image of sidebar icon as SVG
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset('assets/icons/More Square.svg'), // Sidebar icon in SVG format
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Header'),
              decoration: BoxDecoration(color: Colors.cyan,
              ),
            ),
            ListTile(
              title: const Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          var person = people[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(person.photoUrl),
                  //? AssetImage(person['image']) // Use person's image if available
                  //: AssetImage('assets/images/default_user.png'), // Placeholder image
              backgroundColor: Colors.grey[200], // Set a background color if needed
            ),
            title: Text(person.name),
            onTap: () async{
              // Handle tap on each person
              // Navigate to the map screen and pass the person's name
              final position = await _getCurrentPosition();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(person: person, position: position),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Future<LatLng?> _getCurrentPosition() async {
    bool _serviceEnabled;
    PermissionStatus _permission;

    // Check if location services are enabled
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permission
    _permission = await _locationController.hasPermission();
    if (_permission == PermissionStatus.denied) {
      _permission = await _locationController.requestPermission();
      if (_permission != PermissionStatus.granted) {
        return Future.error('Location permission denied.');
      }
    }

    if (_permission == PermissionStatus.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    LatLng current = LatLng(29.34447, 79.56336);
    // Get the current position
    _locationController.onLocationChanged.listen((LocationData currentLocation){
      if(currentLocation.latitude != null && currentLocation.longitude != null)
        {
          setState(() {
            _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            current = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            print(_currentP);
          });
        }
    });
    return _currentP;
  }

}
class MapScreen extends StatelessWidget {
  final Person person;
  final LatLng? position;

  MapScreen({required this.person, required this.position});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location of ${person.name}'),
      ),
      body: position == null
          ? const Center(
        child: Text('Loading....'),
      )
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position!,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId(person.name),
            position: position!,
            infoWindow: InfoWindow(title: person.name),
          ),
        },
      ),
    );
  }
}



