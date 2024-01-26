import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
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
class MissionRoutine {
  List<String> days;
  List<String> frequency;
  TimeOfDay time;
  TimeOfDay endTime;
  List<String> routeName;
  bool runAllRoutes;
  bool isActive;

  MissionRoutine({
    required this.days,
    required this.frequency,
    required this.time,
    required this.endTime,
    required this.routeName,
    this.runAllRoutes = false,
    this.isActive = false,
  });
}
List<Map<String, dynamic>> globalRouteList = [];
List<Mission> missionsSingle = [];
List<MissionRoutine> missionsRoutine = [];
int howManyDrone = 0;
int selectedDroneIndex = 0;
String fromWhereToSelectionPage = '';
//List<List<String>> storedRoutes= [];
List<Drone> droneList = [];

Future<ui.Image> loadImage(String assetPath) async {
  ByteData data = await rootBundle.load(assetPath);
  Uint8List bytes = data.buffer.asUint8List();
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}


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
              title: Text('Create New Route'),
              subtitle: Text('Latest route created: $_routeName'),
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
          // Start Mission Card
          Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.flight),
              title: Text('Start Mission'),
              subtitle: Text('Start a flight mission from your saved route.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle tap action for Route
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedRoutesPage(),
                  ),
                );
              },
            ),
          ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnomalyRecordPage(),
                  ),
                );
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

