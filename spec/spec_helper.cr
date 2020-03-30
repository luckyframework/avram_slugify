require "spec"
require "../src/avram_slugify"
require "./support/*"

Avram::Migrator::Runner.new.ensure_migrated!
Avram::SchemaEnforcer.ensure_correct_column_mappings!
Habitat.raise_if_missing_settings!
