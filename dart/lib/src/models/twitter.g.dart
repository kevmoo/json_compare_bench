// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitter.dart';

// **************************************************************************
// CodableGenerator
// **************************************************************************

// =============================================================================
// 1. TwitterMetadata
// =============================================================================
extension type const _$TwitterMetadataSchema(int _value) {
  static const String nameResultType = 'result_type';
  static const String nameIsoLanguageCode = 'iso_language_code';

  static final Uint8List nameResultTypeBytes = Uint8List.fromList(const [
    114,
    101,
    115,
    117,
    108,
    116,
    95,
    116,
    121,
    112,
    101,
  ]);
  static final Uint8List nameIsoLanguageCodeBytes = Uint8List.fromList(const [
    105,
    115,
    111,
    95,
    108,
    97,
    110,
    103,
    117,
    97,
    103,
    101,
    95,
    99,
    111,
    100,
    101,
  ]);

  static const int keyResultType = 0;
  static const int keyIsoLanguageCode = 1;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameResultType,
    nameIsoLanguageCode,
  ]);

  static const _$TwitterMetadataSchema none = _$TwitterMetadataSchema(0);
}

TwitterMetadata _$TwitterMetadataFromReader(JsonTokenReader reader) {
  reader.beginObject();
  String? resultType;
  String? isoLanguageCode;

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterMetadataSchema.options)) {
      case _$TwitterMetadataSchema.keyResultType:
        resultType = reader.readString();
        break;
      case _$TwitterMetadataSchema.keyIsoLanguageCode:
        isoLanguageCode = reader.readString();
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  return TwitterMetadata(
    resultType: resultType ?? '',
    isoLanguageCode: isoLanguageCode ?? '',
  );
}

void _$TwitterMetadataToWriter(
  TwitterMetadata instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterMetadataSchema.nameResultTypeBytes);
  writer.writeString(instance.resultType);
  writer.writeNameBytes(_$TwitterMetadataSchema.nameIsoLanguageCodeBytes);
  writer.writeString(instance.isoLanguageCode);
  writer.endObject();
}

// =============================================================================
// 2. TwitterUserMention
// =============================================================================
extension type const _$TwitterUserMentionSchema(int _value) {
  static const String nameScreenName = 'screen_name';
  static const String nameName = 'name';
  static const String nameId = 'id';
  static const String nameIdStr = 'id_str';
  static const String nameIndices = 'indices';

  static final Uint8List nameScreenNameBytes = Uint8List.fromList(const [
    115,
    99,
    114,
    101,
    101,
    110,
    95,
    110,
    97,
    109,
    101,
  ]);
  static final Uint8List nameNameBytes = Uint8List.fromList(const [
    110,
    97,
    109,
    101,
  ]);
  static final Uint8List nameIdBytes = Uint8List.fromList(const [105, 100]);
  static final Uint8List nameIdStrBytes = Uint8List.fromList(const [
    105,
    100,
    95,
    115,
    116,
    114,
  ]);
  static final Uint8List nameIndicesBytes = Uint8List.fromList(const [
    105,
    110,
    100,
    105,
    99,
    101,
    115,
  ]);

  static const int keyScreenName = 0;
  static const int keyName = 1;
  static const int keyId = 2;
  static const int keyIdStr = 3;
  static const int keyIndices = 4;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameScreenName,
    nameName,
    nameId,
    nameIdStr,
    nameIndices,
  ]);

  static const _$TwitterUserMentionSchema none = _$TwitterUserMentionSchema(0);
}

TwitterUserMention _$TwitterUserMentionFromReader(JsonTokenReader reader) {
  reader.beginObject();
  String? screenName;
  String? name;
  int? id;
  String? idStr;
  List<int> indices = const [];

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterUserMentionSchema.options)) {
      case _$TwitterUserMentionSchema.keyScreenName:
        screenName = reader.readString();
        break;
      case _$TwitterUserMentionSchema.keyName:
        name = reader.readString();
        break;
      case _$TwitterUserMentionSchema.keyId:
        id = reader.readInt();
        break;
      case _$TwitterUserMentionSchema.keyIdStr:
        idStr = reader.readString();
        break;
      case _$TwitterUserMentionSchema.keyIndices:
        reader.beginArray();
        final list = <int>[];
        while (reader.hasNext()) {
          list.add(reader.readInt());
        }
        reader.endArray();
        indices = list;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  return TwitterUserMention(
    screenName: screenName ?? '',
    name: name ?? '',
    id: id ?? 0,
    idStr: idStr ?? '',
    indices: indices,
  );
}

void _$TwitterUserMentionToWriter(
  TwitterUserMention instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterUserMentionSchema.nameScreenNameBytes);
  writer.writeString(instance.screenName);
  writer.writeNameBytes(_$TwitterUserMentionSchema.nameNameBytes);
  writer.writeString(instance.name);
  writer.writeNameBytes(_$TwitterUserMentionSchema.nameIdBytes);
  writer.writeInt(instance.id);
  writer.writeNameBytes(_$TwitterUserMentionSchema.nameIdStrBytes);
  writer.writeString(instance.idStr);
  writer.writeNameBytes(_$TwitterUserMentionSchema.nameIndicesBytes);
  writer.beginArray();
  for (final idx in instance.indices) {
    writer.writeInt(idx);
  }
  writer.endArray();
  writer.endObject();
}

// =============================================================================
// 3. TwitterUrl
// =============================================================================
extension type const _$TwitterUrlSchema(int _value) {
  static const String nameUrl = 'url';
  static const String nameExpandedUrl = 'expanded_url';
  static const String nameDisplayUrl = 'display_url';
  static const String nameIndices = 'indices';

  static final Uint8List nameUrlBytes = Uint8List.fromList(const [
    117,
    114,
    108,
  ]);
  static final Uint8List nameExpandedUrlBytes = Uint8List.fromList(const [
    101,
    120,
    112,
    97,
    110,
    100,
    101,
    100,
    95,
    117,
    114,
    108,
  ]);
  static final Uint8List nameDisplayUrlBytes = Uint8List.fromList(const [
    100,
    105,
    115,
    112,
    108,
    97,
    121,
    95,
    117,
    114,
    108,
  ]);
  static final Uint8List nameIndicesBytes = Uint8List.fromList(const [
    105,
    110,
    100,
    105,
    99,
    101,
    115,
  ]);

  static const int keyUrl = 0;
  static const int keyExpandedUrl = 1;
  static const int keyDisplayUrl = 2;
  static const int keyIndices = 3;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameUrl,
    nameExpandedUrl,
    nameDisplayUrl,
    nameIndices,
  ]);

  static const _$TwitterUrlSchema none = _$TwitterUrlSchema(0);
}

TwitterUrl _$TwitterUrlFromReader(JsonTokenReader reader) {
  reader.beginObject();
  String? url;
  String? expandedUrl;
  String? displayUrl;
  List<int> indices = const [];

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterUrlSchema.options)) {
      case _$TwitterUrlSchema.keyUrl:
        url = reader.readString();
        break;
      case _$TwitterUrlSchema.keyExpandedUrl:
        expandedUrl = reader.readString();
        break;
      case _$TwitterUrlSchema.keyDisplayUrl:
        displayUrl = reader.readString();
        break;
      case _$TwitterUrlSchema.keyIndices:
        reader.beginArray();
        final list = <int>[];
        while (reader.hasNext()) {
          list.add(reader.readInt());
        }
        reader.endArray();
        indices = list;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  return TwitterUrl(
    url: url ?? '',
    expandedUrl: expandedUrl ?? '',
    displayUrl: displayUrl ?? '',
    indices: indices,
  );
}

