import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:webview_flutter/webview_flutter.dart';
//global variable
class Drone {
  String name;
  String ip;
  int number;
  List<Route> routes = [];
  Drone(this.name, this.ip, this.number);
}

class Route{
  List<String> storedRoutes= [];
  List<String> parameter =[];
  String name;

  Route(this.name);

}
class Mission {
  List<String> days;
  TimeOfDay time;
  List<String> routeName;
  bool runAllRoutes;
  bool isActive;

  Mission({
    required this.days,
    required this.time,
    required this.routeName,
    this.runAllRoutes = false,
    this.isActive = false,
  });
}
List<Map<String, dynamic>> globalRouteList = [];
List<Mission> missions = [];
int howManyDrone = 0;
int selectedDroneIndex = 0;
String fromWhereToSelectionPage = '';
//List<List<String>> storedRoutes= [];
List<Drone> droneList = [];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DroneHomePage(),
    );
  }
}

class DroneHomePage extends StatefulWidget {
  @override
  _DroneHomePageState createState() => _DroneHomePageState();
}

class _DroneHomePageState extends State<DroneHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dobermann'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to the new page when the add button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DroneRegistrationPage()), // Replace NewPage with your page widget
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? HomePage() : Container(), // Show HomePage for the first tab
      // Add other pages for other tabs here
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Fixed type when you have more than 3 items
        backgroundColor: Colors.black, // Assuming a dark theme from the screenshot
        selectedItemColor: Colors.white, // Color when an item is selected
        unselectedItemColor: Colors.grey, // Color when an item is not selected
        currentIndex: _selectedIndex, // Current index of the selected tab
        onTap: _onItemTapped, // Callback when a tab is tapped
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Material(
              color: Colors.black, // Color for the tab bar
              child: TabBar(
                tabs: [
                  Tab(text: 'My Drone(3)'), // First tab
                  Tab(text: 'Anomaly Records'), // Second tab
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // First tab content: Camera Streams
                  CameraStreamsPage(),
                  // Second tab content: Activity Center
                  ActivityCenterPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CameraStreamsPage extends StatelessWidget {
  /*WebViewController controller = WebViewController()
    ..loadRequest(Uri.parse('http://192.168.1.111:8080/?action=stream'));
  WebViewController controller2 = WebViewController()
    ..loadRequest(Uri.parse('http://192.168.1.111:8081/?action=stream'));
  WebViewController controller3 = WebViewController()
    ..loadRequest(Uri.parse('http://192.168.1.111:8080/?action=stream'));*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // First camera stream block
              buildCameraStreamBlock(context, 'http://192.168.1.111:8080/?action=stream', 'Garden'),
              SizedBox(height: 16),
              // Second camera stream block
              buildCameraStreamBlock(context, 'http://192.168.1.111:8081/?action=stream', 'Kitchen'),
              SizedBox(height: 16),
              // Third camera stream block
              buildCameraStreamBlock(context, 'http://192.168.1.111:8082/?action=stream', 'Living room'),
              // Add more blocks if needed
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCameraStreamBlock(BuildContext context, String streamUrl, String description) {
    // Replace with your actual WebViewController
    //WebViewController controller = WebViewController();
    //controller.loadUrl(streamUrl);

    return Container(
      height: 200, // Specify your desired height
      decoration: BoxDecoration(
        color: Colors.grey,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          /*WebView(
            initialUrl: streamUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              controller = webViewController;
            },
          ),*/
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the page with only this video stream
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleStreamPage(streamUrl: streamUrl, location: description),
                      ),
                    );
                  },
                  child: Text('Manage'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class SingleStreamPage extends StatefulWidget {
  final String streamUrl;
  final String location;
  final int selectedRoute;

  SingleStreamPage({
    required this.streamUrl,
    required this.location,
    this.selectedRoute = 1,
  });

  @override
  _SingleStreamPageState createState() => _SingleStreamPageState();
}

class _SingleStreamPageState extends State<SingleStreamPage> {
  late int _selectedRoute; // Initialize with a late variable
  String _routeName = '';
  @override
  void initState() {
    super.initState();
    _selectedRoute = widget.selectedRoute; // Assign the initial value from the widget
  }

  void _handleRouteSelection(int route) {
    // Update the state with the new route
    setState(() {
      _selectedRoute = route;
    });
  }
  void _handleRouteNameSelection(String routeName) {
    // Update the state with the new route
    setState(() {
      _routeName = routeName;
    });
  }
  @override
  Widget build(BuildContext context) {
    // Replace with your actual WebViewController
    //WebViewController controller = WebViewController();
    //controller.loadUrl(streamUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              height: 200, // Specify your desired height
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          // Route Section
          Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.alt_route),
              title: Text('Route Design'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle tap action for Route
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteDesignPage(onRouteSelected: _handleRouteNameSelection),
                  ),
                );
              },
            ),
          ),
          Text('Selected Route: $_routeName'),
          // Schedule Mission Section
          Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Schedule Mission'),
              subtitle: Text('Set up the mission schedule for your device.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle tap action for Schedule Mission
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleMissionPage(),
                  ),
                );
              },
            ),
          ),
          // Anomaly Records Section
          Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.record_voice_over),
              title: Text('Anomaly Records'),
              subtitle: Text('View the history of detected anomalies.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle tap action for Anomaly Records
              },
            ),
          ),
          // Messages Section (optional based on screenshot)
          Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle tap action
              },
            ),
          ),
        ],
      ),
    );
  }
}
class RouteDesignPage extends StatefulWidget {
  final ValueChanged<String> onRouteSelected;

