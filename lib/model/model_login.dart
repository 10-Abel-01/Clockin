class LoginModel {
  final String idKaryawan;
  final String namaKaryawan;
  final String jabatan;
  final String fotoProfil;
  final String noTelp;
  final String email;
  final String? bank;
  final String? rekening;

  // konstruktor untuk menerima semua data pengguna
  LoginModel({
    required this.idKaryawan,
    required this.namaKaryawan,
    required this.jabatan,
    required this.fotoProfil,
    required this.noTelp,
    required this.email,
    this.bank,
    this.rekening,
  });

  // konstruktor untuk membuat objek LoginModel dari Map (JSON)
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      idKaryawan:
          json['id_karyawan']?.toString() ??
          '', // Pastikan id_karyawan diubah ke String dan tidak null
      namaKaryawan: json['nama_karyawan']?.toString() ?? '',
      jabatan: json['jabatan']?.toString() ?? '',
      fotoProfil: json['foto_profil']?.toString() ?? '',
      noTelp: json['no_telp']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      bank: json['bank']?.toString(),
      rekening: json['rekening']?.toString(),
    );
  }

  // metode untuk mengonversi objek loginmodel ke json
  Map<String, dynamic> toJson() {
    return {
      'id_karyawan': idKaryawan,
      'nama_karyawan': namaKaryawan,
      'jabatan': jabatan,
      'foto_profil': fotoProfil,
      'no_telp': noTelp,
      'email': email,
      'bank': bank,
      'rekening': rekening,
    };
  }
}