void _$TwitterUrlToWriter(TwitterUrl instance, JsonTokenWriter writer) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterUrlSchema.nameUrlBytes);
  writer.writeString(instance.url);
  writer.writeNameBytes(_$TwitterUrlSchema.nameExpandedUrlBytes);
  writer.writeString(instance.expandedUrl);
  writer.writeNameBytes(_$TwitterUrlSchema.nameDisplayUrlBytes);
  writer.writeString(instance.displayUrl);
  writer.writeNameBytes(_$TwitterUrlSchema.nameIndicesBytes);
  writer.beginArray();
  for (final idx in instance.indices) {
    writer.writeInt(idx);
  }
  writer.endArray();
  writer.endObject();
}

// =============================================================================
// 4. TwitterEntitiesUrls
// =============================================================================
extension type const _$TwitterEntitiesUrlsSchema(int _value) {
  static const String nameUrls = 'urls';
  static final Uint8List nameUrlsBytes = Uint8List.fromList(const [
    117,
    114,
    108,
    115,
  ]);
  static const int keyUrls = 0;
  static final JsonKeyOptions options = JsonKeyOptions.of(const [nameUrls]);
  static const _$TwitterEntitiesUrlsSchema none = _$TwitterEntitiesUrlsSchema(
    0,
  );
}

TwitterEntitiesUrls _$TwitterEntitiesUrlsFromReader(JsonTokenReader reader) {
  reader.beginObject();
  List<TwitterUrl> urls = const [];

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterEntitiesUrlsSchema.options)) {
      case _$TwitterEntitiesUrlsSchema.keyUrls:
        reader.beginArray();
        final list = <TwitterUrl>[];
        while (reader.hasNext()) {
          list.add(_$TwitterUrlFromReader(reader));
        }
        reader.endArray();
        urls = list;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  return TwitterEntitiesUrls(urls: urls);
}

void _$TwitterEntitiesUrlsToWriter(
  TwitterEntitiesUrls instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterEntitiesUrlsSchema.nameUrlsBytes);
  writer.beginArray();
  for (final u in instance.urls) {
    _$TwitterUrlToWriter(u, writer);
  }
  writer.endArray();
  writer.endObject();
}

// =============================================================================
// 5. TwitterUserEntities
// =============================================================================
extension type const _$TwitterUserEntitiesSchema(int _value) {
  static const String nameUrl = 'url';
  static const String nameDescription = 'description';

  static final Uint8List nameUrlBytes = Uint8List.fromList(const [
    117,
    114,
    108,
  ]);
  static final Uint8List nameDescriptionBytes = Uint8List.fromList(const [
    100,
    101,
    115,
    99,
    114,
    105,
    112,
    116,
    105,
    111,
    110,
  ]);

  static const int keyUrl = 0;
  static const int keyDescription = 1;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameUrl,
    nameDescription,
  ]);
  static const _$TwitterUserEntitiesSchema none = _$TwitterUserEntitiesSchema(
    0,
  );
}

TwitterUserEntities _$TwitterUserEntitiesFromReader(JsonTokenReader reader) {
  reader.beginObject();
  TwitterEntitiesUrls? url;
  TwitterEntitiesUrls? description;

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterUserEntitiesSchema.options)) {
      case _$TwitterUserEntitiesSchema.keyUrl:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          url = _$TwitterEntitiesUrlsFromReader(reader);
        }
        break;
      case _$TwitterUserEntitiesSchema.keyDescription:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          description = _$TwitterEntitiesUrlsFromReader(reader);
        }
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  return TwitterUserEntities(url: url, description: description);
}

void _$TwitterUserEntitiesToWriter(
  TwitterUserEntities instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  if (instance.url != null) {
    writer.writeNameBytes(_$TwitterUserEntitiesSchema.nameUrlBytes);
    _$TwitterEntitiesUrlsToWriter(instance.url!, writer);
  }
  if (instance.description != null) {
    writer.writeNameBytes(_$TwitterUserEntitiesSchema.nameDescriptionBytes);
    _$TwitterEntitiesUrlsToWriter(instance.description!, writer);
  }
  writer.endObject();
}

// =============================================================================
// 6. TwitterEntities
// =============================================================================
extension type const _$TwitterEntitiesSchema(int _value) {
  static const String nameUrls = 'urls';
  static const String nameUserMentions = 'user_mentions';

  static final Uint8List nameUrlsBytes = Uint8List.fromList(const [
    117,
    114,
    108,
    115,
  ]);
  static final Uint8List nameUserMentionsBytes = Uint8List.fromList(const [
    117,
    115,
    101,
    114,
    95,
    109,
    101,
    110,
    116,
    105,
    111,
    110,
    115,
  ]);

  static const int keyUrls = 0;
  static const int keyUserMentions = 1;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameUrls,
    nameUserMentions,
  ]);
  static const _$TwitterEntitiesSchema none = _$TwitterEntitiesSchema(0);
}

TwitterEntities _$TwitterEntitiesFromReader(JsonTokenReader reader) {
  reader.beginObject();
  List<TwitterUrl> urls = const [];
  List<TwitterUserMention> userMentions = const [];

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterEntitiesSchema.options)) {
      case _$TwitterEntitiesSchema.keyUrls:
        reader.beginArray();
        final list = <TwitterUrl>[];
        while (reader.hasNext()) {
          list.add(_$TwitterUrlFromReader(reader));
        }
        reader.endArray();
        urls = list;
        break;
      case _$TwitterEntitiesSchema.keyUserMentions:
        reader.beginArray();
        final list = <TwitterUserMention>[];
        while (reader.hasNext()) {
          list.add(_$TwitterUserMentionFromReader(reader));
        }
        reader.endArray();
        userMentions = list;
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();
  return TwitterEntities(urls: urls, userMentions: userMentions);
}

void _$TwitterEntitiesToWriter(
  TwitterEntities instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterEntitiesSchema.nameUrlsBytes);
  writer.beginArray();
  for (final u in instance.urls) {
    _$TwitterUrlToWriter(u, writer);
  }
  writer.endArray();
  writer.writeNameBytes(_$TwitterEntitiesSchema.nameUserMentionsBytes);
  writer.beginArray();
  for (final m in instance.userMentions) {
    _$TwitterUserMentionToWriter(m, writer);
  }
  writer.endArray();
  writer.endObject();
}

// =============================================================================
// 7. TwitterUser
// =============================================================================
extension type const _$TwitterUserSchema(int _value) {
  static const String nameId = 'id';
  static const String nameIdStr = 'id_str';
  static const String nameName = 'name';
  static const String nameScreenName = 'screen_name';
  static const String nameLocation = 'location';
  static const String nameDescription = 'description';
  static const String nameUrl = 'url';
  static const String nameEntities = 'entities';
  static const String nameProtected = 'protected';
  static const String nameFollowersCount = 'followers_count';
  static const String nameFriendsCount = 'friends_count';
  static const String nameListedCount = 'listed_count';
  static const String nameCreatedAt = 'created_at';
  static const String nameFavouritesCount = 'favourites_count';
  static const String nameUtcOffset = 'utc_offset';
  static const String nameTimeZone = 'time_zone';
  static const String nameGeoEnabled = 'geo_enabled';
  static const String nameVerified = 'verified';
  static const String nameStatusesCount = 'statuses_count';
  static const String nameLang = 'lang';
  static const String nameContributorsEnabled = 'contributors_enabled';
  static const String nameIsTranslator = 'is_translator';
  static const String nameIsTranslationEnabled = 'is_translation_enabled';
  static const String nameProfileBackgroundColor = 'profile_background_color';
  static const String nameProfileBackgroundImageUrl =
      'profile_background_image_url';
  static const String nameProfileBackgroundImageUrlHttps =
      'profile_background_image_url_https';
  static const String nameProfileBackgroundTile = 'profile_background_tile';
  static const String nameProfileImageUrl = 'profile_image_url';
  static const String nameProfileImageUrlHttps = 'profile_image_url_https';
  static const String nameProfileBannerUrl = 'profile_banner_url';
  static const String nameProfileLinkColor = 'profile_link_color';
  static const String nameProfileSidebarBorderColor =
      'profile_sidebar_border_color';
  static const String nameProfileSidebarFillColor =
      'profile_sidebar_fill_color';
  static const String nameProfileTextColor = 'profile_text_color';
  static const String nameProfileUseBackgroundImage =
      'profile_use_background_image';
  static const String nameDefaultProfile = 'default_profile';
  static const String nameDefaultProfileImage = 'default_profile_image';
  static const String nameFollowing = 'following';
  static const String nameFollowRequestSent = 'follow_request_sent';
  static const String nameNotifications = 'notifications';

