class FlavorsConfig {
  static late FlavorsConfig instance;

  final bool isTest;
  final bool enableTestingTools;

  FlavorsConfig({required this.isTest, required this.enableTestingTools}) {
    instance = this;
  }
}
