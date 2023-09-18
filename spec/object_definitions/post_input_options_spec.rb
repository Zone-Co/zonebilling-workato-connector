# frozen_string_literal: true

RSpec.describe 'object_definition/post_input_options', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.post_input_options }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:options_field) { schema_fields[0] }

    it 'returns 1 field' do
      expect(schema_fields.length).to eq(1)
    end

    it 'contains Options field' do
      expect(options_field['name']).to eq('options')
      expect(options_field['label']).to eq('Options')
      expect(options_field['type']).to eq(:object)
      expect(options_field['properties']).to be_kind_of(Array)
    end
  end
end
