# frozen_string_literal: true

RSpec.describe 'object_definition/get_options_response', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.get_options_response }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:include_empty_properties_field) { schema_fields[0] }
    subject(:text_always_field) { schema_fields[1] }
    subject(:label_as_key_field) { schema_fields[2] }

    it 'returns 3 fields' do
      expect(schema_fields.length).to eq(3)
    end

    it 'contains Include Empty Properties field' do
      expect(include_empty_properties_field['name']).to eq('include_empty_properties')
      expect(include_empty_properties_field['label']).to eq('Include Empty Properties')
      expect(include_empty_properties_field['type']).to eq('boolean')
      expect(include_empty_properties_field['control_type']).to eq('checkbox')
      expect(include_empty_properties_field['sticky']).to be_truthy
      expect(include_empty_properties_field['optional']).to be_truthy
    end

    it 'contains Text Always field' do
      expect(text_always_field['name']).to eq('text_always')
      expect(text_always_field['label']).to eq('Include Text Always')
      expect(text_always_field['type']).to eq('boolean')
      expect(text_always_field['control_type']).to eq('checkbox')
      expect(text_always_field['sticky']).to be_truthy
      expect(text_always_field['optional']).to be_truthy
    end

    it 'contains Label As Key field' do
      expect(label_as_key_field['name']).to eq('label_as_key')
      expect(label_as_key_field['label']).to eq('Use NetSuite Column Label as Result Key')
      expect(label_as_key_field['type']).to eq('boolean')
      expect(label_as_key_field['control_type']).to eq('checkbox')
      expect(label_as_key_field['sticky']).to be_truthy
      expect(label_as_key_field['optional']).to be_truthy
    end

  end
end
