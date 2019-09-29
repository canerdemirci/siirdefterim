class Siir {
  int id;
  String ad;
  String metin;
  int sairId;
  String createdAt;

  static final String colId = 'id';
  static final String colAd = 'ad';
  static final String colMetin = 'metin';
  static final String colSairid = 'sair_id';
  static final String colCreatedat = 'created_at';

  Siir({
    this.id,
    this.ad,
    this.metin,
    this.sairId,
    this.createdAt
  });
}