class _RouteDesignPageState extends State<RouteDesignPage> with SingleTickerProviderStateMixin {
  int _selectedRoute = 1;
  double _diameter = 10; // Default diameter
  double _altitude = 0; // Default altitude
  bool _testFlightStarted = false;
  late final Future<ui.Image> landmarkImageFuture;
  late final Future<ui.Image> chargingStationImageFuture;
  late AnimationController _animationController;
  late Animation<double> _animation;
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
  }

  String _getRouteShapeName(int routeNumber) {
    switch (routeNumber) {
      case 1:
        return 'Circle';
      case 2:
        return 'Pie slice';
      case 3:
        return 'Triangle';
      case 4:
        return 'Square';
      case 5:
        return 'Cross';
      case 6:
        return 'Straight';
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
          title: const Text('Test Flight'),
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
  @override
  void initState() {
    super.initState();
    landmarkImageFuture = loadImage('assets/images/drone1.png');
    chargingStationImageFuture = loadImage('assets/images/chargingStation.png');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Adjust duration to control the speed
    )..repeat();

    /*_animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {}); // Causes the widget to rebuild on animation tick
      });*/
    /*_animationController.addListener(() {
      setState(() {});
    });*/
  }

  /*void startAnimation() {
    _animationController.forward();
  }

  void stopAnimation() {
    _animationController.stop();
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Route'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: FutureBuilder<List<ui.Image>>(
                  future: Future.wait([landmarkImageFuture, chargingStationImageFuture]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Loading indicator while waiting for images
                    }
                    if (snapshot.hasError) {
                      return Text("Error loading images: ${snapshot.error}");
                    }
                    if (snapshot.hasData) {
                      // Images are loaded, now passing them to the CustomPainter
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: RouteDesignPainter(
                              selectedRoute: _selectedRoute,
                              diameter: _diameter,
                              altitude: _altitude,
                              landmarkImage: snapshot.data![0],
                              chargingStationImage: snapshot.data![1],
                              progress: _animationController.value,
                              sizeIndex: 1,
                            ),
                          );
                        },
                      );
                    } else {
                      // This should not happen if images are loaded correctly
                      return Text("Unknown error");
                    }
                  },
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: List.generate(6, (index) {
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
              child: const Text('Test Flight'),
            ),
            ElevatedButton(
              onPressed: _testFlightStarted ? _promptRouteName : null, // Call _promptRouteName on press
              child: const Text('Save Route'),
            ),
            /*ElevatedButton(
              onPressed: startAnimation,
              child: Text('Start Animation'),
            ),
            ElevatedButton(
              onPressed: stopAnimation,
              child: Text('Stop Animation'),
            ),*/
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class RouteDesignPainter extends CustomPainter {
  final int selectedRoute;
  final double diameter;
  final double altitude;
  final ui.Image landmarkImage; // Assuming you have a ui.Image for the landmark
  final ui.Image chargingStationImage;
  final double progress; // A value between 0.0 and 1.0 representing the progress along the path
  final int sizeIndex;
  RouteDesignPainter({required this.selectedRoute, required this.diameter, required this.altitude, required this.landmarkImage,required this.chargingStationImage,
    required this.progress, required this.sizeIndex});




  Offset _calculateImagePosition(Size size, Offset center, double radius) {
    // This method should calculate the exact position where you want to draw the image.
    // For simplicity, here we're using the center of the canvas which might need adjustment.
    return center;
  }

  void _drawChargingStationImage(Canvas canvas, Offset position) {
    final srcRect = Rect.fromLTWH(0, 0, chargingStationImage.width.toDouble(), chargingStationImage.height.toDouble());
    final dstRect = sizeIndex == 0? Rect.fromCenter(center: position, width: 50.0, height: 50.0) : Rect.fromCenter(center: position, width: 100.0, height: 100.0);  // Adjust size as needed

    canvas.drawImageRect(chargingStationImage, srcRect, dstRect, Paint());
  }
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var center = Offset(size.width / 2, size.height / 2);
    // change "12" to adjust the ratio between painting and the edge of the area. "10" reach the edge
    var radius = (size.width / 2) * (diameter / 12); // Calculate radius based on diameter
    var centerTop = Offset(size.width / 2, size.height / 2 - radius);
    Path path;
    Offset imagePosition = _calculateImagePosition(size, center, radius);
    Offset imagePositionForShapeSix = _calculateImagePosition(size, centerTop, radius);
    // change "12" to adjust the ratio between painting and the edge of the area. "10" reach the edge
    final double sectorRadius = size.width / 2 * (diameter / 12); // Use diameter for the sector radius
    const double startAngle = 15 * (math.pi / 180); // Start angle for the sector (convert degrees to radians)
    const double sweepAngle = 150 * (math.pi / 180); // Sweep angle for the sector (convert degrees to radians)


    switch (selectedRoute) {
      case 1:
        //circle code
        path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
        canvas.drawPath(path, paint);
        _drawChargingStationImage(canvas, imagePosition);
        break;
      case 2:
        //half Circle code
        /*path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..arcToPoint(
            Offset(center.dx, center.dy + radius),
            radius: Radius.circular(radius),
          );
        canvas.drawPath(path, paint);
        _drawChargingStationImage(canvas, imagePosition);*/
        //pie slice code
        path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: sectorRadius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close(); // This will create a line back to the center to complete the sector

        // Draw the sector
        canvas.drawPath(path, paint);

        // Draw the charging station in the center of the sector
        /*final Offset chargingStationPosition = Offset(
            (size.width - chargingStationWidth) / 2,
            (size.height - chargingStationHeight) / 2
        );
        final Rect chargingStationRect = Rect.fromLTWH(
            chargingStationPosition.dx,
            chargingStationPosition.dy,
            chargingStationWidth,
            chargingStationHeight
        );
        // Define the source rectangle from the image
        final Rect src = Rect.fromLTWH(0, 0, chargingStationImage.width.toDouble(), chargingStationImage.height.toDouble());

        // Draw the resized image
        canvas.drawImageRect(chargingStationImage, src, chargingStationRect, Paint());*/
        _drawChargingStationImage(canvas, imagePosition);
        break;
      case 3:
        //triangle code
        path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        _drawChargingStationImage(canvas, imagePosition);
        break;
      case 4:
        //square code
        path = Path()
          ..addRect(Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius));
        canvas.drawPath(path, paint);
        _drawChargingStationImage(canvas, imagePosition);
        break;
      case 5:
        //diamond code
        /*path = Path()

          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);*/
        //cross code
        path = Path()
          ..moveTo(center.dx - radius, center.dy)
        ..lineTo(center.dx + radius, center.dy)
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx, center.dy + radius);

        // Draw the path
        canvas.drawPath(path, paint);
        _drawChargingStationImage(canvas, imagePosition);

        // Calculate landmark position based on animation progress
        Offset landmarkPosition;
        double segmentLength = 1.0 / 8.0; // Each segment is 1/8th of the total animation

        if (progress <= segmentLength) {
          // Move left from center
          double x = center.dx - radius * progress / segmentLength;
          landmarkPosition = Offset(x, center.dy);
        } else if (progress <= 2 * segmentLength) {
          // Move right to center from left
          double x = center.dx - radius + radius * (progress - segmentLength) / segmentLength;
          landmarkPosition = Offset(x, center.dy);
        } else if (progress <= 3 * segmentLength) {
          // Move right from center
          double x = center.dx + radius * (progress - 2 * segmentLength) / segmentLength;
          landmarkPosition = Offset(x, center.dy);
        } else if (progress <= 4 * segmentLength) {
          // Move left to center from right
          double x = center.dx + radius - radius * (progress - 3 * segmentLength) / segmentLength;
          landmarkPosition = Offset(x, center.dy);
        } else if (progress <= 5 * segmentLength) {
          // Move up from center
          double y = center.dy - radius * (progress - 4 * segmentLength) / segmentLength;
          landmarkPosition = Offset(center.dx, y);
        } else if (progress <= 6 * segmentLength) {
          // Move down to center from top
          double y = center.dy - radius + radius * (progress - 5 * segmentLength) / segmentLength;
          landmarkPosition = Offset(center.dx, y);
        } else if (progress <= 7 * segmentLength) {
          // Move down from center
          double y = center.dy + radius * (progress - 6 * segmentLength) / segmentLength;
          landmarkPosition = Offset(center.dx, y);
        } else {
          // Move up to center from bottom
          double y = center.dy + radius - radius * (progress - 7 * segmentLength) / segmentLength;
          landmarkPosition = Offset(center.dx, y);
        }

        // Draw the landmark
        final landmarkSize = Size(50.0, 50.0); // Adjust size as needed
        final Rect landmarkRect = Rect.fromCenter(
          center: landmarkPosition,
          width: landmarkSize.width,
          height: landmarkSize.height,
        );
        final Rect src = Rect.fromLTWH(0, 0, landmarkImage.width.toDouble(), landmarkImage.height.toDouble());
        canvas.drawImageRect(landmarkImage, src, landmarkRect, Paint());
        break;
      case 6:
        path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        _drawChargingStationImage(canvas, imagePositionForShapeSix);
        break;
      default:
        throw 'Route $selectedRoute not recognized';
    }


    // Drawing the landmark along the path except shape 5
    if (path != null && selectedRoute != 5) {
      ui.PathMetric pathMetric = path.computeMetrics().first;
      ui.Tangent? tangent = pathMetric.getTangentForOffset(pathMetric.length * progress);

      if (tangent != null) {
        // Define the source rectangle from the image
        final src = Rect.fromLTWH(0, 0, landmarkImage.width.toDouble(), landmarkImage.height.toDouble());

        // Define the destination rectangle on the canvas
        // Adjust the width and height as needed
        const dstWidth = 50.0;
        const dstHeight = 50.0;
        final dst = Rect.fromCenter(
          center: tangent.position,
          width: dstWidth,
          height: dstHeight,
        );

        // Draw the resized image
        canvas.drawImageRect(landmarkImage, src, dst, Paint());
      }
    }
  }

  @override
  bool shouldRepaint(covariant RouteDesignPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.selectedRoute != selectedRoute;
    //return true;
  }
}
class ScheduleMissionPage extends StatefulWidget {
  @override
  _ScheduleMissionPageState createState() => _ScheduleMissionPageState();
}

