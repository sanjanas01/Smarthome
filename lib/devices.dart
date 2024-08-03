import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _temperature = 23.0;

  void _addDevice(String location) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController deviceNameController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Device'),
          content: TextField(
            controller: deviceNameController,
            decoration: const InputDecoration(hintText: 'Device Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (deviceNameController.text.isNotEmpty) {
                  try {
                    await _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .collection('locations')
                        .doc(location)
                        .collection('devices')
                        .add({
                          'name': deviceNameController.text,
                          'active': false,
                          'location': location,
                          'image': 'assets/other.png',
                        });
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error adding device: $e');
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _changeTemperature() {
    showDialog(
      context: context,
      builder: (context) {
        double tempValue = _temperature;
        return AlertDialog(
          title: const Text(
            'Set Temperature',
            textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0XFF487748),
                ),
                ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: tempValue,
                    min: -10,
                    max: 60,
                    divisions: 7,
                    activeColor: Color(0XFF65A765),
                    label: tempValue.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        tempValue = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _temperature = tempValue;
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Set',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0XFF487748),
                  fontSize: 20
                  
                ),
                ),
            ),
          ],
        );
      },
    );
  }

  void _toggleDeviceActive(DocumentSnapshot device) async {
    final isActive = device['active'] as bool;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('locations')
        .doc(device['location'])
        .collection('devices')
        .doc(device.id)
        .update({'active': !isActive});
  }

  @override
  Widget build(BuildContext context) {
    final location = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: const Color(0xFF596E5F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                child: Text(
                  location ?? '',
                  style: const TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _auth.currentUser != null
                      ? _firestore
                          .collection('users')
                          .doc(_auth.currentUser!.uid)
                          .collection('locations')
                          .doc(location)
                          .collection('devices')
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    int deviceCount = snapshot.hasData
                        ? snapshot.data!.docs
                            .where((device) {
                              final data = device.data() as Map<String, dynamic>?;
                              return data != null && data.containsKey('active') && data['active'] == true;
                            })
                            .length
                        : 0;
                    return Text(
                      '$deviceCount device${deviceCount == 1 ? '' : 's'} active',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _changeTemperature,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 225, 141, 16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thermostat, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '${_temperature.round()}°c',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                height: 250,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _auth.currentUser != null
                      ? _firestore
                          .collection('users')
                          .doc(_auth.currentUser!.uid)
                          .collection('locations')
                          .doc(location)
                          .collection('devices')
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No devices found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final device = snapshot.data!.docs[index];
                        final deviceData = device.data() as Map<String, dynamic>;
                        final isActive = deviceData['active'] as bool;
                        final deviceName = deviceData['name'] as String;

                        String path;
                        switch (deviceName.toLowerCase()) {
                          case 'tv':
                            path='assets/tv.png';
                            break;
                          case 'ac':
                            path='assets/ac.png';
                            break;
                          case 'fan':
                            path='assets/fan.png';
                            break;
                          case 'light':
                            path='assets/light.png';
                            break;
                          case 'fridge':
                            path='assets/fridge.png';
                            break;
                          default:
                            path='assets/other.png';
                        }

                        return Container(
                          width: 200,
                          height: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/tile.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    path,
                                    width: 300,
                                    height: 200,
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    deviceName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: GestureDetector(
                                  onTap: () => _toggleDeviceActive(device),
                                  child: Icon(
                                    Icons.circle,
                                    color: isActive ? Colors.green : Colors.black,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () => _addDevice(location ?? ''),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add_circle_outline),
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
