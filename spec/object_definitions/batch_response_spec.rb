# frozen_string_literal: true

RSpec.describe 'object_definition/batch_response', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.batch_response }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:status_field) { schema_fields[0] }
    subject(:response_field) { schema_fields[1] }

    it 'returns 2 fields' do
      expect(schema_fields.length).to eq(2)
    end

    it 'contains Status field' do
      expect(status_field['name']).to eq('status')
      expect(status_field['label']).to eq('Status')
      expect(status_field['type']).to eq('object')
      expect(status_field['properties']).to be_kind_of(Array)
    end

    it 'contains Response field with toggle' do
      expect(response_field['name']).to eq('response')
      expect(response_field['label']).to eq('Response')
      expect(response_field['type']).to eq('object')
      expect(response_field['properties']).to be_kind_of(Array)
    end
  end
end
