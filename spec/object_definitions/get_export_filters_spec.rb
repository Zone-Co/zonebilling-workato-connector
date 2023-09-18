# frozen_string_literal: true

RSpec.describe 'object_definition/get_export_filters', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.get_export_filters }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:record_type_field) { schema_fields[0] }
    subject(:record_type_toggle_field) { record_type_field['toggle_field'] }
    subject(:filters_field) { schema_fields[1] }

    it 'returns 2 fields' do
      expect(schema_fields.length).to eq(2)
    end

    it 'contains Record Type field' do
      expect(record_type_field['name']).to eq('record_type')
      expect(record_type_field['label']).to eq('Record Type')
      expect(record_type_field['type']).to eq(:string)
      expect(record_type_field['control_type']).to eq(:select)
      expect(record_type_field['pick_list']).to eq('record_types')
      expect(record_type_field['toggle_hint']).to eq('Select')
      expect(record_type_field['toggle_field']).to be_kind_of(Object)
    end

    it 'contains Record Type toggle field' do
      expect(record_type_toggle_field['name']).to eq('record_type')
      expect(record_type_toggle_field['label']).to eq('Record Type')
      expect(record_type_toggle_field['type']).to eq(:string)
      expect(record_type_toggle_field['change_on_blur']).to be_truthy
      expect(record_type_toggle_field['extends_schema']).to be_truthy
      expect(record_type_toggle_field['toggle_hint']).to eq('ID')
    end

    it 'contains Filters field' do
      expect(filters_field['name']).to eq('filters')
      expect(filters_field['label']).to eq('Filters')
      expect(filters_field['ngIf']).to eq('input.dynamic_filters.record_type')
      expect(filters_field['type']).to eq(:array)
      expect(filters_field['item_label']).to eq('Filter')
      expect(filters_field['list_mode']).to eq('static')
      expect(filters_field['list_mode_toggle']).to be_falsey
    end
  end
end
