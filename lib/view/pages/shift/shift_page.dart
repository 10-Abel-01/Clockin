// import 'package:flutter/material.dart';
// import 'package:Clockin/view/components/custom_bottom_nav.dart';
// import 'package:Clockin/model/model_shift.dart';

// class ShiftPage extends StatelessWidget {
//   final Map<String, dynamic>? userData;

//   const ShiftPage({Key? key, this.userData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final shifts = ShiftModel.sampleData();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shift'),
//         backgroundColor: const Color(0xFF0056B5),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: const Color(0xFF0056B5),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Text(
//                   '07.54 WIB',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Kamis, 20 Mar 2025',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: const [
//                       Text(
//                         'Jadwal : Maret 2025\nPagi\n08.00 WIB - 17.00 WIB',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: shifts.length,
//               itemBuilder: (context, index) {
//                 final shift = shifts[index];
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             shift.location,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             '${shift.date.day}-${shift.date.month}-${shift.date.year}',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           const Text(
//                             'Clockin',
//                             style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             shift.clockIn,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           const Text(
//                             'Clockout',
//                             style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             shift.clockOut,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           const Text(
//                             'Durasi',
//                             style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             shift.duration,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNav(
//         currentIndex: 2,
//         userData: userData,
//       ),
//     );
//   }
// }
