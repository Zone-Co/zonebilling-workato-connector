# frozen_string_literal: true

RSpec.describe 'object_definition/post_response', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.post_response }

  describe 'fields' do

    context 'with no options' do

      subject(:schema_fields_no_options) { object_definition.fields(settings, {}) }

      it 'has no fields with no options' do
        expect(schema_fields_no_options).to be_empty
      end
    end

    context 'on create/update/upsert' do

      subject(:schema_fields_with_record_type) { object_definition.fields(settings, {
        :record_type => 'customer'
      }) }
      subject(:internal_id_field) { schema_fields_with_record_type[0] }

      it 'has fields' do
        expect(schema_fields_with_record_type).to_not be_empty
      end

      it 'contains Internal ID field' do
        expect(internal_id_field['name']).to eq('internalid')
        expect(internal_id_field['label']).to eq('Internal ID')
        expect(internal_id_field['type']).to eq(:integer)
      end
    end

    context 'with Automations option' do

      subject(:schema_fields_with_automations) { object_definition.fields(settings, {
        :options => {
          :automations => '1,2,3'
        }
      }) }
      subject(:reference_id_field) { schema_fields_with_automations[0] }

      it 'contains Reference ID field' do
        expect(reference_id_field['name']).to eq('reference_id')
        expect(reference_id_field['label']).to eq('Reference ID')
        expect(reference_id_field['type']).to eq(:integer)
      end
    end

    context 'with export ID option' do

      subject(:schema_fields_with_automations) { object_definition.fields(settings, {
        :options => {
          :export_id => 'zab_customer'
        }
      }) }
      subject(:results_field) { schema_fields_with_automations[0] }

      it 'contains Results field' do
        expect(results_field['name']).to eq('results')
        expect(results_field['label']).to eq('Results')
        expect(results_field['type']).to eq(:array)
      end
    end

    context 'with all options selected' do
      subject(:schema_fields_with_all) { object_definition.fields(settings, {
        :record_type => 'customer',
        :options => {
          :automations => '1,2,3',
          :export_id => 'zab_customer'
        }
      }) }
      subject(:internal_id_field) { schema_fields_with_all[0] }
      subject(:reference_id_field) { schema_fields_with_all[1] }
      subject(:results_field) { schema_fields_with_all[2] }

      it 'contains Internal ID field' do
        expect(internal_id_field['name']).to eq('internalid')
        expect(internal_id_field['label']).to eq('Internal ID')
        expect(internal_id_field['type']).to eq(:integer)
      end

      it 'contains Reference ID field' do
        expect(reference_id_field['name']).to eq('reference_id')
        expect(reference_id_field['label']).to eq('Reference ID')
        expect(reference_id_field['type']).to eq(:integer)
      end

      it 'contains Results field' do
        expect(results_field['name']).to eq('results')
        expect(results_field['label']).to eq('Results')
        expect(results_field['type']).to eq(:array)
      end
    end
  end
end