  static final Uint8List nameIdBytes = Uint8List.fromList(const [105, 100]);
  static final Uint8List nameIdStrBytes = Uint8List.fromList(const [
    105,
    100,
    95,
    115,
    116,
    114,
  ]);
  static final Uint8List nameNameBytes = Uint8List.fromList(const [
    110,
    97,
    109,
    101,
  ]);
  static final Uint8List nameScreenNameBytes = Uint8List.fromList(const [
    115,
    99,
    114,
    101,
    101,
    110,
    95,
    110,
    97,
    109,
    101,
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
  static final Uint8List nameDescriptionBytes = Uint8List.fromList(const [
    100,
    101,
    115,
    99,
    114,
    105,
    112,
    116,
    105,
    111,
    110,
  ]);
  static final Uint8List nameUrlBytes = Uint8List.fromList(const [
    117,
    114,
    108,
  ]);
  static final Uint8List nameEntitiesBytes = Uint8List.fromList(const [
    101,
    110,
    116,
    105,
    116,
    105,
    101,
    115,
  ]);
  static final Uint8List nameProtectedBytes = Uint8List.fromList(const [
    112,
    114,
    111,
    116,
    101,
    99,
    116,
    101,
    100,
  ]);
  static final Uint8List nameFollowersCountBytes = Uint8List.fromList(const [
    102,
    111,
    108,
    108,
    111,
    119,
    101,
    114,
    115,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameFriendsCountBytes = Uint8List.fromList(const [
    102,
    114,
    105,
    101,
    110,
    100,
    115,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameListedCountBytes = Uint8List.fromList(const [
    108,
    105,
    115,
    116,
    101,
    100,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameCreatedAtBytes = Uint8List.fromList(const [
    99,
    114,
    101,
    97,
    116,
    101,
    100,
    95,
    97,
    116,
  ]);
  static final Uint8List nameFavouritesCountBytes = Uint8List.fromList(const [
    102,
    97,
    118,
    111,
    117,
    114,
    105,
    116,
    101,
    115,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameUtcOffsetBytes = Uint8List.fromList(const [
    117,
    116,
    99,
    95,
    111,
    102,
    102,
    115,
    101,
    116,
  ]);
  static final Uint8List nameTimeZoneBytes = Uint8List.fromList(const [
    116,
    105,
    109,
    101,
    95,
    122,
    111,
    110,
    101,
  ]);
  static final Uint8List nameGeoEnabledBytes = Uint8List.fromList(const [
    103,
    101,
    111,
    95,
    101,
    110,
    97,
    98,
    108,
    101,
    100,
  ]);
  static final Uint8List nameVerifiedBytes = Uint8List.fromList(const [
    118,
    101,
    114,
    105,
    102,
    105,
    101,
    100,
  ]);
  static final Uint8List nameStatusesCountBytes = Uint8List.fromList(const [
    115,
    116,
    97,
    116,
    117,
    115,
    101,
    115,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameLangBytes = Uint8List.fromList(const [
    108,
    97,
    110,
    103,
  ]);
  static final Uint8List nameContributorsEnabledBytes =
      Uint8List.fromList(const [
        99,
        111,
        110,
        116,
        114,
        105,
        98,
        117,
        116,
        111,
        114,
        115,
        95,
        101,
        110,
        97,
        98,
        108,
        101,
        100,
      ]);
  static final Uint8List nameIsTranslatorBytes = Uint8List.fromList(const [
    105,
    115,
    95,
    116,
    114,
    97,
    110,
    115,
    108,
    97,
    116,
    111,
    114,
  ]);
  static final Uint8List nameIsTranslationEnabledBytes =
      Uint8List.fromList(const [
        105,
        115,
        95,
        116,
        114,
        97,
        110,
        115,
        108,
        97,
        116,
        105,
        111,
        110,
        95,
        101,
        110,
        97,
        98,
        108,
        101,
        100,
      ]);
  static final Uint8List nameProfileBackgroundColorBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        98,
        97,
        99,
        107,
        103,
        114,
        111,
        117,
        110,
        100,
        95,
        99,
        111,
        108,
        111,
        114,
      ]);
  static final Uint8List nameProfileBackgroundImageUrlBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        98,
        97,
        99,
        107,
        103,
        114,
        111,
        117,
        110,
        100,
        95,
        105,
        109,
        97,
        103,
        101,
        95,
        117,
        114,
        108,
      ]);
  static final Uint8List nameProfileBackgroundImageUrlHttpsBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        98,
        97,
        99,
        107,
        103,
        114,
        111,
        117,
        110,
        100,
        95,
        105,
        109,
        97,
        103,
        101,
        95,
        117,
        114,
        108,
        95,
        104,
        116,
        116,
        112,
        115,
      ]);
  static final Uint8List nameProfileBackgroundTileBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        98,
        97,
        99,
        107,
        103,
        114,
        111,
        117,
        110,
        100,
        95,
        116,
        105,
        108,
        101,
      ]);
  static final Uint8List nameProfileImageUrlBytes = Uint8List.fromList(const [
    112,
    114,
    111,
    102,
    105,
    108,
    101,
    95,
    105,
    109,
    97,
    103,
    101,
    95,
    117,
    114,
    108,
  ]);
  static final Uint8List nameProfileImageUrlHttpsBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        105,
        109,
        97,
        103,
        101,
        95,
        117,
        114,
        108,
        95,
        104,
        116,
        116,
        112,
        115,
      ]);
  static final Uint8List nameProfileBannerUrlBytes = Uint8List.fromList(const [
    112,
    114,
    111,
    102,
    105,
    108,
    101,
    95,
    98,
    97,
    110,
    110,
    101,
    114,
    95,
    117,
    114,
    108,
  ]);
  static final Uint8List nameProfileLinkColorBytes = Uint8List.fromList(const [
    112,
    114,
    111,
    102,
    105,
    108,
    101,
    95,
    108,
    105,
    110,
    107,
    95,
    99,
    111,
    108,
    111,
    114,
  ]);
  static final Uint8List nameProfileSidebarBorderColorBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        115,
        105,
        100,
        101,
        98,
        97,
        114,
        95,
        98,
        111,
        114,
        100,
        101,
        114,
        95,
        99,
        111,
        108,
        111,
        114,
      ]);
  static final Uint8List nameProfileSidebarFillColorBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        115,
        105,
        100,
        101,
        98,
        97,
        114,
        95,
        102,
        105,
        108,
        108,
        95,
        99,
        111,
        108,
        111,
        114,
      ]);
  static final Uint8List nameProfileTextColorBytes = Uint8List.fromList(const [
    112,
    114,
    111,
    102,
    105,
    108,
    101,
    95,
    116,
    101,
    120,
    116,
    95,
    99,
    111,
    108,
    111,
    114,
  ]);
  static final Uint8List nameProfileUseBackgroundImageBytes =
      Uint8List.fromList(const [
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        117,
        115,
        101,
        95,
        98,
        97,
        99,
        107,
        103,
        114,
        111,
        117,
        110,
        100,
        95,
        105,
        109,
        97,
        103,
        101,
      ]);
  static final Uint8List nameDefaultProfileBytes = Uint8List.fromList(const [
    100,
    101,
    102,
    97,
    117,
    108,
    116,
    95,
    112,
    114,
    111,
    102,
    105,
    108,
    101,
  ]);
  static final Uint8List nameDefaultProfileImageBytes =
      Uint8List.fromList(const [
        100,
        101,
        102,
        97,
        117,
        108,
        116,
        95,
        112,
        114,
        111,
        102,
        105,
        108,
        101,
        95,
        105,
        109,
        97,
        103,
        101,
      ]);
  static final Uint8List nameFollowingBytes = Uint8List.fromList(const [
    102,
    111,
    108,
    108,
    111,
    119,
    105,
    110,
    103,
  ]);
  static final Uint8List nameFollowRequestSentBytes = Uint8List.fromList(const [
    102,
    111,
    108,
    108,
    111,
    119,
    95,
    114,
    101,
    113,
    117,
    101,
    115,
    116,
    95,
    115,
    101,
    110,
    116,
  ]);
  static final Uint8List nameNotificationsBytes = Uint8List.fromList(const [
    110,
    111,
    116,
    105,
    102,
    105,
    99,
    97,
    116,
    105,
    111,
    110,
    115,
  ]);

  static const int keyId = 0;
  static const int keyIdStr = 1;
  static const int keyName = 2;
  static const int keyScreenName = 3;
  static const int keyLocation = 4;
  static const int keyDescription = 5;
  static const int keyUrl = 6;
  static const int keyEntities = 7;
  static const int keyProtected = 8;
  static const int keyFollowersCount = 9;
  static const int keyFriendsCount = 10;
  static const int keyListedCount = 11;
  static const int keyCreatedAt = 12;
  static const int keyFavouritesCount = 13;
  static const int keyUtcOffset = 14;
  static const int keyTimeZone = 15;
  static const int keyGeoEnabled = 16;
  static const int keyVerified = 17;
  static const int keyStatusesCount = 18;
  static const int keyLang = 19;
  static const int keyContributorsEnabled = 20;
  static const int keyIsTranslator = 21;
  static const int keyIsTranslationEnabled = 22;
  static const int keyProfileBackgroundColor = 23;
  static const int keyProfileBackgroundImageUrl = 24;
  static const int keyProfileBackgroundImageUrlHttps = 25;
  static const int keyProfileBackgroundTile = 26;
  static const int keyProfileImageUrl = 27;
  static const int keyProfileImageUrlHttps = 28;
  static const int keyProfileBannerUrl = 29;
  static const int keyProfileLinkColor = 30;
  static const int keyProfileSidebarBorderColor = 31;
  static const int keyProfileSidebarFillColor = 32;
  static const int keyProfileTextColor = 33;
  static const int keyProfileUseBackgroundImage = 34;
  static const int keyDefaultProfile = 35;
  static const int keyDefaultProfileImage = 36;
  static const int keyFollowing = 37;
  static const int keyFollowRequestSent = 38;
  static const int keyNotifications = 39;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameId,
    nameIdStr,
    nameName,
    nameScreenName,
    nameLocation,
    nameDescription,
    nameUrl,
    nameEntities,
    nameProtected,
    nameFollowersCount,
    nameFriendsCount,
    nameListedCount,
    nameCreatedAt,
    nameFavouritesCount,
    nameUtcOffset,
    nameTimeZone,
    nameGeoEnabled,
    nameVerified,
    nameStatusesCount,
    nameLang,
    nameContributorsEnabled,
    nameIsTranslator,
    nameIsTranslationEnabled,
    nameProfileBackgroundColor,
    nameProfileBackgroundImageUrl,
    nameProfileBackgroundImageUrlHttps,
    nameProfileBackgroundTile,
    nameProfileImageUrl,
    nameProfileImageUrlHttps,
    nameProfileBannerUrl,
    nameProfileLinkColor,
    nameProfileSidebarBorderColor,
    nameProfileSidebarFillColor,
    nameProfileTextColor,
    nameProfileUseBackgroundImage,
    nameDefaultProfile,
    nameDefaultProfileImage,
    nameFollowing,
    nameFollowRequestSent,
    nameNotifications,
  ]);

  static const _$TwitterUserSchema none = _$TwitterUserSchema(0);
}