  RouteDesignPage({required this.onRouteSelected});

  @override
  _RouteDesignPageState createState() => _RouteDesignPageState();
}

class _RouteDesignPageState extends State<RouteDesignPage> {
  int _selectedRoute = 1;
  double _diameter = 10; // Default diameter
  double _altitude = 0; // Default altitude
  bool _testFlightStarted = false;
  void _saveRoute(String routeName) {
    final routeData = {
      'name': routeName,
      'shape': _getRouteShapeName(_selectedRoute),
      'diameter': _diameter,
      'altitude': _altitude
    };

    globalRouteList.add(routeData);
    _debugPrintSavedRoutes();
  }
  void _debugPrintSavedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoutes = prefs.getStringList('savedRoutes') ?? [];
    print("Saved routes: $savedRoutes");
  }
  @override
  String _getRouteShapeName(int routeNumber) {
    switch (routeNumber) {
      case 1:
        return 'Circular';
      case 2:
        return 'Half Circular';
      case 3:
        return 'Triangle';
      case 4:
        return 'Square';
      case 5:
        return 'Diamond';
      default:
        return 'Unknown';
    }
  }
  void _showTestFlightDialog() {
    String routeShape = _getRouteShapeName(_selectedRoute); // Get the name of the selected route shape

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Test Flight'),
          content: Text(
            'The drone is scheduled for a test flight along your predefined route. '
                'It is imperative to verify that the route parameters are accurately configured '
                'to prevent any potential damage to the drone and surrounding property. Ensure '
                'the following settings are correct:\n\n'
                '- Route Shape: $routeShape\n'
                '- Flying Altitude: ${_altitude.toStringAsFixed(1)} meters\n'
                '- Circle Radius: ${_diameter.toStringAsFixed(1)} meters',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Start'),
              onPressed: () {
                setState(() {
                  _testFlightStarted = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _promptRouteName() {
    String routeName = ''; // Temporary variable to store the route name

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Name Your Route'),
          content: TextField(
            onChanged: (value) {
              routeName = value;
            },
            decoration: InputDecoration(hintText: "Enter route name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                if (routeName.isNotEmpty) {
                  widget.onRouteSelected(routeName); // Pass the route name back
                  _saveRoute(routeName);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Route'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text('Diameter: ${_diameter.toStringAsFixed(1)} meters'),
            Slider(
              min: 0,
              max: 10,
              divisions: 10,
              label: _diameter.toStringAsFixed(1),
              value: _diameter,
              onChanged: (double value) {
                setState(() {
                  _diameter = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Altitude: ${_altitude.toStringAsFixed(1)} meters'),
            Slider(
              min: 0,
              max: 5,
              divisions: 5,
              label: _altitude.toStringAsFixed(1),
              value: _altitude,
              onChanged: (double value) {
                setState(() {
                  _altitude = value;
                });
              },
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: CustomPaint(
                  painter: RouteDesignPainter(
                    selectedRoute: _selectedRoute,
                    diameter: _diameter,
                    altitude: _altitude,
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: List.generate(5, (index) {
                return ChoiceChip(
                  label: Text('${index + 1}'),
                  selected: _selectedRoute == index + 1,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedRoute = selected ? index + 1 : _selectedRoute;
                    });
                  },
                );
              }),
            ),
            ElevatedButton(
              onPressed: _showTestFlightDialog,
              child: Text('Test Flight'),
            ),
            ElevatedButton(
              onPressed: _testFlightStarted ? _promptRouteName : null, // Call _promptRouteName on press
              child: Text('Save Route'),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteDesignPainter extends CustomPainter {
  final int selectedRoute;
  final double diameter;
  final double altitude;

  RouteDesignPainter({required this.selectedRoute, required this.diameter, required this.altitude});



  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var center = Offset(size.width / 2, size.height / 2);
    var radius = (size.width / 2) * (diameter / 10); // Calculate radius based on diameter

    switch (selectedRoute) {
      case 1:
        canvas.drawCircle(center, radius, paint);
        break;
      case 2:
        var path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..arcToPoint(
            Offset(center.dx, center.dy + radius),
            radius: Radius.circular(radius),
          );
        canvas.drawPath(path, paint);
        break;
      case 3:
        var path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 4:
        var rect = Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius);
        canvas.drawRect(rect, paint);
        break;
      case 5:
        var path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ScheduleMissionPage extends StatefulWidget {
  @override
  _ScheduleMissionPageState createState() => _ScheduleMissionPageState();
}

class _ScheduleMissionPageState extends State<ScheduleMissionPage> {


  void _addNewMission() async {
    // Open EditMissionPage to create a new Mission
    final Mission? addedMission = await Navigator.push<Mission>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMissionPage(
          mission: Mission(
            days: [],
            time: TimeOfDay.now(),
            routeName: [],
            runAllRoutes: false,
            isActive: false,
          ),
          isNewMission: true, // Indicate that this is a new mission
        ),
      ),
    );

    // Open EditMissionPage with the new empty Mission
    if (addedMission != null) {
      setState(() {
        missions.add(addedMission);
      });
    }
  }

  /*void _editMission(int index) async {
    final updatedMission = await Navigator.of(context).push<Mission>(
      MaterialPageRoute(
        builder: (context) => EditMissionPage(mission: missions[index]),
      ),
    );

    if (updatedMission != null) {
      setState(() {
        missions[index] = updatedMission;
      });
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Missions'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewMission, // Call _addNewMission when the add icon is pressed
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return ListTile(
            title: Text('${mission.days.join(', ')} ${mission.time.format(context)}'),
            subtitle: Text(mission.routeName.join(', ')),
            trailing: Switch(
              value: mission.isActive,
              onChanged: (bool value) {
                setState(() {
                  mission.isActive = value;
                });
              },
            ),
            onTap: () async {
              // Edit an existing mission
              final Mission? updatedMission = await Navigator.push<Mission>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMissionPage(mission: mission, isNewMission: false),
                ),
              );

              if (updatedMission != null) {
                setState(() {
                  missions[index] = updatedMission;
                });
              }
            },
          );
        },
      ),
    );
  }
}
class EditMissionPage extends StatefulWidget {
  final Mission mission;
  final bool isNewMission;

  EditMissionPage({required this.mission, required this.isNewMission});

  @override
  _EditMissionPageState createState() => _EditMissionPageState();
}


class _EditMissionPageState extends State<EditMissionPage> {
  late List<String> _days;
  late TimeOfDay _time;
  late List<String> _routeName;
  late bool _runAllRoutes;
  late bool _isActive;
  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _days = widget.mission.days;
    _time = widget.mission.time;
    _routeName = widget.mission.routeName;
    _runAllRoutes = widget.mission.runAllRoutes;
    _isActive = widget.mission.isActive;
  }
  // Function to show a dialog to select the time
  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }
  void _saveMission() {
    // Create a new Mission object with the current state
    final Mission updatedMission = Mission(
      days: _days,
      time: _time,
      routeName: _routeName,
      runAllRoutes: _runAllRoutes,
      isActive: _isActive,
    );

    // Return the updated mission to the previous page
    Navigator.of(context).pop(updatedMission);
  }
  // Function to show a dialog to select days
  void _selectDays() async {
    // Use a local copy of _days for the dialog's state
    final List<String> localSelectedDays = List<String>.from(_days);

    final List<String>? newSelectedDays = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage the local state for checkboxes within the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Repeat'),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _allDays.map((day) {
                    return CheckboxListTile(
                      title: Text(day),
                      value: localSelectedDays.contains(day),
                      onChanged: (bool? value) {
                        if (value == true) {
                          localSelectedDays.add(day);
                        } else {
                          localSelectedDays.remove(day);
                        }
                        // Update the local state within the dialog
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog without saving changes
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () {
                    Navigator.of(context).pop(localSelectedDays); // Return the selected days
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newSelectedDays != null) {
      setState(() {
        _days = newSelectedDays; // Update the main state with the new selections
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              // Close the edit page
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Start Time'),
              trailing: Text('${_time.format(context)}'),
              onTap: _selectTime,
            ),
            ListTile(
              title: Text('Repeat'),
              trailing: Text(_days.join(', ')),
              onTap: _selectDays,
            ),
            SwitchListTile(
              title: Text('Run All Routes'),
              value: _runAllRoutes,
              onChanged: (bool value) {
                setState(() {
                  _runAllRoutes = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('My Routes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._buildRouteList(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Save the edited mission details
                  _saveMission();
                  //Navigator.of(context).pop();
                },
                child: Text('Save Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRouteList() {
    // Assuming globalRouteList is available with the list of routes
    return globalRouteList.map((route) {
      bool isSelected = _routeName.contains(route['name']);
      return CheckboxListTile(
        title: Text(route['name']),
        value: isSelected,
        onChanged: _runAllRoutes ? null : (bool? value) {
          setState(() {
            if (value == true) {
              _routeName.add(route['name']);
            } else {
              _routeName.remove(route['name']);
            }
          });
        },
      );
    }).toList();
  }
}
class SelectDaysPage extends StatefulWidget {
  final List<String> selectedDays;

  SelectDaysPage({required this.selectedDays});

  @override
  _SelectDaysPageState createState() => _SelectDaysPageState();
}

class _SelectDaysPageState extends State<SelectDaysPage> {
  late List<String> _selectedDays;
  final List<String> _allDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.selectedDays.toList();
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _saveAndExit() {
    Navigator.pop(context, _selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repeat'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveAndExit,
          ),
        ],
      ),
      body: ListView(
        children: _allDays.map((day) {
          return CheckboxListTile(
            title: Text(day),
            value: _selectedDays.contains(day),
            onChanged: (_) => _toggleDay(day),
          );
        }).toList(),
      ),
    );
  }
}

// Add other page classes or widgets here if needed
class DroneRegistrationPage extends StatefulWidget {
  @override
  _DroneRegistrationPageState createState() => _DroneRegistrationPageState();
}

class _DroneRegistrationPageState extends State<DroneRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();

  void _showRegistrationSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered the drone.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _submitData() {
    howManyDrone++;
    setState(() {
      droneList.add(Drone(_nameController.text, _ipController.text, howManyDrone-1));
    });
    /*for (var drone in droneList) {
      print("Drone Name: ${drone.name}, IP: ${drone.ip}");
    }*/
    Navigator.pop(context);
    _showRegistrationSuccessDialog(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drone Registration Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Drone Name',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  hintText: 'Enter Drone IP',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ActivityCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Added SafeArea to avoid overlap with the status bar
        child: SingleChildScrollView( // Added SingleChildScrollView for scrollable content
          child: Column(
            children: [
              // First block
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/image1.jpg',
                      width: 220,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Time:\n2023-12-1 18:50\nRoute:\nTest route 1\n',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16), // Add space between blocks

              // Second block
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/image2.jpg',
                      width: 220,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Time:\n2023-12-2 14:30\nRoute:\nTest route 2\n',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Third block
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/image3.jpg',
                      width: 220,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Time:\n2023-12-3 09:30\nRoute:\nTest route 3\n',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
