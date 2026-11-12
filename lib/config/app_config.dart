/// Fill these in after you create the Supabase project and deploy the API,
/// or pass them at build/run time with --dart-define, e.g.:
///   flutter run --dart-define=API_BASE_URL=https://portfolio-api-l4on.onrender.com
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT_REF.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://portfolio-api-l4on.onrender.com',
  );

  static const storageBucket = 'portfolio-images';

  static const publicSiteBaseUrl = String.fromEnvironment(
    'PUBLIC_SITE_BASE_URL',
    defaultValue: 'https://oussamamethnani.vercel.app',
  );
}