class _ScheduleMissionPageState extends State<ScheduleMissionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // setState to rebuild the AppBar with the new action icon
      setState(() {});
    }
  }
  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _addSingleFlight() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSingleMissionPage(
          singleFlightMissions: Mission(
            days: [],
            time: TimeOfDay.now(),
            routeName: [],
            runAllRoutes: false,
            isActive: false,
          ),
          isNewMission: true, // This flag is true since we're adding a new mission
        ),
      ),
    ).then((newMission) {
      if (newMission != null) {
        setState(() {
          // Assuming you have a list for single flight missions
          missionsSingle.add(newMission);
        });
      }
    });
  }

  void _addRoutineFlight() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditRoutineMissionPage(
          routineFlightMissions: MissionRoutine(
            days: [],
            frequency: [],
            time: TimeOfDay.now(),
            endTime: TimeOfDay.now(),
            routeName: [],
            runAllRoutes: false,
            isActive: false,
          ),
          isNewMission: true, // This flag is true since we're adding a new mission
        ),
      ),
    ).then((newMission) {
      if (newMission != null) {
        setState(() {
          // Assuming you have a list for routine flight missions
          missionsRoutine.add(newMission);
        });
      }
    });
  }

  /*void _addNewMission() async {
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
*/
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Single Flight'),
            Tab(text: 'Routine Flight'),
          ],
        ),
        actions: <Widget>[
          if (_tabController.index == 0)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addSingleFlight,
            ),
          if (_tabController.index == 1)
            IconButton(
              icon: Icon(Icons.flight),
              onPressed: _addRoutineFlight,
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab content
          buildSingleFlightTab(),

          // Second tab content
          buildRoutineFlightTab(),
        ],
      ),
    );
  }

  Widget buildSingleFlightTab() {
    // Return the Single Flight tab view
    return ListView.builder(
      itemCount: missionsSingle.length,
      itemBuilder: (context, index) {
        final mission = missionsSingle[index];
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
                builder: (context) => EditSingleMissionPage(singleFlightMissions: mission, isNewMission: false),
              ),
            );

            if (updatedMission != null) {
              setState(() {
                missionsSingle[index] = updatedMission;
              });
            }
          },
        );
      },
    );
  }

  Widget buildRoutineFlightTab() {
    // Return the Routine Flight tab view
    return ListView.builder(
      itemCount: missionsRoutine.length,
      itemBuilder: (context, index) {
        final mission = missionsRoutine[index];
        return ListTile(
          title: Text('${mission.time.format(context)} ~ ${mission.endTime.format(context)}'),
          subtitle: Text('${mission.days.join(', ')}, ${mission.frequency.join(', ')}, ${mission.routeName.join(', ')}'),
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
            final MissionRoutine? updatedMission = await Navigator.push<MissionRoutine>(
              context,
              MaterialPageRoute(
                builder: (context) => EditRoutineMissionPage(routineFlightMissions: mission, isNewMission: false),
              ),
            );

            if (updatedMission != null) {
              setState(() {
                missionsRoutine[index] = updatedMission;
              });
            }
          },
        );
      },
    );
  }
}
class EditSingleMissionPage extends StatefulWidget {
  final Mission singleFlightMissions;
  final bool isNewMission;

