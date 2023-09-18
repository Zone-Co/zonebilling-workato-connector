# frozen_string_literal: true

RSpec.describe 'object_definition/get_file_response', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.get_file_response }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:name_field) { schema_fields[0] }
    subject(:description_field) { schema_fields[1] }
    subject(:contents_field) { schema_fields[2] }

    it 'returns 3 fields' do
      expect(schema_fields.length).to eq(3)
    end

    it 'contains Name field' do
      expect(name_field['name']).to eq('name')
      expect(name_field['label']).to eq('File Name')
      expect(name_field['type']).to eq(:string)
    end

    it 'contains Description field' do
      expect(description_field['name']).to eq('description')
      expect(description_field['label']).to eq('Description')
      expect(description_field['type']).to eq(:string)
    end

    it 'contains Contents field' do
      expect(contents_field['name']).to eq('contents')
      expect(contents_field['label']).to eq('File')
      expect(contents_field['type']).to eq(:string)
    end
  end
end
