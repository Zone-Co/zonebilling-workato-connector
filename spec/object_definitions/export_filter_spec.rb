# frozen_string_literal: true

RSpec.describe 'object_definition/export_filter', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.export_filter }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:field_id_field) { schema_fields[0] }
    subject(:operator_field) { schema_fields[1] }
    subject(:value_field) { schema_fields[2] }
    subject(:type_field) { schema_fields[3] }

    it 'returns 4 fields' do
      expect(schema_fields.length).to eq(4)
    end

    it 'contains Field ID field' do
      expect(field_id_field['name']).to eq('field_id')
      expect(field_id_field['label']).to eq('Field ID')
      expect(field_id_field['type']).to eq(:string)
      expect(field_id_field['pick_list']).to eq('record_fields')
      expect(field_id_field['sticky']).to be_truthy
      expect(field_id_field['optional']).to be_falsey
      expect(field_id_field['toggle_field']).to be_kind_of(Object)
    end

    it 'contains Operator field' do
      expect(operator_field['name']).to eq('operator')
      expect(operator_field['label']).to eq('Operator')
      expect(operator_field['type']).to eq(:string)
      expect(operator_field['pick_list']).to eq('operators')
      expect(operator_field['sticky']).to be_truthy
      expect(operator_field['optional']).to be_falsey
    end

    it 'contains Value field' do
      expect(value_field['name']).to eq('value')
      expect(value_field['label']).to eq('Value')
      expect(value_field['type']).to eq(:string)
      expect(value_field['sticky']).to be_truthy
      expect(value_field['optional']).to be_falsey
    end

    it 'contains Type field' do
      expect(type_field['name']).to eq('type')
      expect(type_field['label']).to eq('Type')
      expect(type_field['type']).to eq(:string)
      expect(type_field['pick_list']).to eq('filter_types')
      expect(type_field['sticky']).to be_truthy
      expect(type_field['optional']).to be_falsey
    end
  end
end