TwitterUser _$TwitterUserFromReader(JsonTokenReader reader) {
  reader.beginObject();

  int? id;
  String? idStr;
  String? name;
  String? screenName;
  String location = '';
  String description = '';
  String? url;
  TwitterUserEntities? entities;
  bool protected = false;
  int followersCount = 0;
  int friendsCount = 0;
  int listedCount = 0;
  String? createdAt;
  int favouritesCount = 0;
  int? utcOffset;
  String? timeZone;
  bool geoEnabled = false;
  bool verified = false;
  int statusesCount = 0;
  String lang = 'en';
  bool contributorsEnabled = false;
  bool isTranslator = false;
  bool isTranslationEnabled = false;
  String profileBackgroundColor = '';
  String profileBackgroundImageUrl = '';
  String profileBackgroundImageUrlHttps = '';
  bool profileBackgroundTile = false;
  String profileImageUrl = '';
  String profileImageUrlHttps = '';
  String? profileBannerUrl;
  String profileLinkColor = '';
  String profileSidebarBorderColor = '';
  String profileSidebarFillColor = '';
  String profileTextColor = '';
  bool profileUseBackgroundImage = false;
  bool defaultProfile = false;
  bool defaultProfileImage = false;
  bool following = false;
  bool followRequestSent = false;
  bool notifications = false;

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterUserSchema.options)) {
      case _$TwitterUserSchema.keyId:
        id = reader.readInt();
        break;
      case _$TwitterUserSchema.keyIdStr:
        idStr = reader.readString();
        break;
      case _$TwitterUserSchema.keyName:
        name = reader.readString();
        break;
      case _$TwitterUserSchema.keyScreenName:
        screenName = reader.readString();
        break;
      case _$TwitterUserSchema.keyLocation:
        location = reader.readString();
        break;
      case _$TwitterUserSchema.keyDescription:
        description = reader.readString();
        break;
      case _$TwitterUserSchema.keyUrl:
        if (reader.isNextNull()) {
          reader.readNull();
          url = null;
        } else {
          url = reader.readString();
        }
        break;
      case _$TwitterUserSchema.keyEntities:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          entities = _$TwitterUserEntitiesFromReader(reader);
        }
        break;
      case _$TwitterUserSchema.keyProtected:
        protected = reader.readBool();
        break;
      case _$TwitterUserSchema.keyFollowersCount:
        followersCount = reader.readInt();
        break;
      case _$TwitterUserSchema.keyFriendsCount:
        friendsCount = reader.readInt();
        break;
      case _$TwitterUserSchema.keyListedCount:
        listedCount = reader.readInt();
        break;
      case _$TwitterUserSchema.keyCreatedAt:
        createdAt = reader.readString();
        break;
      case _$TwitterUserSchema.keyFavouritesCount:
        favouritesCount = reader.readInt();
        break;
      case _$TwitterUserSchema.keyUtcOffset:
        if (reader.isNextNull()) {
          reader.readNull();
          utcOffset = null;
        } else {
          utcOffset = reader.readInt();
        }
        break;
      case _$TwitterUserSchema.keyTimeZone:
        if (reader.isNextNull()) {
          reader.readNull();
          timeZone = null;
        } else {
          timeZone = reader.readString();
        }
        break;
      case _$TwitterUserSchema.keyGeoEnabled:
        geoEnabled = reader.readBool();
        break;
      case _$TwitterUserSchema.keyVerified:
        verified = reader.readBool();
        break;
      case _$TwitterUserSchema.keyStatusesCount:
        statusesCount = reader.readInt();
        break;
      case _$TwitterUserSchema.keyLang:
        lang = reader.readString();
        break;
      case _$TwitterUserSchema.keyContributorsEnabled:
        contributorsEnabled = reader.readBool();
        break;
      case _$TwitterUserSchema.keyIsTranslator:
        isTranslator = reader.readBool();
        break;
      case _$TwitterUserSchema.keyIsTranslationEnabled:
        isTranslationEnabled = reader.readBool();
        break;
      case _$TwitterUserSchema.keyProfileBackgroundColor:
        profileBackgroundColor = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileBackgroundImageUrl:
        profileBackgroundImageUrl = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileBackgroundImageUrlHttps:
        profileBackgroundImageUrlHttps = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileBackgroundTile:
        profileBackgroundTile = reader.readBool();
        break;
      case _$TwitterUserSchema.keyProfileImageUrl:
        profileImageUrl = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileImageUrlHttps:
        profileImageUrlHttps = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileBannerUrl:
        if (reader.isNextNull()) {
          reader.readNull();
          profileBannerUrl = null;
        } else {
          profileBannerUrl = reader.readString();
        }
        break;
      case _$TwitterUserSchema.keyProfileLinkColor:
        profileLinkColor = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileSidebarBorderColor:
        profileSidebarBorderColor = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileSidebarFillColor:
        profileSidebarFillColor = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileTextColor:
        profileTextColor = reader.readString();
        break;
      case _$TwitterUserSchema.keyProfileUseBackgroundImage:
        profileUseBackgroundImage = reader.readBool();
        break;
      case _$TwitterUserSchema.keyDefaultProfile:
        defaultProfile = reader.readBool();
        break;
      case _$TwitterUserSchema.keyDefaultProfileImage:
        defaultProfileImage = reader.readBool();
        break;
      case _$TwitterUserSchema.keyFollowing:
        following = reader.readBool();
        break;
      case _$TwitterUserSchema.keyFollowRequestSent:
        followRequestSent = reader.readBool();
        break;
      case _$TwitterUserSchema.keyNotifications:
        notifications = reader.readBool();
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();

  return TwitterUser(
    id: id ?? 0,
    idStr: idStr ?? '',
    name: name ?? '',
    screenName: screenName ?? '',
    location: location,
    description: description,
    url: url,
    entities: entities,
    protected: protected,
    followersCount: followersCount,
    friendsCount: friendsCount,
    listedCount: listedCount,
    createdAt: createdAt ?? '',
    favouritesCount: favouritesCount,
    utcOffset: utcOffset,
    timeZone: timeZone,
    geoEnabled: geoEnabled,
    verified: verified,
    statusesCount: statusesCount,
    lang: lang,
    contributorsEnabled: contributorsEnabled,
    isTranslator: isTranslator,
    isTranslationEnabled: isTranslationEnabled,
    profileBackgroundColor: profileBackgroundColor,
    profileBackgroundImageUrl: profileBackgroundImageUrl,
    profileBackgroundImageUrlHttps: profileBackgroundImageUrlHttps,
    profileBackgroundTile: profileBackgroundTile,
    profileImageUrl: profileImageUrl,
    profileImageUrlHttps: profileImageUrlHttps,
    profileBannerUrl: profileBannerUrl,
    profileLinkColor: profileLinkColor,
    profileSidebarBorderColor: profileSidebarBorderColor,
    profileSidebarFillColor: profileSidebarFillColor,
    profileTextColor: profileTextColor,
    profileUseBackgroundImage: profileUseBackgroundImage,
    defaultProfile: defaultProfile,
    defaultProfileImage: defaultProfileImage,
    following: following,
    followRequestSent: followRequestSent,
    notifications: notifications,
  );
}

