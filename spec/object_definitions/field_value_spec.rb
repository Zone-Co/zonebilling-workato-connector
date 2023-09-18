# frozen_string_literal: true

RSpec.describe 'object_definition/field_value', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.field_value }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:value_field) { schema_fields[0] }
    subject(:text_field) { schema_fields[1] }

    it 'returns 2 fields' do
      expect(schema_fields.length).to eq(2)
    end

    it 'contains Value field' do
      expect(value_field['name']).to eq('value')
      expect(value_field['label']).to eq('Value')
      expect(value_field['type']).to eq('string')
    end

    it 'contains Text field' do
      expect(text_field['name']).to eq('text')
      expect(text_field['label']).to eq('Text')
      expect(text_field['type']).to eq('string')
      expect(text_field['optional']).to be_truthy
    end
  end
end
