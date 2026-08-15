package main

// =============================================================================
// 1. small.json
// =============================================================================

type SmallLocation struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	City      string  `json:"city"`
	Country   string  `json:"country"`
}

type SmallMetadata struct {
	LoginCount int64         `json:"loginCount"`
	LastLogin  string        `json:"lastLogin"`
	Location   SmallLocation `json:"location"`
}

type SmallDocument struct {
	ID       int64         `json:"id"`
	UUID     string        `json:"uuid"`
	Name     string        `json:"name"`
	Email    string        `json:"email"`
	IsActive bool          `json:"isActive"`
	Balance  float64       `json:"balance"`
	Age      int64         `json:"age"`
	Roles    []string      `json:"roles"`
	Metadata SmallMetadata `json:"metadata"`
	Tags     []string      `json:"tags"`
}

// =============================================================================
// 2. twitter.json
// =============================================================================

type TwitterMetadata struct {
	ResultType      string `json:"result_type"`
	IsoLanguageCode string `json:"iso_language_code"`
}

type TwitterUserMention struct {
	ScreenName string  `json:"screen_name"`
	Name       string  `json:"name"`
	ID         int64   `json:"id"`
	IDStr      string  `json:"id_str"`
	Indices    []int64 `json:"indices"`
}

type TwitterUrl struct {
	Url         string  `json:"url"`
	ExpandedUrl string  `json:"expanded_url"`
	DisplayUrl  string  `json:"display_url"`
	Indices     []int64 `json:"indices"`
}

type TwitterEntitiesUrls struct {
	Urls []TwitterUrl `json:"urls"`
}

type TwitterUserEntities struct {
	Url         *TwitterEntitiesUrls `json:"url"`
	Description *TwitterEntitiesUrls `json:"description"`
}

type TwitterEntities struct {
	Urls         []TwitterUrl         `json:"urls"`
	UserMentions []TwitterUserMention `json:"user_mentions"`
}

type TwitterUser struct {
	ID                             int64                `json:"id"`
	IDStr                          string               `json:"id_str"`
	Name                           string               `json:"name"`
	ScreenName                     string               `json:"screen_name"`
	Location                       string               `json:"location"`
	Description                    string               `json:"description"`
	Url                            *string              `json:"url"`
	Entities                       *TwitterUserEntities `json:"entities"`
	Protected                      bool                 `json:"protected"`
	FollowersCount                 int64                `json:"followers_count"`
	FriendsCount                   int64                `json:"friends_count"`
	ListedCount                    int64                `json:"listed_count"`
	CreatedAt                      string               `json:"created_at"`
	FavouritesCount                int64                `json:"favourites_count"`
	UtcOffset                      *int64               `json:"utc_offset"`
	TimeZone                       *string              `json:"time_zone"`
	GeoEnabled                     bool                 `json:"geo_enabled"`
	Verified                       bool                 `json:"verified"`
	StatusesCount                  int64                `json:"statuses_count"`
	Lang                           string               `json:"lang"`
	ContributorsEnabled            bool                 `json:"contributors_enabled"`
	IsTranslator                   bool                 `json:"is_translator"`
	IsTranslationEnabled           bool                 `json:"is_translation_enabled"`
	ProfileBackgroundColor         string               `json:"profile_background_color"`
	ProfileBackgroundImageUrl      string               `json:"profile_background_image_url"`
	ProfileBackgroundImageUrlHttps string               `json:"profile_background_image_url_https"`
	ProfileBackgroundTile          bool                 `json:"profile_background_tile"`
	ProfileImageUrl                string               `json:"profile_image_url"`
	ProfileImageUrlHttps           string               `json:"profile_image_url_https"`
	ProfileBannerUrl               *string              `json:"profile_banner_url"`
	ProfileLinkColor               string               `json:"profile_link_color"`
	ProfileSidebarBorderColor      string               `json:"profile_sidebar_border_color"`
	ProfileSidebarFillColor        string               `json:"profile_sidebar_fill_color"`
	ProfileTextColor               string               `json:"profile_text_color"`
	ProfileUseBackgroundImage      bool                 `json:"profile_use_background_image"`
	DefaultProfile                 bool                 `json:"default_profile"`
	DefaultProfileImage            bool                 `json:"default_profile_image"`
	Following                      bool                 `json:"following"`
	FollowRequestSent              bool                 `json:"follow_request_sent"`
	Notifications                  bool                 `json:"notifications"`
}

