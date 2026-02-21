const runConfigDevelopmentTemplate = r'''
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="development" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="buildFlavor" value="development" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_development.dart" />
    <method v="2" />
  </configuration>
</component>
''';

const runConfigStagingTemplate = r'''
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="staging" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="buildFlavor" value="staging" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_staging.dart" />
    <method v="2" />
  </configuration>
</component>
''';

const runConfigProductionTemplate = r'''
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="production" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="buildFlavor" value="production" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_production.dart" />
    <method v="2" />
  </configuration>
</component>
''';
