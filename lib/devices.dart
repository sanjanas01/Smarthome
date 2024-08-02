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

  void _addDevice() {
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
              onPressed: () {
                if (deviceNameController.text.isNotEmpty) {
                  _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .collection('devices')
                      .add({'name': deviceNameController.text, 'active': false});
                  Navigator.pop(context);
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
        return AlertDialog(
          title: const Text('Set Temperature'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _temperature,
                min: 16,
                max: 30,
                divisions: 14,
                label: _temperature.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
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
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _auth.currentUser != null
                    ? _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
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
            GestureDetector(
              onTap: _changeTemperature,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_temperature.round()}°C',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _auth.currentUser != null
                    ? _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
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
                        'No devices connected',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final devices = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final data = device.data() as Map<String, dynamic>?; 
                      bool isActive = data != null && data.containsKey('active') ? data['active'] : false;
                      return Container(
                        width: 140,
                        height: 90,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Show different icons based on device name
                              Icon(
                                (data?['name'] ?? '').toLowerCase().contains('lamp')
                                    ? Icons.lightbulb_outline
                                    : (data?['name'] ?? '').toLowerCase().contains('tv')
                                        ? Icons.tv
                                        : Icons.device_unknown,
                                size: 40,
                              ),
                              Text(
                                data?['name'] ?? '',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Checkbox(
                                value: isActive,
                                onChanged: (bool? value) {
                                  _firestore
                                      .collection('users')
                                      .doc(_auth.currentUser!.uid)
                                      .collection('devices')
                                      .doc(device.id)
                                      .update({'active': value});
                                },
                              ),
                            ],
                          ),
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
                  onPressed: _addDevice,
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
