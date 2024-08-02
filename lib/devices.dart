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
          title: const Text('Set Temperature'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: tempValue,
                    min: 16,
                    max: 30,
                    divisions: 14,
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
              child: const Text('Set'),
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
      body: Padding(
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
                        .collection('devices')
                        .where('location', isEqualTo: location)
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
            GestureDetector(
              onTap: _changeTemperature,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 120),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 16.0), 
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _auth.currentUser != null
                    ? _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .collection('devices')
                        .where('location', isEqualTo: location)
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
                      final deviceImage = deviceData['image'] as String;

                      return Container(
                        width: 120, 
                        height: 100, 
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    deviceImage,
                                    width: 40, 
                                    height: 40, 
                                  ),
                                  Text(
                                    deviceName,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _toggleDeviceActive(device),
                                child: Icon(
                                  Icons.circle,
                                  color: isActive ? Colors.green : Colors.white,
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
