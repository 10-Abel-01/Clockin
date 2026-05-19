import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:Clockin/view/pages/absensi/clockin/clockin_page.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'controller_absensi.dart';

class AbsensiPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AbsensiPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              AbsensiController()
                ..fetchJadwalAndShift()
                ..fetchHistory(int.parse(userData['id_karyawan'].toString()))
                ..fetchIzinSummary(
                  int.parse(userData['id_karyawan'].toString()),
                )
                ..startAutoRefresh(int.parse(userData['id_karyawan'].toString())),
      child: AbsensiPageContent(userData: userData),
    );
  }
}

class AbsensiPageContent extends StatelessWidget {
  final Map<String, dynamic> userData;
  const AbsensiPageContent({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AbsensiController>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0056B5),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildCurrentTimeAndDate(),
              const SizedBox(height: 24),
              _buildJadwalBox(context, controller),
              const SizedBox(height: 24),
              _buildHistorySection(controller),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Absensi',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(userData: userData),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentTimeAndDate() {
    return Column(
      children: [
        Text(
          '${DateFormat.Hm().format(DateTime.now())} WIB',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          DateFormat.EEEE(
            'id_ID',
          ).add_d().add_MMM().add_y().format(DateTime.now()),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildJadwalBox(BuildContext context, AbsensiController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Jadwal : ${controller.jadwalBulan}",
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            controller.jadwalShift ?? '',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            controller.jamShift ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Divider(height: 20, color: Colors.black),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildClockButton(context, controller, "Clock In"),
              _buildClockButton(context, controller, "Clock Out"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClockButton(
    BuildContext context,
    AbsensiController controller,
    String label,
  ) {
    return ElevatedButton(
      onPressed: () async {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (label == "Clock In") {
          bool alreadyClockIn = controller.history.any((record) {
            // determine date field (absensi use 'tanggal_hadir', visit use 'tanggal')
            String? dateStr = record['tanggal_hadir'] ?? record['tanggal'];
            if (dateStr == null) return false;
            DateTime recordDate;
            try {
              recordDate = DateTime.parse(dateStr);
            } catch (_) {
              return false;
            }
            final tipe =
                (record['tipe_absensi'] ?? '').toString().toLowerCase();
            if (tipe != 'office' && tipe != '') return false;
            return DateFormat('yyyy-MM-dd').format(recordDate) == today &&
                (record['jam_absen_masuk'] != null &&
                    record['jam_absen_masuk'] != '-');
          });
          if (alreadyClockIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anda telah absen masuk hari ini')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClockInPage()),
          );
        } else if (label == "Clock Out") {
          bool alreadyClockOut = controller.history.any((record) {
            // try tanggal_hadir (absensi) or tanggal (visit)
            final rawDate = record['tanggal_hadir'] ?? record['tanggal'];
            if (rawDate == null) return false;
            DateTime recordDate;
            try {
              recordDate = DateTime.parse(rawDate);
            } catch (_) {
              return false;
            }
            return DateFormat('yyyy-MM-dd').format(recordDate) == today &&
                (record['jam_absen_keluar'] != null &&
                    record['jam_absen_keluar'] != '-');
          });
          if (alreadyClockOut) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anda telah absen keluar')),
            );
            return;
          }
          // Logika Clock Out
          try {
            bool success = await controller.handleClockOut(
              context,
              int.parse(userData['id_karyawan'].toString()),
            );
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clock Out berhasil!')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0056B5),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHistorySection(AbsensiController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF95C1E6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Text(
                    "Tanggal",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Clockin",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Clockout",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Durasi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          // absensi dan visit digabung per hari
          Builder(
            builder: (context) {
              final daily = _buildDailySummaries(controller);
              return ListView.builder(
                itemCount: daily.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = daily[index];
                  return _buildHistoryRow(item);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _buildDailySummaries(AbsensiController controller) {
    // group by date (yyyy-MM-dd) but only for the current month
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();
    for (final rec in controller.history) {
      // detect raw date field: prefer 'tanggal_hadir' then visit 'tanggal'
      String? rawDate;
      if (rec.containsKey('tanggal_hadir') && rec['tanggal_hadir'] != null) {
        rawDate = rec['tanggal_hadir'].toString();
      } else if (rec.containsKey('tanggal') && rec['tanggal'] != null) {
        rawDate = rec['tanggal'].toString();
      } else {
        continue;
      }

      DateTime parsed;
      try {
        parsed = DateTime.parse(rawDate);
      } catch (_) {
        continue;
      }

      // skip records not in current month/year
      if (parsed.year != now.year || parsed.month != now.month) continue;

      final dateKey = DateFormat('yyyy-MM-dd').format(parsed);
      grouped.putIfAbsent(dateKey, () => []).add(rec);
    }

    final List<Map<String, String>> daily = [];
    final timeFormat = DateFormat.Hm();
    final displayFormat = DateFormat('dd MMM yyyy', 'id_ID');

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final dateKey in sortedDates) {
      final records = grouped[dateKey]!;
      // collect office records
      String clockIn = '-';
      String clockOut = '-';

      // find any absensi record (office) for that date
      final office = records.firstWhere(
        (r) =>
            r.containsKey('jam_absen_masuk') ||
            r.containsKey('jam_absen_keluar'),
        orElse: () => {},
      );
      if (office is Map && office.isNotEmpty) {
        clockIn = office['jam_absen_masuk'] ?? '-';
        clockOut = office['jam_absen_keluar'] ?? '-';
      }

      // collect visit times
      final visitTimes = <String>[];
      for (final r in records) {
        // visit rows from API use key 'jam', older model used 'jam_visit'
        final jamVal = r['jam'] ?? r['jam_visit'];
        if (jamVal != null && jamVal != '') {
          visitTimes.add(jamVal.toString());
        }
        // sometimes visit stored as jam_absen_masuk with tipe_visit indicator
        if ((r['tipe_absensi'] ?? '').toString().toLowerCase() == 'visit' &&
            r['jam_absen_masuk'] != null) {
          visitTimes.add(r['jam_absen_masuk']);
        }
      }

      if (visitTimes.isNotEmpty) {
        // sort times with flexible parsing (HH:mm:ss, HH:mm, or full DateTime)
        DateTime? parseFlexible(String s) {
          try {
            return DateFormat.Hms().parse(s);
          } catch (_) {}
          try {
            return DateFormat.Hm().parse(s);
          } catch (_) {}
          try {
            return DateTime.parse(s);
          } catch (_) {}
          return null;
        }
        visitTimes.sort((a, b) {
          final ta = parseFlexible(a.toString());
          final tb = parseFlexible(b.toString());
          if (ta != null && tb != null) return ta.compareTo(tb);
          return a.toString().compareTo(b.toString());
        });
        // if office data exists, prefer office times; otherwise use visit first/last
        if (clockIn == '-' && clockOut == '-') {
          clockIn = visitTimes.first;
          clockOut = visitTimes.last;
        } else {
          // still offer visit-derived times if one of office times missing
          if (clockIn == '-' && visitTimes.isNotEmpty)
            clockIn = visitTimes.first;
          if (clockOut == '-' && visitTimes.isNotEmpty)
            clockOut = visitTimes.last;
        }
      }

      // compute duration
      String dur = '-';
      if (clockIn != '-' && clockOut != '-') {
        dur = controller.calculateDuration(clockIn, clockOut);
      }

      final dateDisplay = displayFormat.format(DateTime.parse(dateKey));
      daily.add({
        'tanggal': dateDisplay,
        'clockIn': clockIn,
        'clockOut': clockOut,
        'durasi': dur,
      });
    }

    return daily;
  }

  Widget _buildHistoryRow(Map<String, String> item) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF95C1E6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item['tanggal'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              item['clockIn'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              item['clockOut'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              item['durasi'] ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AbsensiController controller, int index) {
    if (index >= controller.history.length) return const SizedBox.shrink();

    final item = controller.history[index];
    final rawTanggal = item['tanggal_hadir'] ?? item['tanggal'] ?? '';
    final tanggal = rawTanggal.isNotEmpty
        ? DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(rawTanggal))
        : '-';
    final clockIn = item['jam_absen_masuk'] ?? '-';
    final clockOut = item['jam_absen_keluar'] ?? '-';
    final durasi =
        (clockIn != '-' && clockOut != '-')
            ? controller.calculateDuration(clockIn, clockOut)
            : '-';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF95C1E6), // Warna latar belakang header
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              tanggal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              clockIn,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              clockOut,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              durasi,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
