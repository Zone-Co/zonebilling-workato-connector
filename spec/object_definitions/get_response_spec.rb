# frozen_string_literal: true

RSpec.describe 'object_definition/get_response', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.get_response }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:page_field) { schema_fields[0] }
    subject(:total_pages_field) { schema_fields[1] }
    subject(:total_results_field) { schema_fields[2] }
    subject(:results_returned_field) { schema_fields[3] }

    it 'returns 4 fields' do
      expect(schema_fields.length).to eq(4)
    end

    it 'contains Page field' do
      expect(page_field['name']).to eq('page')
      expect(page_field['label']).to eq('Page')
      expect(page_field['type']).to eq('integer')
    end

    it 'contains Total Pages field' do
      expect(total_pages_field['name']).to eq('total_pages')
      expect(total_pages_field['label']).to eq('Total Pages')
      expect(total_pages_field['type']).to eq('integer')
    end

    it 'contains Total Results field' do
      expect(total_results_field['name']).to eq('total_results')
      expect(total_results_field['label']).to eq('Total Results')
      expect(total_results_field['type']).to eq('integer')
    end

    it 'contains Results Returned field' do
      expect(results_returned_field['name']).to eq('results_returned')
      expect(results_returned_field['label']).to eq('Results Returned')
      expect(results_returned_field['type']).to eq('integer')
    end

    subject(:schema_fields_with_export_id) { object_definition.fields(settings, {
      :export_id => 'zab_customer'
    }) }
    subject(:results_field) { schema_fields_with_export_id[4] }

    it 'returns 5 fields with an export_id' do
      expect(schema_fields_with_export_id.length).to eq(5)
    end

    it 'contains Page field' do
      expect(results_field['name']).to eq('results')
      expect(results_field['label']).to eq('Results')
      expect(results_field['type']).to eq(:array)
      expect(results_field['of']).to eq(:object)
      expect(results_field['properties']).to be_kind_of(Array)
    end
  end
end