  EditSingleMissionPage({required this.singleFlightMissions, required this.isNewMission});

  @override
  _EditSingleMissionPageState createState() => _EditSingleMissionPageState();
}


class _EditSingleMissionPageState extends State<EditSingleMissionPage> {
  late List<String> _days;
  late TimeOfDay _time;
  late List<String> _routeName;
  late bool _runAllRoutes;
  late bool _isActive;
  final List<String> _allDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _days = widget.singleFlightMissions.days;
    _time = widget.singleFlightMissions.time;
    _routeName = widget.singleFlightMissions.routeName;
    _runAllRoutes = widget.singleFlightMissions.runAllRoutes;
    _isActive = widget.singleFlightMissions.isActive;
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
                      title: Text('Every $day'),
                      value: localSelectedDays.contains(day.substring(0,3)),
                      onChanged: (bool? value) {
                        if (value == true) {
                          localSelectedDays.add(day.substring(0,3));
                        } else {
                          localSelectedDays.remove(day.substring(0,3));
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
class EditRoutineMissionPage extends StatefulWidget {
  final MissionRoutine routineFlightMissions;
  final bool isNewMission;

  EditRoutineMissionPage({required this.routineFlightMissions, required this.isNewMission});

  @override
  _EditRoutineMissionPageState createState() => _EditRoutineMissionPageState();
}


class _EditRoutineMissionPageState extends State<EditRoutineMissionPage> {
  late List<String> _days;
  late List<String> _frequency;
  late TimeOfDay _time;
  late TimeOfDay _endTime;
  late List<String> _routeName;
  late bool _runAllRoutes;
  late bool _isActive;
  final List<String> _allDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _allFrequency = ['5 min', '10 min', '15 min', '30 min', '60 min'];

  @override
  void initState() {
    super.initState();
    _days = widget.routineFlightMissions.days;
    _frequency = widget.routineFlightMissions.frequency;
    _time = widget.routineFlightMissions.time;
    _endTime = widget.routineFlightMissions.endTime;
    _routeName = widget.routineFlightMissions.routeName;
    _runAllRoutes = widget.routineFlightMissions.runAllRoutes;
    _isActive = widget.routineFlightMissions.isActive;
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
  void _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }
  void _saveMission() {
    // Create a new Mission object with the current state
    final MissionRoutine updatedMission = MissionRoutine(
      days: _days,
      frequency: _frequency,
      time: _time,
      endTime: _endTime,
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
                      title: Text('Every $day'),
                      value: localSelectedDays.contains(day.substring(0,3)),
                      onChanged: (bool? value) {
                        if (value == true) {
                          localSelectedDays.add(day.substring(0,3));
                        } else {
                          localSelectedDays.remove(day.substring(0,3));
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

  void _selectFrequency() async {
    // Use a local copy of _days for the dialog's state
    final List<String> localSelectedFrequency = List<String>.from(_frequency);

    final List<String>? newSelectedFrequency = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage the local state for checkboxes within the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Frequency'),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _allFrequency.map((Frequency) {
                    return CheckboxListTile(
                      title: Text('Every $Frequency'),
                      value: localSelectedFrequency.contains(Frequency),
                      onChanged: (bool? value) {
                        if (value == true) {
                          localSelectedFrequency.add(Frequency);
                        } else {
                          localSelectedFrequency.remove(Frequency);
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
                    Navigator.of(context).pop(localSelectedFrequency); // Return the selected days
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newSelectedFrequency != null) {
      setState(() {
        _frequency = newSelectedFrequency; // Update the main state with the new selections
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
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
              title: Text('End Time'),
              trailing: Text('${_endTime.format(context)}'),
              onTap: _selectEndTime,
            ),
            ListTile(
              title: Text('Repeat'),
              trailing: Text(_days.join(', ')),
              onTap: _selectDays,
            ),
            ListTile(
              title: Text('Frequency'),
              trailing: Text(_frequency.join(', ')),
              onTap: _selectFrequency,
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
            title: Text('Every $day'),
            value: _selectedDays.contains(day.substring(0,3)),
            onChanged: (_) => _toggleDay(day.substring(0,3)),
          );
        }).toList(),
      ),
    );
  }
}

class SavedRoutesPage extends StatefulWidget {
  @override
  _SavedRoutesPageState createState() => _SavedRoutesPageState();
}

class _SavedRoutesPageState extends State<SavedRoutesPage> with SingleTickerProviderStateMixin{
  // This should be populated with your saved routes
  bool _isEditMode = false;
  late final Future<ui.Image> landmarkImageFuture;
  late final Future<ui.Image> chargingStationImageFuture;
  late AnimationController _animationController;
  int _getRouteShapeInt(String routeNumber) {
    switch (routeNumber) {
      case 'Circle':
        return 1;
      case 'Pie slice':
        return 2;
      case 'Triangle':
        return 3;
      case 'Square':
        return 4;
      case 'Cross':
        return 5;
      case 'Straight':
        return 6;
      default:
        return 1;
    }
  }
  @override
  void initState() {
    super.initState();
    landmarkImageFuture = loadImage('assets/images/drone1.png');
    chargingStationImageFuture = loadImage('assets/images/chargingStation.png');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Adjust duration to control the speed
    )..repeat();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Mission'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: globalRouteList.length,
        itemBuilder: (context, index) {
          final route = globalRouteList[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(route['name']),
                    trailing: _isEditMode
                        ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Confirm deletion with the user before removing the route
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Route'),
                              content: Text('Are you sure you want to delete this route?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () {
                                    // Delete the route and update the state
                                    setState(() {
                                      globalRouteList.removeAt(index);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                        : Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle tap action for Route
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlyingPage(routeName: route['name'],selectShape: _getRouteShapeInt(route['shape']), batteryLevel: 100, altitude: route['altitude'], diameter: route['diameter'],),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 3.0), // Spacing between name and row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Painted route area
                      Expanded(
                        flex: 3,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: FutureBuilder<List<ui.Image>>(
                              future: Future.wait([landmarkImageFuture, chargingStationImageFuture]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Loading indicator while waiting for images
                                }
                                if (snapshot.hasError) {
                                  return Text("Error loading images: ${snapshot.error}");
                                }
                                if (snapshot.hasData) {
                                  // Images are loaded, now passing them to the CustomPainter
                                  return AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: RouteDesignPainter(
                                          selectedRoute: _getRouteShapeInt(route['shape']),
                                          diameter: route['diameter'],
                                          altitude: route['altitude'],
                                          landmarkImage: snapshot.data![0],
                                          chargingStationImage: snapshot.data![1],
                                          progress: _animationController.value,
                                          sizeIndex: 0,
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  // This should not happen if images are loaded correctly
                                  return const Text("Unknown error");
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      // Spacer can be used to give some space between items, if needed
                      // Spacer(flex: 1),
                      // Text description area for altitude and diameter
                      Expanded(
                        flex: 2, // Adjust flex factor to control width proportion
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Flying Altitude: ${route['altitude'].toString()}m'),
                            Text('Diameter: ${route['diameter'].toString()}m'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),


    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
class FlyingPage extends StatefulWidget {
  final String routeName;
  final int selectShape;
  final double batteryLevel;
  final double altitude;
  final double diameter;

  // Constructor to accept values for the route name and battery level
  FlyingPage({
    required this.routeName,
    required this.selectShape,
    required this.batteryLevel,
    required this.altitude,
    required this.diameter,
  });
  @override
  _FlyingPageState createState() => _FlyingPageState();
}

class _FlyingPageState extends State<FlyingPage> with SingleTickerProviderStateMixin{
  bool isFlightStarted = false;
  late final Future<ui.Image> landmarkImageFuture;
  late final Future<ui.Image> chargingStationImageFuture;
  late AnimationController _animationController;
  void _onStartPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Take-off'),
        content: Text('Are you sure you want to start the flight?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog but do not start the flight
            },
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              setState(() {
                isFlightStarted = true; // Update the state to reflect that the flight has started
              });
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }

  void _onCancelPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Cancellation'),
        content: Text('Are you sure you want to cancel the flight?\nThe drone will return to its charging station'),
        actions: <Widget>[
          TextButton(
            child: Text('Keep Flying'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog but keep the flight running
            },
          ),
          TextButton(
            child: Text('Cancel Flight'),
            onPressed: () {
              setState(() {
                isFlightStarted = false; // Update the state to reflect that the flight is canceled
              });
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }

  /*int _getRouteShapeInt(String routeNumber) {
    switch (routeNumber) {
      case 'Circular':
        return 1;
      case 'Half Circular':
        return 2;
      case 'Triangle':
        return 3;
      case 'Square':
        return 4;
      case 'Diamond':
        return 5;
      default:
        return 1;
    }
  }*/
  @override
  void initState() {
    super.initState();
    landmarkImageFuture = loadImage('assets/images/drone1.png');
    chargingStationImageFuture = loadImage('assets/images/chargingStation.png');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Adjust duration to control the speed
    )..repeat();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName), // Route name displayed on the AppBar
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Placeholder for video 1
                Expanded(
                  child: Container(
                    height: 200, // Specify your desired height
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                // Placeholder for video 2
                SizedBox(height: 8),
                Expanded(
                  child: Container(
                    height: 200, // Specify your desired height
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Battery level
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Battery Level: ${widget.batteryLevel.toStringAsFixed(0)}%'),
                      // Add other drone status indicators here
                    ],
                  ),
                ),
                // Other drone status indicators can be added here
              ],
            ),
          ),
          // CustomPaint area
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Painted route area
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: FutureBuilder<List<ui.Image>>(
                        future: Future.wait([landmarkImageFuture, chargingStationImageFuture]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Loading indicator while waiting for images
                          }
                          if (snapshot.hasError) {
                            return Text("Error loading images: ${snapshot.error}");
                          }
                          if (snapshot.hasData) {
                            // Images are loaded, now passing them to the CustomPainter
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: RouteDesignPainter(
                                    selectedRoute: widget.selectShape,
                                    diameter: widget.diameter,
                                    altitude: widget.altitude,
                                    landmarkImage: snapshot.data![0],
                                    chargingStationImage: snapshot.data![1],
                                    progress: _animationController.value,
                                    sizeIndex: 0,
                                  ),
                                );
                              },
                            );
                          } else {
                            // This should not happen if images are loaded correctly
                            return const Text("Unknown error");
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Spacer can be used to give some space between items, if needed
                // Spacer(flex: 1),
                // Text description area for altitude and diameter
                Expanded(
                  flex: 2, // Adjust flex factor to control width proportion
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Flying Altitude: ${widget.altitude.toString()}m'),
                      Text('Diameter: ${widget.diameter.toString()}m'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Start button
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:ElevatedButton(
                onPressed: isFlightStarted ? _onCancelPressed : _onStartPressed,
                child: Text(isFlightStarted ? 'Cancel' : 'Start',
                  style: TextStyle(
                    fontSize: 24, // Set your desired font size here
                    //fontWeight: FontWeight.bold, // If you want your font to be bold
                    // other text styling as needed
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: isFlightStarted ? Colors.red : Colors.green,
                  minimumSize: Size(300, 70),// Change color based on state
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

class ActivityCenterPage extends StatefulWidget {
  const ActivityCenterPage({Key? key}) : super(key: key);

  @override
  _ActivityCenterPageState createState() => _ActivityCenterPageState();
}
class _ActivityCenterPageState extends State<ActivityCenterPage> {
  final List<Map<String, String>> anomalies = [
    {
      'droneName': 'Garden',
      'time': '2024-01-01 12:00',
      'anomalyType': 'Intrusion Detected',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Kitchen',
      'time': '2024-01-02 13:00',
      'anomalyType': 'Signal Lost',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Living room',
      'time': '2024-01-03 14:00',
      'anomalyType': 'Battery Low',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Warehouse',
      'time': '2024-01-04 15:00',
      'anomalyType': 'Unresponsive',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Garage',
      'time': '2024-01-05 16:00',
      'anomalyType': 'Weather Alert',
      'imagePath': 'assets/image1.jpg',
    },
  ];

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this anomaly record?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog but don't delete
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteAnomaly(index); // Delete the anomaly record
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAnomaly(int index) {
    setState(() {
      anomalies.removeAt(index);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: anomalies.length,
        itemBuilder: (context, index) {
          final anomaly = anomalies[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/drone1.png'),
                  ),
                  title: Text(anomaly['droneName']!), // Drone name
                  subtitle: Text('${anomaly['time']} - ${anomaly['anomalyType']}'),
                  isThreeLine: true,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    anomaly['imagePath']!, // Anomaly image
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.download, color: Colors.blue),
                      label: Text('Download', style: TextStyle(color: Colors.blue)),
                      onPressed: () {
                        // Implement download logic
                      },
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _showDeleteConfirmationDialog(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AnomalyRecordPage extends StatefulWidget {
  const AnomalyRecordPage({Key? key}) : super(key: key);

  @override
  _AnomalyRecordPageState createState() => _AnomalyRecordPageState();
}
class _AnomalyRecordPageState extends State<AnomalyRecordPage> {
  final List<Map<String, String>> anomalies = [
    {
      'droneName': 'Garden',
      'time': '2024-01-01 12:00',
      'anomalyType': 'Intrusion Detected',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Garden',
      'time': '2024-01-02 13:00',
      'anomalyType': 'Signal Lost',
      'imagePath': 'assets/image2.jpg',
    },
    /*{
      'droneName': 'Living room',
      'time': '2024-01-03 14:00',
      'anomalyType': 'Battery Low',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Warehouse',
      'time': '2024-01-04 15:00',
      'anomalyType': 'Unresponsive',
      'imagePath': 'assets/image1.jpg',
    },
    {
      'droneName': 'Garage',
      'time': '2024-01-05 16:00',
      'anomalyType': 'Weather Alert',
      'imagePath': 'assets/image1.jpg',
    },*/
  ];
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this anomaly record?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog but don't delete
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteAnomaly(index); // Delete the anomaly record
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAnomaly(int index) {
    setState(() {
      anomalies.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anomaly Records'),
      ),
      body: ListView.builder(
        itemCount: anomalies.length,
        itemBuilder: (context, index) {
          final anomaly = anomalies[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/drone1.png'),
                  ),
                  title: Text(anomaly['droneName']!), // Drone name
                  subtitle: Text('${anomaly['time']} - ${anomaly['anomalyType']}'),
                  isThreeLine: true,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    anomaly['imagePath']!, // Anomaly image
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.download, color: Colors.blue),
                      label: Text('Download', style: TextStyle(color: Colors.blue)),
                      onPressed: () {
                        // Implement download logic
                      },
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _showDeleteConfirmationDialog(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

