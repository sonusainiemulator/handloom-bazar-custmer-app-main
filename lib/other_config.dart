class OtherConfig {
  static const bool USE_PUSH_NOTIFICATION = true;
  static const bool USE_GOOGLE_MAP = true;
  static const String GOOGLE_MAP_API_KEY = "";

  // Google Places (Reviews)
  // NOTE: For security, prefer loading from secure storage or env in production.
  static const String GOOGLE_PLACES_API_KEY =
      "AIzaSyAzB4o0mgGns8hzYt_OVQlsz5SqzCZN21k";
  // Provide your Google Place ID for your shop to fetch reviews
  static const String GOOGLE_PLACE_ID =
      "ChIJixzrr7utJToRd7wKLXf0Axk"; // leave empty to resolve via text query
  // Optional: if Place ID is unknown, set this text query and we will resolve
  static const String GOOGLE_PLACE_TEXT_QUERY =
      "Priya Fashion, bhalununda Main Road, nearby Laxmi Mandir, Jogender Meher, Bhalumunda, Badamula, Odisha 767040";
  // Default country code for phone numbers (used when user omits +CC)
  static const String defaultPhoneCountryCode = "+91";
}
