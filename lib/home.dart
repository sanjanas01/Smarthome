import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _locationController = TextEditingController();

  Future<void> _addLocation() async {
    final User? user = _auth.currentUser;
    final location = _locationController.text.trim();

    if (location.isNotEmpty) {
      final userDoc = _firestore.collection('users').doc(user?.uid);
      await userDoc.collection('locations').add({
        'location': location,
      });

      _locationController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a location'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final userName = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF596E5F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:20.0,vertical: 150.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, $userName',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20), 
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Enter Location',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20), 
              ElevatedButton(
                onPressed: _addLocation,
                child: const Text('Add Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20), 
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _auth.currentUser != null
                      ? _firestore
                          .collection('users')
                          .doc(user?.uid)
                          .collection('locations')
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
                          'No locations added',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final locations = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index]['location'];
                        return ListTile(
                          title: Text(
                            location,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/devices',
                              arguments: location,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