void _$TwitterUserToWriter(TwitterUser instance, JsonTokenWriter writer) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterUserSchema.nameIdBytes);
  writer.writeInt(instance.id);
  writer.writeNameBytes(_$TwitterUserSchema.nameIdStrBytes);
  writer.writeString(instance.idStr);
  writer.writeNameBytes(_$TwitterUserSchema.nameNameBytes);
  writer.writeString(instance.name);
  writer.writeNameBytes(_$TwitterUserSchema.nameScreenNameBytes);
  writer.writeString(instance.screenName);
  writer.writeNameBytes(_$TwitterUserSchema.nameLocationBytes);
  writer.writeString(instance.location);
  writer.writeNameBytes(_$TwitterUserSchema.nameDescriptionBytes);
  writer.writeString(instance.description);
  if (instance.url != null) {
    writer.writeNameBytes(_$TwitterUserSchema.nameUrlBytes);
    writer.writeString(instance.url!);
  }
  if (instance.entities != null) {
    writer.writeNameBytes(_$TwitterUserSchema.nameEntitiesBytes);
    _$TwitterUserEntitiesToWriter(instance.entities!, writer);
  }
  writer.writeNameBytes(_$TwitterUserSchema.nameProtectedBytes);
  writer.writeBool(instance.protected);
  writer.writeNameBytes(_$TwitterUserSchema.nameFollowersCountBytes);
  writer.writeInt(instance.followersCount);
  writer.writeNameBytes(_$TwitterUserSchema.nameFriendsCountBytes);
  writer.writeInt(instance.friendsCount);
  writer.writeNameBytes(_$TwitterUserSchema.nameListedCountBytes);
  writer.writeInt(instance.listedCount);
  writer.writeNameBytes(_$TwitterUserSchema.nameCreatedAtBytes);
  writer.writeString(instance.createdAt);
  writer.writeNameBytes(_$TwitterUserSchema.nameFavouritesCountBytes);
  writer.writeInt(instance.favouritesCount);
  if (instance.utcOffset != null) {
    writer.writeNameBytes(_$TwitterUserSchema.nameUtcOffsetBytes);
    writer.writeInt(instance.utcOffset!);
  }
  if (instance.timeZone != null) {
    writer.writeNameBytes(_$TwitterUserSchema.nameTimeZoneBytes);
    writer.writeString(instance.timeZone!);
  }
  writer.writeNameBytes(_$TwitterUserSchema.nameGeoEnabledBytes);
  writer.writeBool(instance.geoEnabled);
  writer.writeNameBytes(_$TwitterUserSchema.nameVerifiedBytes);
  writer.writeBool(instance.verified);
  writer.writeNameBytes(_$TwitterUserSchema.nameStatusesCountBytes);
  writer.writeInt(instance.statusesCount);
  writer.writeNameBytes(_$TwitterUserSchema.nameLangBytes);
  writer.writeString(instance.lang);
  writer.writeNameBytes(_$TwitterUserSchema.nameContributorsEnabledBytes);
  writer.writeBool(instance.contributorsEnabled);
  writer.writeNameBytes(_$TwitterUserSchema.nameIsTranslatorBytes);
  writer.writeBool(instance.isTranslator);
  writer.writeNameBytes(_$TwitterUserSchema.nameIsTranslationEnabledBytes);
  writer.writeBool(instance.isTranslationEnabled);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileBackgroundColorBytes);
  writer.writeString(instance.profileBackgroundColor);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileBackgroundImageUrlBytes);
  writer.writeString(instance.profileBackgroundImageUrl);
  writer.writeNameBytes(
    _$TwitterUserSchema.nameProfileBackgroundImageUrlHttpsBytes,
  );
  writer.writeString(instance.profileBackgroundImageUrlHttps);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileBackgroundTileBytes);
  writer.writeBool(instance.profileBackgroundTile);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileImageUrlBytes);
  writer.writeString(instance.profileImageUrl);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileImageUrlHttpsBytes);
  writer.writeString(instance.profileImageUrlHttps);
  if (instance.profileBannerUrl != null) {
    writer.writeNameBytes(_$TwitterUserSchema.nameProfileBannerUrlBytes);
    writer.writeString(instance.profileBannerUrl!);
  }
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileLinkColorBytes);
  writer.writeString(instance.profileLinkColor);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileSidebarBorderColorBytes);
  writer.writeString(instance.profileSidebarBorderColor);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileSidebarFillColorBytes);
  writer.writeString(instance.profileSidebarFillColor);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileTextColorBytes);
  writer.writeString(instance.profileTextColor);
  writer.writeNameBytes(_$TwitterUserSchema.nameProfileUseBackgroundImageBytes);
  writer.writeBool(instance.profileUseBackgroundImage);
  writer.writeNameBytes(_$TwitterUserSchema.nameDefaultProfileBytes);
  writer.writeBool(instance.defaultProfile);
  writer.writeNameBytes(_$TwitterUserSchema.nameDefaultProfileImageBytes);
  writer.writeBool(instance.defaultProfileImage);
  writer.writeNameBytes(_$TwitterUserSchema.nameFollowingBytes);
  writer.writeBool(instance.following);
  writer.writeNameBytes(_$TwitterUserSchema.nameFollowRequestSentBytes);
  writer.writeBool(instance.followRequestSent);
  writer.writeNameBytes(_$TwitterUserSchema.nameNotificationsBytes);
  writer.writeBool(instance.notifications);
  writer.endObject();
}

