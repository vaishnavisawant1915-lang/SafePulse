import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, String>> contacts = [];
  bool _isLoading = true;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _contactsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('emergencyContacts');
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final snapshot = await _contactsCollection.get();

      final loadedContacts = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name': data['name']?.toString() ?? '',
          'phone': data['phone']?.toString() ?? '',
          'relation': data['relation']?.toString() ?? '',
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        contacts = loadedContacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load contacts: $e'),
        ),
      );
    }
  }

  Future<void> _addContact(Map<String, String> contact) async {
    await _contactsCollection.add({
      'name': contact['name'],
      'phone': contact['phone'],
      'relation': contact['relation'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateContact(
    String contactId,
    Map<String, String> contact,
  ) async {
    await _contactsCollection.doc(contactId).update({
      'name': contact['name'],
      'phone': contact['phone'],
      'relation': contact['relation'],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteContact(String contactId) async {
    await _contactsCollection.doc(contactId).delete();
  }

  void _showContactForm({int? index}) {
    final nameController = TextEditingController(
      text: index != null ? contacts[index]['name'] : '',
    );

    final phoneController = TextEditingController(
      text: index != null ? contacts[index]['phone'] : '',
    );

    final relationController = TextEditingController(
      text: index != null ? contacts[index]['relation'] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            index == null ? 'Add Emergency Contact' : 'Edit Contact',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Name and phone number are required.',
                      ),
                    ),
                  );
                  return;
                }

                final contact = {
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'relation': relationController.text.trim(),
                };

                try {
                  if (index == null) {
                    await _addContact(contact);
                  } else {
                    final contactId = contacts[index]['id'];

                    if (contactId != null) {
                      await _updateContact(contactId, contact);
                    }
                  }

                  if (!mounted) return;

                  Navigator.pop(context);

                  await _loadContacts();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        index == null
                            ? 'Emergency contact saved to Firebase.'
                            : 'Emergency contact updated.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Operation failed: $e',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                index == null ? 'SAVE' : 'UPDATE',
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text(
            'Are you sure you want to delete this emergency contact?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final contactId = contacts[index]['id'];

                Navigator.pop(context);

                if (contactId == null) return;

                try {
                  await _deleteContact(contactId);
                  await _loadContacts();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency contact deleted.'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: $e'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showContactForm();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : contacts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contact_emergency_outlined,
                          size: 90,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Emergency Contacts',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add trusted people who should be contacted during an emergency.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showContactForm();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Add Your First Contact',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];

                    final name = contact['name'] ?? '';
                    final phone = contact['phone'] ?? '';
                    final relation = contact['relation'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '$relation\n$phone',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showContactForm(index: index);
                            }

                            if (value == 'delete') {
                              _confirmDelete(index);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}