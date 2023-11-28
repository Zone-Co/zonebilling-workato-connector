# frozen_string_literal: true

RSpec.describe 'object_definition/file_export_options', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.file_export_options }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {:record_type => 'customer'}) }
    subject(:file_export_type_field) { schema_fields[0] }
    subject(:file_compression_type_field) { schema_fields[1] }
    subject(:template_id_field) { schema_fields[2] }
    subject(:schema_fields_with_transaction) { object_definition.fields(settings, {:record_type => 'invoice'}) }
    subject(:template_id_field_with_transaction) { schema_fields[2] }

    it 'returns 3 fields' do
      expect(schema_fields.length).to eq(3)
    end

    it 'contains File export type field' do
      expect(file_export_type_field['name']).to eq('file_export_type')
      expect(file_export_type_field['label']).to eq('Export Type')
      expect(file_export_type_field['default']).to eq('recordpdf')
      expect(file_export_type_field['sticky']).to be_truthy
      expect(file_export_type_field['optional']).to be_truthy
    end

    it 'contains File compression type field' do
      expect(file_compression_type_field['name']).to eq('file_compression_type')
      expect(file_compression_type_field['label']).to eq('File Compression Type')
      expect(file_compression_type_field['pick_list']).to eq('file_compression_type')
      expect(file_compression_type_field['sticky']).to be_truthy
      expect(file_compression_type_field['optional']).to be_truthy
    end

    it 'contains Template ID field' do
      expect(template_id_field['name']).to eq('template_id')
      expect(template_id_field['label']).to eq('Template ID')
      expect(template_id_field['type']).to eq(:integer)
      expect(template_id_field['sticky']).to be_truthy
      expect(template_id_field['optional']).to be_falsey
    end

    it 'contains Template ID field for Transaction Record type' do
      expect(template_id_field_with_transaction['name']).to eq('template_id')
      expect(template_id_field_with_transaction['label']).to eq('Template ID')
      expect(template_id_field_with_transaction['type']).to eq(:integer)
      expect(template_id_field_with_transaction['sticky']).to be_truthy
      expect(template_id_field_with_transaction['optional']).to be_falsey
    end
  end
end
