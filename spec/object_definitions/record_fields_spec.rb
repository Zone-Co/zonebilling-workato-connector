# frozen_string_literal: true

RSpec.describe 'object_definition/record_fields', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.record_fields }

  describe 'fields' do

    context 'with no options' do
      subject(:schema_fields_no_input) { object_definition.fields(settings, {}) }
      subject(:field_group_field) { schema_fields_no_input[0] }
      subject(:field_group_properties) { field_group_field['properties'] }

      it 'contains empty field group' do
        expect(field_group_field['name']).to eq('record_fields')
        expect(field_group_field['label']).to eq('Fields')
        expect(field_group_field['type']).to eq(:object)
        expect(field_group_field['properties']).to be_kind_of(Array)
        expect(field_group_properties.length).to be(0)
      end
    end

    context 'with record type indicated' do

      subject(:schema_fields_with_input) { object_definition.fields(settings, {
        :record_type => 'customer'
      }) }
      subject(:field_group_field) { schema_fields_with_input[0] }
      subject(:sublists_group_field) { schema_fields_with_input[1] }

      it 'has fields' do
        expect(schema_fields_with_input).to_not be_empty
      end

      it 'contains field group' do
        expect(field_group_field['name']).to eq('record_fields')
        expect(field_group_field['label']).to eq('Fields')
        expect(field_group_field['type']).to eq(:object)
      end

      it 'contains sublist fields' do
        expect(sublists_group_field['name']).to eq('sublist_fields')
        expect(sublists_group_field['label']).to eq('Sublists')
        expect(sublists_group_field['type']).to eq(:object)
        expect(sublists_group_field['properties']).to be_kind_of(Array)
      end
    end
  end
end
