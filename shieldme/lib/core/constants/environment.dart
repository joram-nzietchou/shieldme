enum Flavor { development, staging, production }

class Environment {
  static Flavor currentFlavor = Flavor.development;
  
  static String get baseUrl {
    switch (currentFlavor) {
      case Flavor.development:
        return 'http://localhost:3000/api';
      case Flavor.staging:
        return 'https://staging-api.shieldme.com/api';
      case Flavor.production:
        return 'https://api.shieldme.com/api';
    }
  }
  
  static bool get isDevelopment => currentFlavor == Flavor.development;
  static bool get isStaging => currentFlavor == Flavor.staging;
  static bool get isProduction => currentFlavor == Flavor.production;
  
  static String get appName {
    switch (currentFlavor) {
      case Flavor.development:
        return 'ShieldMe DEV';
      case Flavor.staging:
        return 'ShieldMe STAGING';
      case Flavor.production:
        return 'ShieldMe';
    }
  }
}