// =============================================================================
// 8. TwitterStatus
// =============================================================================
extension type const _$TwitterStatusSchema(int _value) {
  static const String nameMetadata = 'metadata';
  static const String nameCreatedAt = 'created_at';
  static const String nameId = 'id';
  static const String nameIdStr = 'id_str';
  static const String nameText = 'text';
  static const String nameSource = 'source';
  static const String nameTruncated = 'truncated';
  static const String nameInReplyToStatusId = 'in_reply_to_status_id';
  static const String nameInReplyToStatusIdStr = 'in_reply_to_status_id_str';
  static const String nameInReplyToUserId = 'in_reply_to_user_id';
  static const String nameInReplyToUserIdStr = 'in_reply_to_user_id_str';
  static const String nameInReplyToScreenName = 'in_reply_to_screen_name';
  static const String nameUser = 'user';
  static const String nameRetweetCount = 'retweet_count';
  static const String nameFavoriteCount = 'favorite_count';
  static const String nameEntities = 'entities';
  static const String nameFavorited = 'favorited';
  static const String nameRetweeted = 'retweeted';
  static const String namePossiblySensitive = 'possibly_sensitive';
  static const String nameLang = 'lang';
  static const String nameRetweetedStatus = 'retweeted_status';

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
  static final Uint8List nameCreatedAtBytes = Uint8List.fromList(const [
    99,
    114,
    101,
    97,
    116,
    101,
    100,
    95,
    97,
    116,
  ]);
  static final Uint8List nameIdBytes = Uint8List.fromList(const [105, 100]);
  static final Uint8List nameIdStrBytes = Uint8List.fromList(const [
    105,
    100,
    95,
    115,
    116,
    114,
  ]);
  static final Uint8List nameTextBytes = Uint8List.fromList(const [
    116,
    101,
    120,
    116,
  ]);
  static final Uint8List nameSourceBytes = Uint8List.fromList(const [
    115,
    111,
    117,
    114,
    99,
    101,
  ]);
  static final Uint8List nameTruncatedBytes = Uint8List.fromList(const [
    116,
    114,
    117,
    110,
    99,
    97,
    116,
    101,
    100,
  ]);
  static final Uint8List nameInReplyToStatusIdBytes = Uint8List.fromList(const [
    105,
    110,
    95,
    114,
    101,
    112,
    108,
    121,
    95,
    116,
    111,
    95,
    115,
    116,
    97,
    116,
    117,
    115,
    95,
    105,
    100,
  ]);
  static final Uint8List nameInReplyToStatusIdStrBytes =
      Uint8List.fromList(const [
        105,
        110,
        95,
        114,
        101,
        112,
        108,
        121,
        95,
        116,
        111,
        95,
        115,
        116,
        97,
        116,
        117,
        115,
        95,
        105,
        100,
        95,
        115,
        116,
        114,
      ]);
  static final Uint8List nameInReplyToUserIdBytes = Uint8List.fromList(const [
    105,
    110,
    95,
    114,
    101,
    112,
    108,
    121,
    95,
    116,
    111,
    95,
    117,
    115,
    101,
    114,
    95,
    105,
    100,
  ]);
  static final Uint8List nameInReplyToUserIdStrBytes =
      Uint8List.fromList(const [
        105,
        110,
        95,
        114,
        101,
        112,
        108,
        121,
        95,
        116,
        111,
        95,
        117,
        115,
        101,
        114,
        95,
        105,
        100,
        95,
        115,
        116,
        114,
      ]);
  static final Uint8List nameInReplyToScreenNameBytes =
      Uint8List.fromList(const [
        105,
        110,
        95,
        114,
        101,
        112,
        108,
        121,
        95,
        116,
        111,
        95,
        115,
        99,
        114,
        101,
        101,
        110,
        95,
        110,
        97,
        109,
        101,
      ]);
  static final Uint8List nameUserBytes = Uint8List.fromList(const [
    117,
    115,
    101,
    114,
  ]);
  static final Uint8List nameRetweetCountBytes = Uint8List.fromList(const [
    114,
    101,
    116,
    119,
    101,
    101,
    116,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameFavoriteCountBytes = Uint8List.fromList(const [
    102,
    97,
    118,
    111,
    114,
    105,
    116,
    101,
    95,
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameEntitiesBytes = Uint8List.fromList(const [
    101,
    110,
    116,
    105,
    116,
    105,
    101,
    115,
  ]);
  static final Uint8List nameFavoritedBytes = Uint8List.fromList(const [
    102,
    97,
    118,
    111,
    114,
    105,
    116,
    101,
    100,
  ]);
  static final Uint8List nameRetweetedBytes = Uint8List.fromList(const [
    114,
    101,
    116,
    119,
    101,
    101,
    116,
    101,
    100,
  ]);
  static final Uint8List namePossiblySensitiveBytes = Uint8List.fromList(const [
    112,
    111,
    115,
    115,
    105,
    98,
    108,
    121,
    95,
    115,
    101,
    110,
    115,
    105,
    116,
    105,
    118,
    101,
  ]);
  static final Uint8List nameLangBytes = Uint8List.fromList(const [
    108,
    97,
    110,
    103,
  ]);
  static final Uint8List nameRetweetedStatusBytes = Uint8List.fromList(const [
    114,
    101,
    116,
    119,
    101,
    101,
    116,
    101,
    100,
    95,
    115,
    116,
    97,
    116,
    117,
    115,
  ]);

  static const int keyMetadata = 0;
  static const int keyCreatedAt = 1;
  static const int keyId = 2;
  static const int keyIdStr = 3;
  static const int keyText = 4;
  static const int keySource = 5;
  static const int keyTruncated = 6;
  static const int keyInReplyToStatusId = 7;
  static const int keyInReplyToStatusIdStr = 8;
  static const int keyInReplyToUserId = 9;
  static const int keyInReplyToUserIdStr = 10;
  static const int keyInReplyToScreenName = 11;
  static const int keyUser = 12;
  static const int keyRetweetCount = 13;
  static const int keyFavoriteCount = 14;
  static const int keyEntities = 15;
  static const int keyFavorited = 16;
  static const int keyRetweeted = 17;
  static const int keyPossiblySensitive = 18;
  static const int keyLang = 19;
  static const int keyRetweetedStatus = 20;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameMetadata,
    nameCreatedAt,
    nameId,
    nameIdStr,
    nameText,
    nameSource,
    nameTruncated,
    nameInReplyToStatusId,
    nameInReplyToStatusIdStr,
    nameInReplyToUserId,
    nameInReplyToUserIdStr,
    nameInReplyToScreenName,
    nameUser,
    nameRetweetCount,
    nameFavoriteCount,
    nameEntities,
    nameFavorited,
    nameRetweeted,
    namePossiblySensitive,
    nameLang,
    nameRetweetedStatus,
  ]);

  static const _$TwitterStatusSchema none = _$TwitterStatusSchema(0);
}

TwitterStatus _$TwitterStatusFromReader(JsonTokenReader reader) {
  reader.beginObject();

  TwitterMetadata? metadata;
  String? createdAt;
  int? id;
  String? idStr;
  String? text;
  String? source;
  bool truncated = false;
  int? inReplyToStatusId;
  String? inReplyToStatusIdStr;
  int? inReplyToUserId;
  String? inReplyToUserIdStr;
  String? inReplyToScreenName;
  TwitterUser? user;
  int retweetCount = 0;
  int favoriteCount = 0;
  TwitterEntities? entities;
  bool favorited = false;
  bool retweeted = false;
  bool? possiblySensitive;
  String lang = 'en';
  TwitterStatus? retweetedStatus;

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterStatusSchema.options)) {
      case _$TwitterStatusSchema.keyMetadata:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          metadata = _$TwitterMetadataFromReader(reader);
        }
        break;
      case _$TwitterStatusSchema.keyCreatedAt:
        createdAt = reader.readString();
        break;
      case _$TwitterStatusSchema.keyId:
        id = reader.readInt();
        break;
      case _$TwitterStatusSchema.keyIdStr:
        idStr = reader.readString();
        break;
      case _$TwitterStatusSchema.keyText:
        text = reader.readString();
        break;
      case _$TwitterStatusSchema.keySource:
        source = reader.readString();
        break;
      case _$TwitterStatusSchema.keyTruncated:
        truncated = reader.readBool();
        break;
      case _$TwitterStatusSchema.keyInReplyToStatusId:
        if (reader.isNextNull()) {
          reader.readNull();
          inReplyToStatusId = null;
        } else {
          inReplyToStatusId = reader.readInt();
        }
        break;
      case _$TwitterStatusSchema.keyInReplyToStatusIdStr:
        if (reader.isNextNull()) {
          reader.readNull();
          inReplyToStatusIdStr = null;
        } else {
          inReplyToStatusIdStr = reader.readString();
        }
        break;
      case _$TwitterStatusSchema.keyInReplyToUserId:
        if (reader.isNextNull()) {
          reader.readNull();
          inReplyToUserId = null;
        } else {
          inReplyToUserId = reader.readInt();
        }
        break;
      case _$TwitterStatusSchema.keyInReplyToUserIdStr:
        if (reader.isNextNull()) {
          reader.readNull();
          inReplyToUserIdStr = null;
        } else {
          inReplyToUserIdStr = reader.readString();
        }
        break;
      case _$TwitterStatusSchema.keyInReplyToScreenName:
        if (reader.isNextNull()) {
          reader.readNull();
          inReplyToScreenName = null;
        } else {
          inReplyToScreenName = reader.readString();
        }
        break;
      case _$TwitterStatusSchema.keyUser:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          user = _$TwitterUserFromReader(reader);
        }
        break;
      case _$TwitterStatusSchema.keyRetweetCount:
        retweetCount = reader.readInt();
        break;
      case _$TwitterStatusSchema.keyFavoriteCount:
        favoriteCount = reader.readInt();
        break;
      case _$TwitterStatusSchema.keyEntities:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          entities = _$TwitterEntitiesFromReader(reader);
        }
        break;
      case _$TwitterStatusSchema.keyFavorited:
        favorited = reader.readBool();
        break;
      case _$TwitterStatusSchema.keyRetweeted:
        retweeted = reader.readBool();
        break;
      case _$TwitterStatusSchema.keyPossiblySensitive:
        if (reader.isNextNull()) {
          reader.readNull();
          possiblySensitive = null;
        } else {
          possiblySensitive = reader.readBool();
        }
        break;
      case _$TwitterStatusSchema.keyLang:
        lang = reader.readString();
        break;
      case _$TwitterStatusSchema.keyRetweetedStatus:
        if (reader.isNextNull()) {
          reader.readNull();
        } else {
          retweetedStatus = _$TwitterStatusFromReader(reader);
        }
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();

  return TwitterStatus(
    metadata: metadata,
    createdAt: createdAt ?? '',
    id: id ?? 0,
    idStr: idStr ?? '',
    text: text ?? '',
    source: source ?? '',
    truncated: truncated,
    inReplyToStatusId: inReplyToStatusId,
    inReplyToStatusIdStr: inReplyToStatusIdStr,
    inReplyToUserId: inReplyToUserId,
    inReplyToUserIdStr: inReplyToUserIdStr,
    inReplyToScreenName: inReplyToScreenName,
    user: user,
    retweetCount: retweetCount,
    favoriteCount: favoriteCount,
    entities: entities,
    favorited: favorited,
    retweeted: retweeted,
    possiblySensitive: possiblySensitive,
    lang: lang,
    retweetedStatus: retweetedStatus,
  );
}

