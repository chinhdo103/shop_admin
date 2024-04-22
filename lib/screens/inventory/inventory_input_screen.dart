import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('LichSuNhap')
          .orderBy('ThoiGianNhap', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var document = snapshot.data!.docs[index];
            DateTime entryDate =
                (document['ThoiGianNhap'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(document['TenSP'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Số lượng: ${document['SoLuongNhap']}'),
                    Text('Ngày nhập: ${_dateFormat.format(entryDate)}'),
                  ],
                ),
                // Add more details or customize as needed
              ),
            );
          },
        );
      },
    );
  }
}
