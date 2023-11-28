# frozen_string_literal: true

RSpec.describe 'object_definition/export_id_option', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.export_id_option }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:export_id_field) { schema_fields[0] }

    it 'returns 1 field' do
      expect(schema_fields.length).to eq(1)
    end

    it 'contains Export ID field' do
      expect(export_id_field['name']).to eq('export_id')
      expect(export_id_field['label']).to eq('ZAB API Export')
      expect(export_id_field['control_type']).to eq(:select)
      expect(export_id_field['sticky']).to be_truthy
      expect(export_id_field['toggle_hint']).to eq('Select')
      expect(export_id_field['pick_list']).to eq('api_exports')
    end
  end
end
