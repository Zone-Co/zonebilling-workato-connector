# frozen_string_literal: true

RSpec.describe 'object_definition/external_reference', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.external_reference }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:field_id_field) { schema_fields[0] }
    subject(:related_field_id_field) { schema_fields[1] }
    subject(:toggle_field) { related_field_id_field['toggle_field'] }

    it 'returns 2 fields' do
      expect(schema_fields.length).to eq(2)
    end

    it 'contains Field ID field' do
      expect(field_id_field['name']).to eq('field_id')
      expect(field_id_field['label']).to eq('Field ID')
      expect(field_id_field['type']).to eq(:string)
      expect(field_id_field['optional']).to be_falsey
      expect(field_id_field['sticky']).to be_truthy
      expect(field_id_field['pick_list']).to eq('record_fields')
      expect(field_id_field['pick_list_params']).to be_kind_of(Object)
      expect(field_id_field['toggle_field']).to be_kind_of(Object)
      expect(field_id_field['toggle_hint']).to eq('Select')
    end

    it 'contains Related Field ID field' do
      expect(related_field_id_field['name']).to eq('related_field_id')
      expect(related_field_id_field['label']).to eq('Related Field ID')
      expect(related_field_id_field['control_type']).to eq('tree')
      expect(related_field_id_field['optional']).to be_falsey
      expect(related_field_id_field['sticky']).to be_truthy
      expect(related_field_id_field['pick_list']).to eq('record_field_tree')
      expect(related_field_id_field['toggle_field']).to be_kind_of(Object)
      expect(related_field_id_field['toggle_hint']).to eq('Select')
    end

    it 'contains Related Field ID field with toggle' do
      expect(toggle_field['name']).to eq('related_field_id')
      expect(toggle_field['label']).to eq('Related Field ID')
      expect(toggle_field['toggle_hint']).to eq('ID')
      expect(toggle_field['type']).to eq(:string)
      expect(toggle_field['control_type']).to eq(:text)
      expect(toggle_field['change_on_blur']).to be_truthy
      expect(toggle_field['extends_schema']).to be_truthy
    end
  end
end
