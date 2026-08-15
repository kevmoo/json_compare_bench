use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// =============================================================================
// 1. small.json
// =============================================================================

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SmallLocation {
    pub latitude: f64,
    pub longitude: f64,
    pub city: String,
    pub country: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SmallMetadata {
    pub login_count: i64,
    pub last_login: String,
    pub location: SmallLocation,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct SmallDocument {
    pub id: i64,
    pub uuid: String,
    pub name: String,
    pub email: String,
    pub is_active: bool,
    pub balance: f64,
    pub age: i64,
    pub roles: Vec<String>,
    pub metadata: SmallMetadata,
    pub tags: Vec<String>,
}

// =============================================================================
// 2. twitter.json
// =============================================================================

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterMetadata {
    #[serde(default)]
    pub result_type: String,
    #[serde(default)]
    pub iso_language_code: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterUserMention {
    #[serde(default)]
    pub screen_name: String,
    #[serde(default)]
    pub name: String,
    #[serde(default)]
    pub id: i64,
    #[serde(default)]
    pub id_str: String,
    #[serde(default)]
    pub indices: Vec<i64>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterUrl {
    #[serde(default)]
    pub url: String,
    #[serde(default)]
    pub expanded_url: String,
    #[serde(default)]
    pub display_url: String,
    #[serde(default)]
    pub indices: Vec<i64>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterEntitiesUrls {
    #[serde(default)]
    pub urls: Vec<TwitterUrl>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterUserEntities {
    pub url: Option<TwitterEntitiesUrls>,
    pub description: Option<TwitterEntitiesUrls>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterEntities {
    #[serde(default)]
    pub urls: Vec<TwitterUrl>,
    #[serde(default)]
    pub user_mentions: Vec<TwitterUserMention>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterUser {
    pub id: i64,
    pub id_str: String,
    pub name: String,
    pub screen_name: String,
    #[serde(default)]
    pub location: String,
    #[serde(default)]
    pub description: String,
    pub url: Option<String>,
    pub entities: Option<TwitterUserEntities>,
    #[serde(default)]
    pub protected: bool,
    #[serde(default)]
    pub followers_count: i64,
    #[serde(default)]
    pub friends_count: i64,
    #[serde(default)]
    pub listed_count: i64,
    #[serde(default)]
    pub created_at: String,
    #[serde(default)]
    pub favourites_count: i64,
    pub utc_offset: Option<i64>,
    pub time_zone: Option<String>,
    #[serde(default)]
    pub geo_enabled: bool,
    #[serde(default)]
    pub verified: bool,
    #[serde(default)]
    pub statuses_count: i64,
    #[serde(default)]
    pub lang: String,
    #[serde(default)]
    pub contributors_enabled: bool,
    #[serde(default)]
    pub is_translator: bool,
    #[serde(default)]
    pub is_translation_enabled: bool,
    #[serde(default)]
    pub profile_background_color: String,
    #[serde(default)]
    pub profile_background_image_url: String,
    #[serde(default)]
    pub profile_background_image_url_https: String,
    #[serde(default)]
    pub profile_background_tile: bool,
    #[serde(default)]
    pub profile_image_url: String,
    #[serde(default)]
    pub profile_image_url_https: String,
    pub profile_banner_url: Option<String>,
    #[serde(default)]
    pub profile_link_color: String,
    #[serde(default)]
    pub profile_sidebar_border_color: String,
    #[serde(default)]
    pub profile_sidebar_fill_color: String,
    #[serde(default)]
    pub profile_text_color: String,
    #[serde(default)]
    pub profile_use_background_image: bool,
    #[serde(default)]
    pub default_profile: bool,
    #[serde(default)]
    pub default_profile_image: bool,
    #[serde(default)]
    pub following: bool,
    #[serde(default)]
    pub follow_request_sent: bool,
    #[serde(default)]
    pub notifications: bool,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterStatus {
    pub metadata: Option<TwitterMetadata>,
    #[serde(default)]
    pub created_at: String,
    pub id: i64,
    pub id_str: String,
    pub text: String,
    pub source: String,
    #[serde(default)]
    pub truncated: bool,
    pub in_reply_to_status_id: Option<i64>,
    pub in_reply_to_status_id_str: Option<String>,
    pub in_reply_to_user_id: Option<i64>,
    pub in_reply_to_user_id_str: Option<String>,
    pub in_reply_to_screen_name: Option<String>,
    pub user: Option<TwitterUser>,
    #[serde(default)]
    pub retweet_count: i64,
    #[serde(default)]
    pub favorite_count: i64,
    pub entities: Option<TwitterEntities>,
    #[serde(default)]
    pub favorited: bool,
    #[serde(default)]
    pub retweeted: bool,
    pub possibly_sensitive: Option<bool>,
    #[serde(default)]
    pub lang: String,
    pub retweeted_status: Option<Box<TwitterStatus>>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterSearchMetadata {
    pub completed_in: f64,
    pub max_id: i64,
    pub max_id_str: String,
    #[serde(default)]
    pub next_results: String,
    pub query: String,
    #[serde(default)]
    pub refresh_url: String,
    pub count: i64,
    #[serde(default)]
    pub since_id: i64,
    #[serde(default)]
    pub since_id_str: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct TwitterResponse {
    #[serde(default)]
    pub statuses: Vec<TwitterStatus>,
    pub search_metadata: TwitterSearchMetadata,
}

// =============================================================================
// 3. citm_catalog.json
// =============================================================================

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
#[serde(rename_all = "camelCase")]
pub struct CitmArea {
    pub area_id: i64,
    #[serde(default)]
    pub block_ids: Vec<i64>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
#[serde(rename_all = "camelCase")]
pub struct CitmSeatCategory {
    #[serde(default)]
    pub areas: Vec<CitmArea>,
    pub seat_category_id: i64,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
#[serde(rename_all = "camelCase")]
pub struct CitmPrice {
    pub amount: i64,
    pub audience_sub_category_id: i64,
    pub seat_category_id: i64,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
#[serde(rename_all = "camelCase")]
pub struct CitmPerformance {
    pub event_id: i64,
    pub id: i64,
    pub logo: Option<String>,
    pub name: Option<String>,
    #[serde(default)]
    pub prices: Vec<CitmPrice>,
    #[serde(default)]
    pub seat_categories: Vec<CitmSeatCategory>,
    pub start: i64,
    pub venue_code: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
#[serde(rename_all = "camelCase")]
pub struct CitmEvent {
    pub description: Option<String>,
    pub id: i64,
    pub logo: Option<String>,
    pub name: String,
    #[serde(default)]
    pub sub_topic_ids: Vec<i64>,
    pub subject_code: Option<i64>,
    pub subtitle: Option<String>,
    #[serde(default)]
    pub topic_ids: Vec<i64>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
#[serde(rename_all = "camelCase")]
pub struct CitmCatalog {
    #[serde(default)]
    pub area_names: HashMap<String, String>,
    #[serde(default)]
    pub audience_sub_category_names: HashMap<String, String>,
    #[serde(default)]
    pub block_names: HashMap<String, String>,
    #[serde(default)]
    pub events: HashMap<String, CitmEvent>,
    #[serde(default)]
    pub performances: Vec<CitmPerformance>,
    #[serde(default)]
    pub seat_category_names: HashMap<String, String>,
    #[serde(default)]
    pub sub_topic_names: HashMap<String, String>,
    #[serde(default)]
    pub subject_names: HashMap<String, String>,
    #[serde(default)]
    pub topic_names: HashMap<String, String>,
    #[serde(default)]
    pub topic_synced: HashMap<String, bool>,
    #[serde(default)]
    pub venue_names: HashMap<String, String>,
}

// =============================================================================
// 4. canada.json
// =============================================================================

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct CanadaProperties {
    pub name: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct CanadaGeometry {
    pub r#type: String,
    pub coordinates: Vec<Vec<Vec<f64>>>,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct CanadaFeature {
    pub r#type: String,
    pub properties: CanadaProperties,
    pub geometry: CanadaGeometry,
}

#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct CanadaFeatureCollection {
    pub r#type: String,
    pub features: Vec<CanadaFeature>,
}