void _$TwitterStatusToWriter(TwitterStatus instance, JsonTokenWriter writer) {
  writer.beginObject();
  if (instance.metadata != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameMetadataBytes);
    _$TwitterMetadataToWriter(instance.metadata!, writer);
  }
  writer.writeNameBytes(_$TwitterStatusSchema.nameCreatedAtBytes);
  writer.writeString(instance.createdAt);
  writer.writeNameBytes(_$TwitterStatusSchema.nameIdBytes);
  writer.writeInt(instance.id);
  writer.writeNameBytes(_$TwitterStatusSchema.nameIdStrBytes);
  writer.writeString(instance.idStr);
  writer.writeNameBytes(_$TwitterStatusSchema.nameTextBytes);
  writer.writeString(instance.text);
  writer.writeNameBytes(_$TwitterStatusSchema.nameSourceBytes);
  writer.writeString(instance.source);
  writer.writeNameBytes(_$TwitterStatusSchema.nameTruncatedBytes);
  writer.writeBool(instance.truncated);
  if (instance.inReplyToStatusId != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameInReplyToStatusIdBytes);
    writer.writeInt(instance.inReplyToStatusId!);
  }
  if (instance.inReplyToStatusIdStr != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameInReplyToStatusIdStrBytes);
    writer.writeString(instance.inReplyToStatusIdStr!);
  }
  if (instance.inReplyToUserId != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameInReplyToUserIdBytes);
    writer.writeInt(instance.inReplyToUserId!);
  }
  if (instance.inReplyToUserIdStr != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameInReplyToUserIdStrBytes);
    writer.writeString(instance.inReplyToUserIdStr!);
  }
  if (instance.inReplyToScreenName != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameInReplyToScreenNameBytes);
    writer.writeString(instance.inReplyToScreenName!);
  }
  if (instance.user != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameUserBytes);
    _$TwitterUserToWriter(instance.user!, writer);
  }
  writer.writeNameBytes(_$TwitterStatusSchema.nameRetweetCountBytes);
  writer.writeInt(instance.retweetCount);
  writer.writeNameBytes(_$TwitterStatusSchema.nameFavoriteCountBytes);
  writer.writeInt(instance.favoriteCount);
  if (instance.entities != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameEntitiesBytes);
    _$TwitterEntitiesToWriter(instance.entities!, writer);
  }
  writer.writeNameBytes(_$TwitterStatusSchema.nameFavoritedBytes);
  writer.writeBool(instance.favorited);
  writer.writeNameBytes(_$TwitterStatusSchema.nameRetweetedBytes);
  writer.writeBool(instance.retweeted);
  if (instance.possiblySensitive != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.namePossiblySensitiveBytes);
    writer.writeBool(instance.possiblySensitive!);
  }
  writer.writeNameBytes(_$TwitterStatusSchema.nameLangBytes);
  writer.writeString(instance.lang);
  if (instance.retweetedStatus != null) {
    writer.writeNameBytes(_$TwitterStatusSchema.nameRetweetedStatusBytes);
    _$TwitterStatusToWriter(instance.retweetedStatus!, writer);
  }
  writer.endObject();
}

