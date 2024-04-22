class TaiKhoanNguoiDung {
  // Add other properties as needed

  TaiKhoanNguoiDung({
    this.id,
    this.ho,
    this.ten,
    this.diachi,
    this.sdt,
    this.email,
    this.hinhanh,
  });

  TaiKhoanNguoiDung.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'] as String?,
          ho: json['Ho'] as String?,
          ten: json['Ten'] as String?,
          diachi: json['diachi'] as String?,
          sdt: json['sdt'] as String?,
          email: json['email'] as String?,
          hinhanh: json['hinhanh'] as String?,
        );

  final String? id;
  final String? ho;
  final String? ten;
  final String? diachi;
  final String? sdt;
  final String? email;
  final String? hinhanh;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'Ho': ho,
      'Ten': ten,
      'diachi': diachi,
      'sdt': sdt,
      'email': email,
      'hinhanh': hinhanh,
    };
  }
}
