import 'package:flutter/material.dart';
import 'controller_form/controller_form_izin.dart';

class IzinFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  IzinFormPage({super.key, this.initialData});

  @override
  State<IzinFormPage> createState() => _IzinFormPageState();
}

class _IzinFormPageState extends State<IzinFormPage> {
  late IzinFormController controller;

  @override
  void initState() {
    super.initState();
    controller = IzinFormController(
      context: context,
      initialData: widget.initialData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0056B5),
      appBar: AppBar(
        title: const Text(
          'Izin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0056B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabelWithDropdown(
                label: 'Jenis Izin',
                items: ['Cuti Tahunan', 'Sakit'],
                icon: Icons.assignment,
              ),
              const Divider(color: Colors.black),
              _buildLabelWithDropdown(
                label: 'Jenis Permintaan',
                items: ['Sehari Penuh', 'Setengah Hari'],
                icon: Icons.access_time,
              ),
              const Divider(color: Colors.black),
              _buildLabelWithDropdown(
                label: 'Tanggal',
                items: ['Hari Ini', 'Besok', 'Lusa'],
                icon: Icons.calendar_today,
              ),
              const Divider(color: Colors.black),
              _buildEditableDescription(),
              const Divider(color: Colors.black),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.file_upload,
                    color: Color(0xFF0056B5),
                    size: 36,
                  ),
                  const SizedBox(width: 8),
                  _buildLabel('Upload File (Opsional)'),
                ],
              ),
              const Divider(color: Colors.black),
              _buildUploadButton(),
              Text(
                'Max file size: 5MB',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.submitIzin(setState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056B5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Request',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black, fontSize: 14),
    );
  }

  Widget _buildLabelWithDropdown({
    required String label,
    required List<String> items,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap:
          label == 'Tanggal'
              ? () => controller.pickDate(setState)
              : () => _showItemSelectionDialog(label, items),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF0056B5), size: 36),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              if (label == 'Tanggal')
                Text(
                  "${controller.selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
              else if (controller.selectedItems[label] != null)
                Text(
                  controller.selectedItems[label]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }

  void _showItemSelectionDialog(String label, List<String> items) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih $label'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  onTap: () {
                    setState(() {
                      controller.selectedItems[label] = items[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableDescription() {
    return GestureDetector(
      onTap: _showDescriptionDialog,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.description, color: Color(0xFF0056B5), size: 36),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsi',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              controller.deskripsiController.text.isNotEmpty
                  ? Text(
                    controller.deskripsiController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                  : const SizedBox(height: 20),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }

  void _showDescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final descController = TextEditingController(
          text: controller.deskripsiController.text,
        );
        return AlertDialog(
          title: const Text('Masukkan Deskripsi'),
          content: TextField(
            controller: descController,
            decoration: const InputDecoration(
              hintText: 'Tulis deskripsi di sini',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  controller.deskripsiController.text = descController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => controller.uploadPdfFile(setState),
          child: Container(
            width: 200,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, color: Colors.black54),
                SizedBox(height: 4),
              ],
            ),
          ),
        ),
        if (controller.uploadedFile != null) ...[
          const SizedBox(height: 8),
          Text(
            controller.uploadedFile!,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ],
    );
  }
}
