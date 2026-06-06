import 'package:flutter/material.dart';
import 'controller_form_lembur.dart';

class LemburFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  LemburFormPage({super.key, this.initialData});

  @override
  State<LemburFormPage> createState() => _LemburFormPageState();
}

class _LemburFormPageState extends State<LemburFormPage> {
  late LemburFormController controller;

  @override
  void initState() {
    super.initState();
    controller = LemburFormController(
      context: context,
      initialData: widget.initialData,
    );
    controller.loadUserData(setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0056B5),
      appBar: AppBar(
        title: const Text(
          'Form Lembur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0056B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              _buildLabel('Nama'),
              Text(
                controller.name ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.black),
              _buildLabel('NIK'),
              Text(
                controller.nik ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.black),
              _buildLabelWithDropdown(
                label: 'Tanggal',
                items: [],
                icon: Icons.calendar_today,
              ),
              const Divider(color: Colors.black),
              _buildEditableDescription(),
              const Divider(color: Colors.black),
              _buildLabelWithDropdown(
                label: 'Atasan',
                items: ['Bapak Fahmi Junaedi', 'Bapak Are', 'Bapak Aris', 'Bapak Randy', 'Ibu Hanny'],
                icon: Icons.person,
              ),
              const Divider(color: Colors.black),
              _buildUploadButton(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.submitLembur(setState),
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
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Masukkan deskripsi lembur',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  controller.deskripsiController.text = descController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
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
        Row(
          children: [
            const Icon(Icons.file_upload, color: Color(0xFF0056B5), size: 36),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => controller.uploadPdfFile(setState),
              child: const Text(
                'Upload File (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0056B5),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        if (controller.uploadedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'File: ${controller.uploadedFile!.split('/').last}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
      ],
    );
  }
}
