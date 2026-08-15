// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'small.dart';

// **************************************************************************
// CodableGenerator
// **************************************************************************

// =============================================================================
// 1. Unified Schema Descriptor for SmallLocation
// =============================================================================
extension type const _$SmallLocationSchema(int _value) {
  static const String nameLatitude = 'latitude';
  static const String nameLongitude = 'longitude';
  static const String nameCity = 'city';
  static const String nameCountry = 'country';

  static final Uint8List nameLatitudeBytes = Uint8List.fromList(const [
    108,
    97,
    116,
    105,
    116,
    117,
    100,
    101,
  ]);
  static final Uint8List nameLongitudeBytes = Uint8List.fromList(const [
    108,
    111,
    110,
    103,
    105,
    116,
    117,
    100,
    101,
  ]);
  static final Uint8List nameCityBytes = Uint8List.fromList(const [
    99,
    105,
    116,
    121,
  ]);
  static final Uint8List nameCountryBytes = Uint8List.fromList(const [
    99,
    111,
    117,
    110,
    116,
    114,
    121,
  ]);

  static const int keyLatitude = 0;
  static const int keyLongitude = 1;
  static const int keyCity = 2;
  static const int keyCountry = 3;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameLatitude,
    nameLongitude,
    nameCity,
    nameCountry,
  ]);

  static const _$SmallLocationSchema none = _$SmallLocationSchema(0);
  static const int _latitudeBit = 1 << 0;
  static const _$SmallLocationSchema latitude = _$SmallLocationSchema(
    _latitudeBit,
  );
  static const int _longitudeBit = 1 << 1;
  static const _$SmallLocationSchema longitude = _$SmallLocationSchema(
    _longitudeBit,
  );
  static const int _cityBit = 1 << 2;
  static const _$SmallLocationSchema city = _$SmallLocationSchema(_cityBit);
  static const int _countryBit = 1 << 3;
  static const _$SmallLocationSchema country = _$SmallLocationSchema(
    _countryBit,
  );

  static const _$SmallLocationSchema golden = _$SmallLocationSchema(
    _latitudeBit | _longitudeBit | _cityBit | _countryBit,
  );

  @pragma('vm:prefer-inline')
  _$SmallLocationSchema operator |(_$SmallLocationSchema other) =>
      _$SmallLocationSchema(_value | other._value);

  @pragma('vm:prefer-inline')
  void validate() {
    if ((_value & golden._value) != golden._value) {
      _throwMissingFields();
    }
  }

  void _throwMissingFields() {
    final missing = <String>[];
    if ((_value & _latitudeBit) == 0) missing.add(nameLatitude);
    if ((_value & _longitudeBit) == 0) missing.add(nameLongitude);
    if ((_value & _cityBit) == 0) missing.add(nameCity);
    if ((_value & _countryBit) == 0) missing.add(nameCountry);
    throw CodableException(
      'Missing required fields for SmallLocation: ${missing.join(", ")}',
    );
  }
}

