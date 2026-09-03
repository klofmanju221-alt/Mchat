class AgoraConfig {
  // Agora App ID
  static const String appId =
      '67442996296a4c45a180b6ac3e6495ed';

  // TEST ONLY
  // Token GitHub Actions Secret ಮೂಲಕ build ಸಮಯದಲ್ಲಿ ಬರುತ್ತದೆ.
  static const String tempToken =
      String.fromEnvironment(
    'AGORA_TEMP_TOKEN',
    defaultValue: '',
  );

  // Temporary Token ಈಗ ಈ channelಗಾಗಿ generate ಮಾಡಲಾಗಿದೆ.
  static const String testChannel =
      'mchat_test';
}
