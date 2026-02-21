const runConfigDevelopmentTemplate = r'''
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="development" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor development" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_development.dart" />
    <method v="2" />
  </configuration>
</component>
''';

const runConfigStagingTemplate = r'''
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="staging" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor staging" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_staging.dart" />
    <method v="2" />
  </configuration>
</component>
''';

const runConfigProductionTemplate = r'''
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="production" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor production" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_production.dart" />
    <method v="2" />
  </configuration>
</component>
''';