type TwitterStatus struct {
	Metadata             *TwitterMetadata `json:"metadata"`
	CreatedAt            string           `json:"created_at"`
	ID                   int64            `json:"id"`
	IDStr                string           `json:"id_str"`
	Text                 string           `json:"text"`
	Source               string           `json:"source"`
	Truncated            bool             `json:"truncated"`
	InReplyToStatusID    *int64           `json:"in_reply_to_status_id"`
	InReplyToStatusIDStr *string          `json:"in_reply_to_status_id_str"`
	InReplyToUserID      *int64           `json:"in_reply_to_user_id"`
	InReplyToUserIDStr   *string          `json:"in_reply_to_user_id_str"`
	InReplyToScreenName  *string          `json:"in_reply_to_screen_name"`
	User                 *TwitterUser     `json:"user"`
	RetweetCount         int64            `json:"retweet_count"`
	FavoriteCount        int64            `json:"favorite_count"`
	Entities             *TwitterEntities `json:"entities"`
	Favorited            bool             `json:"favorited"`
	Retweeted            bool             `json:"retweeted"`
	PossiblySensitive    *bool            `json:"possibly_sensitive"`
	Lang                 string           `json:"lang"`
	RetweetedStatus      *TwitterStatus   `json:"retweeted_status"`
}

type TwitterSearchMetadata struct {
	CompletedIn float64 `json:"completed_in"`
	MaxID       int64   `json:"max_id"`
	MaxIDStr    string  `json:"max_id_str"`
	NextResults string  `json:"next_results"`
	Query       string  `json:"query"`
	RefreshUrl  string  `json:"refresh_url"`
	Count       int64   `json:"count"`
	SinceID     int64   `json:"since_id"`
	SinceIDStr  string  `json:"since_id_str"`
}

type TwitterResponse struct {
	Statuses       []TwitterStatus       `json:"statuses"`
	SearchMetadata TwitterSearchMetadata `json:"search_metadata"`
}

// =============================================================================
// 3. citm_catalog.json
// =============================================================================

type CitmArea struct {
	AreaID   int64   `json:"areaId"`
	BlockIDs []int64 `json:"blockIds"`
}

type CitmSeatCategory struct {
	Areas          []CitmArea `json:"areas"`
	SeatCategoryID int64      `json:"seatCategoryId"`
}

type CitmPrice struct {
	Amount                int64 `json:"amount"`
	AudienceSubCategoryID int64 `json:"audienceSubCategoryId"`
	SeatCategoryID        int64 `json:"seatCategoryId"`
}

type CitmPerformance struct {
	EventID        int64              `json:"eventId"`
	ID             int64              `json:"id"`
	Logo           *string            `json:"logo"`
	Name           *string            `json:"name"`
	Prices         []CitmPrice        `json:"prices"`
	SeatCategories []CitmSeatCategory `json:"seatCategories"`
	Start          int64              `json:"start"`
	VenueCode      string             `json:"venueCode"`
}

type CitmEvent struct {
	Description *string `json:"description"`
	ID          int64   `json:"id"`
	Logo        *string `json:"logo"`
	Name        string  `json:"name"`
	SubTopicIDs []int64 `json:"subTopicIds"`
	SubjectCode *int64  `json:"subjectCode"`
	Subtitle    *string `json:"subtitle"`
	TopicIDs    []int64 `json:"topicIds"`
}

type CitmCatalog struct {
	AreaNames                map[string]string    `json:"areaNames"`
	AudienceSubCategoryNames map[string]string    `json:"audienceSubCategoryNames"`
	BlockNames               map[string]string    `json:"blockNames"`
	Events                   map[string]CitmEvent `json:"events"`
	Performances             []CitmPerformance   `json:"performances"`
	SeatCategoryNames        map[string]string    `json:"seatCategoryNames"`
	SubTopicNames            map[string]string    `json:"subTopicNames"`
	SubjectNames             map[string]string    `json:"subjectNames"`
	TopicNames               map[string]string    `json:"topicNames"`
	TopicSynced              map[string]bool      `json:"topicSynced"`
	VenueNames               map[string]string    `json:"venueNames"`
}

// =============================================================================
// 4. canada.json
// =============================================================================

type CanadaProperties struct {
	Name string `json:"name"`
}

type CanadaGeometry struct {
	Type        string          `json:"type"`
	Coordinates [][][]float64   `json:"coordinates"`
}

type CanadaFeature struct {
	Type       string           `json:"type"`
	Properties CanadaProperties `json:"properties"`
	Geometry   CanadaGeometry   `json:"geometry"`
}

type CanadaFeatureCollection struct {
	Type     string          `json:"type"`
	Features []CanadaFeature `json:"features"`
}
