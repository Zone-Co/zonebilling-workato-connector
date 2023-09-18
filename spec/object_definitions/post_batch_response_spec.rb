# frozen_string_literal: true

RSpec.describe 'object_definition/post_batch_response', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.post_batch_response }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:reference_id_field) { schema_fields[0] }

    it 'returns 1 field' do
      expect(schema_fields.length).to eq(1)
    end

    it 'contains Reference ID field' do
      expect(reference_id_field['name']).to eq('reference_id')
      expect(reference_id_field['label']).to eq('Reference ID')
      expect(reference_id_field['type']).to eq(:integer)
    end

  end
end
