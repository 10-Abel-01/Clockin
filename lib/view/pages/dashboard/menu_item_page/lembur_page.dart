import 'package:flutter/material.dart';
import 'controller_lembur.dart';
import 'form_menu_item_page/lembur_form_page.dart';
import '../../../components/custom_bottom_nav.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({Key? key}) : super(key: key);

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  late LemburController controller;

  @override
  void initState() {
    super.initState();
    controller = LemburController(context: context);
    controller.loadUserData(setState);
    controller.loadLemburData(setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0056B5),
      appBar: AppBar(
        title: const Text(
          'Lembur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0056B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.lemburList.length,
                  itemBuilder: (context, index) {
                    final lembur = controller.lemburList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Tanggal: ${controller.formatDate(lembur['tanggal_lembur'])}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deskripsi: ${lembur['deskripsi_lembur']}'),
                            Text('Atasan: ${lembur['atasan']}'),
                            if (lembur['lampiran'] != null)
                              Text('Lampiran: ${lembur['lampiran']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => controller.editLembur(index, setState),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () =>
                                      controller.deleteLembur(index, setState),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => controller.navigateToLemburForm(
                            setState: setState,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Request',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: CustomBottomNav(
          currentIndex: controller.currentIndex,
          onTap: (idx) => controller.onNavTap(idx, setState),
        ),
      ),
    );
  }
}
