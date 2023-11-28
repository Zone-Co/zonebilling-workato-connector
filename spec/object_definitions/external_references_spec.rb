# frozen_string_literal: true

RSpec.describe 'object_definition/external_references', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.external_references }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:external_references_field) { schema_fields[0] }

    it 'returns 1 field' do
      expect(schema_fields.length).to eq(1)
    end

    it 'contains External Reference field' do
      expect(external_references_field['name']).to eq('external_references')
      expect(external_references_field['label']).to eq('External References')
      expect(external_references_field['type']).to eq(:array)
      expect(external_references_field['of']).to eq(:object)
      expect(external_references_field['list_mode']).to eq('static')
      expect(external_references_field['item_label']).to eq('External Reference')
    end
  end
end
