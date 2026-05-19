import 'package:flutter/material.dart';
import 'controller_izin.dart';
import 'form_menu_item_page/izin_form_page.dart';
import '../../../components/custom_bottom_nav.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({Key? key}) : super(key: key);

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  late IzinController controller;

  @override
  void initState() {
    super.initState();
    controller = IzinController(context: context);
    controller.loadUserData(setState);
    controller.loadIzinData(setState);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.expanded.length != controller.izinList.length) {
      controller.expanded = List.generate(
        controller.izinList.length,
        (index) => false,
      );
    }
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
                child: ListView.separated(
                  itemCount: controller.izinList.length,
                  separatorBuilder:
                      (context, index) => const Divider(color: Colors.black),
                  itemBuilder: (context, index) {
                    final izin = controller.izinList[index];
                    final status = izin['status'] ?? 'Verifikasi';
                    int statusIdx = controller.statusKey.indexOf(status);
                    if (statusIdx == -1) statusIdx = 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Izin - ',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        controller.formatTanggal(
                                          izin['tanggal_izin'],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    izin['deskripsi_izin'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: controller.statusColor[statusIdx],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.statusList[statusIdx],
                                style: TextStyle(
                                  color: controller.statusTextColor[statusIdx],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (statusIdx == 0 || statusIdx == 1)
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                  size: 32,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    controller.editIzin(index, setState);
                                  } else if (value == 'delete') {
                                    controller.deleteIzin(index, setState);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IzinFormPage(),
                          ),
                        ).then((_) => controller.loadIzinData(setState));
                      },
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
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0056B5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white),
                      onPressed: () {},
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