// =============================================================================
// 9. TwitterSearchMetadata
// =============================================================================
extension type const _$TwitterSearchMetadataSchema(int _value) {
  static const String nameCompletedIn = 'completed_in';
  static const String nameMaxId = 'max_id';
  static const String nameMaxIdStr = 'max_id_str';
  static const String nameNextResults = 'next_results';
  static const String nameQuery = 'query';
  static const String nameRefreshUrl = 'refresh_url';
  static const String nameCount = 'count';
  static const String nameSinceId = 'since_id';
  static const String nameSinceIdStr = 'since_id_str';

  static final Uint8List nameCompletedInBytes = Uint8List.fromList(const [
    99,
    111,
    109,
    112,
    108,
    101,
    116,
    101,
    100,
    95,
    105,
    110,
  ]);
  static final Uint8List nameMaxIdBytes = Uint8List.fromList(const [
    109,
    97,
    120,
    95,
    105,
    100,
  ]);
  static final Uint8List nameMaxIdStrBytes = Uint8List.fromList(const [
    109,
    97,
    120,
    95,
    105,
    100,
    95,
    115,
    116,
    114,
  ]);
  static final Uint8List nameNextResultsBytes = Uint8List.fromList(const [
    110,
    101,
    120,
    116,
    95,
    114,
    101,
    115,
    117,
    108,
    116,
    115,
  ]);
  static final Uint8List nameQueryBytes = Uint8List.fromList(const [
    113,
    117,
    101,
    114,
    121,
  ]);
  static final Uint8List nameRefreshUrlBytes = Uint8List.fromList(const [
    114,
    101,
    102,
    114,
    101,
    115,
    104,
    95,
    117,
    114,
    108,
  ]);
  static final Uint8List nameCountBytes = Uint8List.fromList(const [
    99,
    111,
    117,
    110,
    116,
  ]);
  static final Uint8List nameSinceIdBytes = Uint8List.fromList(const [
    115,
    105,
    110,
    99,
    101,
    95,
    105,
    100,
  ]);
  static final Uint8List nameSinceIdStrBytes = Uint8List.fromList(const [
    115,
    105,
    110,
    99,
    101,
    95,
    105,
    100,
    95,
    115,
    116,
    114,
  ]);

  static const int keyCompletedIn = 0;
  static const int keyMaxId = 1;
  static const int keyMaxIdStr = 2;
  static const int keyNextResults = 3;
  static const int keyQuery = 4;
  static const int keyRefreshUrl = 5;
  static const int keyCount = 6;
  static const int keySinceId = 7;
  static const int keySinceIdStr = 8;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameCompletedIn,
    nameMaxId,
    nameMaxIdStr,
    nameNextResults,
    nameQuery,
    nameRefreshUrl,
    nameCount,
    nameSinceId,
    nameSinceIdStr,
  ]);

  static const _$TwitterSearchMetadataSchema none =
      _$TwitterSearchMetadataSchema(0);
}

TwitterSearchMetadata _$TwitterSearchMetadataFromReader(
  JsonTokenReader reader,
) {
  reader.beginObject();

  double? completedIn;
  int? maxId;
  String? maxIdStr;
  String nextResults = '';
  String? query;
  String refreshUrl = '';
  int count = 0;
  int sinceId = 0;
  String sinceIdStr = '0';

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterSearchMetadataSchema.options)) {
      case _$TwitterSearchMetadataSchema.keyCompletedIn:
        completedIn = reader.readDouble();
        break;
      case _$TwitterSearchMetadataSchema.keyMaxId:
        maxId = reader.readInt();
        break;
      case _$TwitterSearchMetadataSchema.keyMaxIdStr:
        maxIdStr = reader.readString();
        break;
      case _$TwitterSearchMetadataSchema.keyNextResults:
        nextResults = reader.readString();
        break;
      case _$TwitterSearchMetadataSchema.keyQuery:
        query = reader.readString();
        break;
      case _$TwitterSearchMetadataSchema.keyRefreshUrl:
        refreshUrl = reader.readString();
        break;
      case _$TwitterSearchMetadataSchema.keyCount:
        count = reader.readInt();
        break;
      case _$TwitterSearchMetadataSchema.keySinceId:
        sinceId = reader.readInt();
        break;
      case _$TwitterSearchMetadataSchema.keySinceIdStr:
        sinceIdStr = reader.readString();
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();

  return TwitterSearchMetadata(
    completedIn: completedIn ?? 0.0,
    maxId: maxId ?? 0,
    maxIdStr: maxIdStr ?? '',
    nextResults: nextResults,
    query: query ?? '',
    refreshUrl: refreshUrl,
    count: count,
    sinceId: sinceId,
    sinceIdStr: sinceIdStr,
  );
}

void _$TwitterSearchMetadataToWriter(
  TwitterSearchMetadata instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameCompletedInBytes);
  writer.writeDouble(instance.completedIn);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameMaxIdBytes);
  writer.writeInt(instance.maxId);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameMaxIdStrBytes);
  writer.writeString(instance.maxIdStr);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameNextResultsBytes);
  writer.writeString(instance.nextResults);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameQueryBytes);
  writer.writeString(instance.query);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameRefreshUrlBytes);
  writer.writeString(instance.refreshUrl);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameCountBytes);
  writer.writeInt(instance.count);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameSinceIdBytes);
  writer.writeInt(instance.sinceId);
  writer.writeNameBytes(_$TwitterSearchMetadataSchema.nameSinceIdStrBytes);
  writer.writeString(instance.sinceIdStr);
  writer.endObject();
}

// =============================================================================
// 10. TwitterResponse
// =============================================================================
extension type const _$TwitterResponseSchema(int _value) {
  static const String nameStatuses = 'statuses';
  static const String nameSearchMetadata = 'search_metadata';

  static final Uint8List nameStatusesBytes = Uint8List.fromList(const [
    115,
    116,
    97,
    116,
    117,
    115,
    101,
    115,
  ]);
  static final Uint8List nameSearchMetadataBytes = Uint8List.fromList(const [
    115,
    101,
    97,
    114,
    99,
    104,
    95,
    109,
    101,
    116,
    97,
    100,
    97,
    116,
    97,
  ]);

  static const int keyStatuses = 0;
  static const int keySearchMetadata = 1;

  static final JsonKeyOptions options = JsonKeyOptions.of(const [
    nameStatuses,
    nameSearchMetadata,
  ]);
  static const _$TwitterResponseSchema none = _$TwitterResponseSchema(0);
}

TwitterResponse _$TwitterResponseFromReader(JsonTokenReader reader) {
  reader.beginObject();

  List<TwitterStatus> statuses = const [];
  TwitterSearchMetadata? searchMetadata;

  while (reader.hasNext()) {
    switch (reader.selectName(_$TwitterResponseSchema.options)) {
      case _$TwitterResponseSchema.keyStatuses:
        reader.beginArray();
        final list = <TwitterStatus>[];
        while (reader.hasNext()) {
          list.add(_$TwitterStatusFromReader(reader));
        }
        reader.endArray();
        statuses = list;
        break;
      case _$TwitterResponseSchema.keySearchMetadata:
        searchMetadata = _$TwitterSearchMetadataFromReader(reader);
        break;
      default:
        reader.skipValue();
        break;
    }
  }
  reader.endObject();

  return TwitterResponse(
    statuses: statuses,
    searchMetadata:
        searchMetadata ??
        const TwitterSearchMetadata(
          completedIn: 0.0,
          maxId: 0,
          maxIdStr: '',
          query: '',
          count: 0,
        ),
  );
}

void _$TwitterResponseToWriter(
  TwitterResponse instance,
  JsonTokenWriter writer,
) {
  writer.beginObject();
  writer.writeNameBytes(_$TwitterResponseSchema.nameStatusesBytes);
  writer.beginArray();
  for (final s in instance.statuses) {
    _$TwitterStatusToWriter(s, writer);
  }
  writer.endArray();
  writer.writeNameBytes(_$TwitterResponseSchema.nameSearchMetadataBytes);
  _$TwitterSearchMetadataToWriter(instance.searchMetadata, writer);
  writer.endObject();
}
