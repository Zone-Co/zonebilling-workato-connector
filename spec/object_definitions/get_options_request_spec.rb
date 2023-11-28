# frozen_string_literal: true

RSpec.describe 'object_definition/get_options_request', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.get_options_request }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:return_all_field) { schema_fields[0] }
    subject(:page_size_field) { schema_fields[1] }
    subject(:page_number_field) { schema_fields[2] }

    it 'returns 3 fields' do
      expect(schema_fields.length).to eq(3)
    end

    it 'contains Return All field' do
      expect(return_all_field['name']).to eq('return_all')
      expect(return_all_field['label']).to eq('Return All')
      expect(return_all_field['type']).to eq('boolean')
      expect(return_all_field['control_type']).to eq('checkbox')
      expect(return_all_field['sticky']).to be_truthy
      expect(return_all_field['optional']).to be_truthy
    end

    it 'contains Page Size field' do
      expect(page_size_field['name']).to eq('page_size')
      expect(page_size_field['label']).to eq('Page Size')
      expect(page_size_field['type']).to eq(:integer)
      expect(page_size_field['control_type']).to eq(:integer)
      expect(page_size_field['sticky']).to be_truthy
      expect(page_size_field['optional']).to be_truthy
    end

    it 'contains Page Number field' do
      expect(page_number_field['name']).to eq('page_number')
      expect(page_number_field['label']).to eq('Page Number')
      expect(page_number_field['ngIf']).to eq('input.options.return_all == "false"')
      expect(page_number_field['type']).to eq(:integer)
      expect(page_number_field['control_type']).to eq(:integer)
      expect(page_number_field['sticky']).to be_truthy
      expect(page_number_field['optional']).to be_truthy
    end
  end
end
