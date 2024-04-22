class TaiKhoan {
  // Add other properties as needed

  TaiKhoan(
      {this.maTK,
      this.hoVaTen,
      this.tenTK,
      this.matKhau,
      this.vaiTro,
      this.trangThai});
  TaiKhoan.fromJson(Map<String, dynamic> json)
      : this(
          maTK: json['MaTK'] as String?,
          hoVaTen: json['HoVaTen'] as String?,
          tenTK: json['TenTK'] as String?,
          matKhau: json['MatKhau'] as String?,
          vaiTro: json['VaiTro'] as String?,
          trangThai: json['TrangThai'] as String?,
        );

  final String? maTK;
  final String? hoVaTen;
  final String? tenTK;
  final String? matKhau;
  final String? vaiTro;
  final String? trangThai;

  Map<String, Object?> toJson() {
    return {
      'MaTK': maTK,
      'HoVaTen': hoVaTen,
      'TenTK': tenTK,
      'MatKhau': matKhau,
      'VaiTro': vaiTro,
      'TrangThai': trangThai,
    };
  }
}
