import 'model_jabatan.dart';

class ProfileModel {
  final int idKaryawan;
  final String namaKaryawan;
  final String jenisKelamin;
  final String tanggalLahir;
  final String email;
  final String noTelp;
  final String fotoProfil;
  final String? bank;
  final String? rekening;
  final JabatanModel? jabatan;

  const ProfileModel({
    required this.idKaryawan,
    required this.namaKaryawan,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.email,
    required this.noTelp,
    required this.fotoProfil,
    this.bank,
    this.rekening,
    this.jabatan,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      idKaryawan: _parseInt(json['id_karyawan']),
      namaKaryawan: json['nama_karyawan']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      tanggalLahir: json['tanggal_lahir']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noTelp: json['no_telp']?.toString() ?? '',
      fotoProfil: json['foto_profil']?.toString() ?? '',
      bank: _parseNullable(json['bank']),
      rekening: _parseNullable(json['rekening']),
      jabatan:
          json['jabatan'] is Map<String, dynamic>
              ? JabatanModel.fromJson(json['jabatan'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_karyawan': idKaryawan,
      'nama_karyawan': namaKaryawan,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'email': email,
      'no_telp': noTelp,
      'foto_profil': fotoProfil,
      'bank': bank,
      'rekening': rekening,
      'jabatan': jabatan?.toJson(),
    };
  }

  ProfileModel copyWith({
    int? idKaryawan,
    String? namaKaryawan,
    String? jenisKelamin,
    String? tanggalLahir,
    String? email,
    String? noTelp,
    String? fotoProfil,
    String? bank,
    String? rekening,
    JabatanModel? jabatan,
  }) {
    return ProfileModel(
      idKaryawan: idKaryawan ?? this.idKaryawan,
      namaKaryawan: namaKaryawan ?? this.namaKaryawan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      email: email ?? this.email,
      noTelp: noTelp ?? this.noTelp,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      bank: bank ?? this.bank,
      rekening: rekening ?? this.rekening,
      jabatan: jabatan ?? this.jabatan,
    );
  }

  factory ProfileModel.empty() {
    return const ProfileModel(
      idKaryawan: 0,
      namaKaryawan: '',
      jenisKelamin: '',
      tanggalLahir: '',
      email: '',
      noTelp: '',
      fotoProfil: '',
      bank: null,
      rekening: null,
      jabatan: null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _parseNullable(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}