SmallLocation _$SmallLocationFromReader(JsonTokenReader reader) {
  reader.beginObject();

  double? latitude;
  double? longitude;
  String? city;
  String? country;
  var seen = _$SmallLocationSchema.none;

  while (reader.hasNext()) {
    switch (reader.selectName(_$SmallLocationSchema.options)) {
      case _$SmallLocationSchema.keyLatitude:
        latitude = reader.readDouble();
        seen |= _$SmallLocationSchema.latitude;
        break;
      case _$SmallLocationSchema.keyLongitude:
        longitude = reader.readDouble();
        seen |= _$SmallLocationSchema.longitude;
        break;
      case _$SmallLocationSchema.keyCity:
        city = reader.readString();
        seen |= _$SmallLocationSchema.city;
        break;
      case _$SmallLocationSchema.keyCountry:
        country = reader.readString();
        seen |= _$SmallLocationSchema.country;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  seen.validate();

  return SmallLocation(
    latitude: latitude!,
    longitude: longitude!,
    city: city!,
    country: country!,
  );
}

void _$SmallLocationToWriter(SmallLocation instance, JsonTokenWriter writer) {
  writer.beginObject();
  writer.writeNameBytes(_$SmallLocationSchema.nameLatitudeBytes);
  writer.writeDouble(instance.latitude);
  writer.writeNameBytes(_$SmallLocationSchema.nameLongitudeBytes);
  writer.writeDouble(instance.longitude);
  writer.writeNameBytes(_$SmallLocationSchema.nameCityBytes);
  writer.writeString(instance.city);
  writer.writeNameBytes(_$SmallLocationSchema.nameCountryBytes);
  writer.writeString(instance.country);
  writer.endObject();
}

// =============================================================================
// 2. Unified Schema Descriptor for SmallMetadata
// =============================================================================
extension type const _$SmallMetadataSchema(int _value) {
  static const String nameLoginCount = 'loginCount';
  static const String nameLastLogin = 'lastLogin';
  static const String nameLocation = 'location';

  static final Uint8List nameLoginCountBytes = Uint8List.fromList(const [
    108,
    111,
    103,
    105,
    110,
    67,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameLastLoginBytes = Uint8List.fromList(const [
    108,
    97,
    115,
    116,
    76,
    111,
    103,
    105,
    110,
  ]);
  static final Uint8List nameLocationBytes = Uint8List.fromList(const [
    108,
    111,
    99,
    97,
    116,
    105,
    111,
    110,
  ]);

  static const int keyLoginCount = 0;
  static const int keyLastLogin = 1;
  static const int keyLocation = 2;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameLoginCount,
    nameLastLogin,
    nameLocation,
  ]);

  static const _$SmallMetadataSchema none = _$SmallMetadataSchema(0);
  static const int _loginCountBit = 1 << 0;
  static const _$SmallMetadataSchema loginCount = _$SmallMetadataSchema(
    _loginCountBit,
  );
  static const int _lastLoginBit = 1 << 1;
  static const _$SmallMetadataSchema lastLogin = _$SmallMetadataSchema(
    _lastLoginBit,
  );
  static const int _locationBit = 1 << 2;
  static const _$SmallMetadataSchema location = _$SmallMetadataSchema(
    _locationBit,
  );

  static const _$SmallMetadataSchema golden = _$SmallMetadataSchema(
    _loginCountBit | _lastLoginBit | _locationBit,
  );

  @pragma('vm:prefer-inline')
  _$SmallMetadataSchema operator |(_$SmallMetadataSchema other) =>
      _$SmallMetadataSchema(_value | other._value);

  @pragma('vm:prefer-inline')
  void validate() {
    if ((_value & golden._value) != golden._value) {
      _throwMissingFields();
    }
  }

  void _throwMissingFields() {
    final missing = <String>[];
    if ((_value & _loginCountBit) == 0) missing.add(nameLoginCount);
    if ((_value & _lastLoginBit) == 0) missing.add(nameLastLogin);
    if ((_value & _locationBit) == 0) missing.add(nameLocation);
    throw CodableException(
      'Missing required fields for SmallMetadata: ${missing.join(", ")}',
    );
  }
}

SmallMetadata _$SmallMetadataFromReader(JsonTokenReader reader) {
  reader.beginObject();

  int? loginCount;
  String? lastLogin;
  SmallLocation? location;
  var seen = _$SmallMetadataSchema.none;

  while (reader.hasNext()) {
    switch (reader.selectName(_$SmallMetadataSchema.options)) {
      case _$SmallMetadataSchema.keyLoginCount:
        loginCount = reader.readInt();
        seen |= _$SmallMetadataSchema.loginCount;
        break;
      case _$SmallMetadataSchema.keyLastLogin:
        lastLogin = reader.readString();
        seen |= _$SmallMetadataSchema.lastLogin;
        break;
      case _$SmallMetadataSchema.keyLocation:
        location = SmallLocation.fromReader(reader);
        seen |= _$SmallMetadataSchema.location;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  seen.validate();

  return SmallMetadata(
    loginCount: loginCount!,
    lastLogin: lastLogin!,
    location: location!,
  );
}

void _$SmallMetadataToWriter(SmallMetadata instance, JsonTokenWriter writer) {
  writer.beginObject();
  writer.writeNameBytes(_$SmallMetadataSchema.nameLoginCountBytes);
  writer.writeInt(instance.loginCount);
  writer.writeNameBytes(_$SmallMetadataSchema.nameLastLoginBytes);
  writer.writeString(instance.lastLogin);
  writer.writeNameBytes(_$SmallMetadataSchema.nameLocationBytes);
  instance.location.toWriter(writer);
  writer.endObject();
}

// =============================================================================
// 3. Unified Schema Descriptor for SmallDocument
// =============================================================================
extension type const _$SmallDocumentSchema(int _value) {
  static const String nameId = 'id';
  static const String nameUuid = 'uuid';
  static const String nameName = 'name';
  static const String nameEmail = 'email';
  static const String nameIsActive = 'isActive';
  static const String nameBalance = 'balance';
  static const String nameAge = 'age';
  static const String nameRoles = 'roles';
  static const String nameMetadata = 'metadata';
  static const String nameTags = 'tags';

  static final Uint8List nameIdBytes = Uint8List.fromList(const [105, 100]);
  static final Uint8List nameUuidBytes = Uint8List.fromList(const [
    117,
    117,
    105,
    100,
  ]);
  static final Uint8List nameNameBytes = Uint8List.fromList(const [
    110,
    97,
    109,
    101,
  ]);
  static final Uint8List nameEmailBytes = Uint8List.fromList(const [
    101,
    109,
    97,
    105,
    108,
  ]);
  static final Uint8List nameIsActiveBytes = Uint8List.fromList(const [
    105,
    115,
    65,
    99,
    116,
    105,
    118,
    101,
  ]);
  static final Uint8List nameBalanceBytes = Uint8List.fromList(const [
    98,
    97,
    108,
    97,
    110,
    99,
    101,
  ]);
  static final Uint8List nameAgeBytes = Uint8List.fromList(const [
    97,
    103,
    101,
  ]);
  static final Uint8List nameRolesBytes = Uint8List.fromList(const [
    114,
    111,
    108,
    101,
    115,
  ]);
  static final Uint8List nameMetadataBytes = Uint8List.fromList(const [
    109,
    101,
    116,
    97,
    100,
    97,
    116,
    97,
  ]);
  static final Uint8List nameTagsBytes = Uint8List.fromList(const [
    116,
    97,
    103,
    115,
  ]);

  static const int keyId = 0;
  static const int keyUuid = 1;
  static const int keyName = 2;
  static const int keyEmail = 3;
  static const int keyIsActive = 4;
  static const int keyBalance = 5;
  static const int keyAge = 6;
  static const int keyRoles = 7;
  static const int keyMetadata = 8;
  static const int keyTags = 9;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameId,
    nameUuid,
    nameName,
    nameEmail,
    nameIsActive,
    nameBalance,
    nameAge,
    nameRoles,
    nameMetadata,
    nameTags,
  ]);

  static const _$SmallDocumentSchema none = _$SmallDocumentSchema(0);
  static const int _idBit = 1 << 0;
  static const _$SmallDocumentSchema id = _$SmallDocumentSchema(_idBit);
  static const int _uuidBit = 1 << 1;
  static const _$SmallDocumentSchema uuid = _$SmallDocumentSchema(_uuidBit);
  static const int _nameBit = 1 << 2;
  static const _$SmallDocumentSchema name = _$SmallDocumentSchema(_nameBit);
  static const int _emailBit = 1 << 3;
  static const _$SmallDocumentSchema email = _$SmallDocumentSchema(_emailBit);
  static const int _isActiveBit = 1 << 4;
  static const _$SmallDocumentSchema isActive = _$SmallDocumentSchema(
    _isActiveBit,
  );
  static const int _balanceBit = 1 << 5;
  static const _$SmallDocumentSchema balance = _$SmallDocumentSchema(
    _balanceBit,
  );
  static const int _ageBit = 1 << 6;
  static const _$SmallDocumentSchema age = _$SmallDocumentSchema(_ageBit);
  static const int _rolesBit = 1 << 7;
  static const _$SmallDocumentSchema roles = _$SmallDocumentSchema(_rolesBit);
  static const int _metadataBit = 1 << 8;
  static const _$SmallDocumentSchema metadata = _$SmallDocumentSchema(
    _metadataBit,
  );
  static const int _tagsBit = 1 << 9;
  static const _$SmallDocumentSchema tags = _$SmallDocumentSchema(_tagsBit);

  static const _$SmallDocumentSchema golden = _$SmallDocumentSchema(
    _idBit |
        _uuidBit |
        _nameBit |
        _emailBit |
        _isActiveBit |
        _balanceBit |
        _ageBit |
        _rolesBit |
        _metadataBit |
        _tagsBit,
  );

  @pragma('vm:prefer-inline')
  _$SmallDocumentSchema operator |(_$SmallDocumentSchema other) =>
      _$SmallDocumentSchema(_value | other._value);

  @pragma('vm:prefer-inline')
  void validate() {
    if ((_value & golden._value) != golden._value) {
      _throwMissingFields();
    }
  }

  void _throwMissingFields() {
    final missing = <String>[];
    if ((_value & _idBit) == 0) missing.add(nameId);
    if ((_value & _uuidBit) == 0) missing.add(nameUuid);
    if ((_value & _nameBit) == 0) missing.add(nameName);
    if ((_value & _emailBit) == 0) missing.add(nameEmail);
    if ((_value & _isActiveBit) == 0) missing.add(nameIsActive);
    if ((_value & _balanceBit) == 0) missing.add(nameBalance);
    if ((_value & _ageBit) == 0) missing.add(nameAge);
    if ((_value & _rolesBit) == 0) missing.add(nameRoles);
    if ((_value & _metadataBit) == 0) missing.add(nameMetadata);
    if ((_value & _tagsBit) == 0) missing.add(nameTags);
    throw CodableException(
      'Missing required fields for SmallDocument: ${missing.join(", ")}',
    );
  }
}

SmallDocument _$SmallDocumentFromReader(JsonTokenReader reader) {
  reader.beginObject();

  int? id;
  String? uuid;
  String? name;
  String? email;
  bool? isActive;
  double? balance;
  int? age;
  List<String>? roles;
  SmallMetadata? metadata;
  List<String>? tags;
  var seen = _$SmallDocumentSchema.none;

  while (reader.hasNext()) {
    switch (reader.selectName(_$SmallDocumentSchema.options)) {
      case _$SmallDocumentSchema.keyId:
        id = reader.readInt();
        seen |= _$SmallDocumentSchema.id;
        break;
      case _$SmallDocumentSchema.keyUuid:
        uuid = reader.readString();
        seen |= _$SmallDocumentSchema.uuid;
        break;
      case _$SmallDocumentSchema.keyName:
        name = reader.readString();
        seen |= _$SmallDocumentSchema.name;
        break;
      case _$SmallDocumentSchema.keyEmail:
        email = reader.readString();
        seen |= _$SmallDocumentSchema.email;
        break;
      case _$SmallDocumentSchema.keyIsActive:
        isActive = reader.readBool();
        seen |= _$SmallDocumentSchema.isActive;
        break;
      case _$SmallDocumentSchema.keyBalance:
        balance = reader.readDouble();
        seen |= _$SmallDocumentSchema.balance;
        break;
      case _$SmallDocumentSchema.keyAge:
        age = reader.readInt();
        seen |= _$SmallDocumentSchema.age;
        break;
      case _$SmallDocumentSchema.keyRoles:
        reader.beginArray();
        final list = <String>[];
        while (reader.hasNext()) {
          list.add(reader.readString());
        }
        reader.endArray();
        roles = list;
        seen |= _$SmallDocumentSchema.roles;
        break;
      case _$SmallDocumentSchema.keyMetadata:
        metadata = SmallMetadata.fromReader(reader);
        seen |= _$SmallDocumentSchema.metadata;
        break;
      case _$SmallDocumentSchema.keyTags:
        reader.beginArray();
        final list = <String>[];
        while (reader.hasNext()) {
          list.add(reader.readString());
        }
        reader.endArray();
        tags = list;
        seen |= _$SmallDocumentSchema.tags;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  seen.validate();

  return SmallDocument(
    id: id!,
    uuid: uuid!,
    name: name!,
    email: email!,
    isActive: isActive!,
    balance: balance!,
    age: age!,
    roles: roles!,
    metadata: metadata!,
    tags: tags!,
  );
}

void _$SmallDocumentToWriter(SmallDocument instance, JsonTokenWriter writer) {
  writer.beginObject();
  writer.writeNameBytes(_$SmallDocumentSchema.nameIdBytes);
  writer.writeInt(instance.id);
  writer.writeNameBytes(_$SmallDocumentSchema.nameUuidBytes);
  writer.writeString(instance.uuid);
  writer.writeNameBytes(_$SmallDocumentSchema.nameNameBytes);
  writer.writeString(instance.name);
  writer.writeNameBytes(_$SmallDocumentSchema.nameEmailBytes);
  writer.writeString(instance.email);
  writer.writeNameBytes(_$SmallDocumentSchema.nameIsActiveBytes);
  writer.writeBool(instance.isActive);
  writer.writeNameBytes(_$SmallDocumentSchema.nameBalanceBytes);
  writer.writeDouble(instance.balance);
  writer.writeNameBytes(_$SmallDocumentSchema.nameAgeBytes);
  writer.writeInt(instance.age);
  writer.writeNameBytes(_$SmallDocumentSchema.nameRolesBytes);
  writer.beginArray();
  for (final r in instance.roles) {
    writer.writeString(r);
  }
  writer.endArray();
  writer.writeNameBytes(_$SmallDocumentSchema.nameMetadataBytes);
  instance.metadata.toWriter(writer);
  writer.writeNameBytes(_$SmallDocumentSchema.nameTagsBytes);
  writer.beginArray();
  for (final t in instance.tags) {
    writer.writeString(t);
  }
  writer.endArray();
  writer.endObject();
}
