# frozen_string_literal: true

RSpec.describe 'actions/get_record_file', :vcr do

  subject(:output) { connector.actions.get_record_file(input) }

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.get_record_file }

  describe 'execute' do
    subject(:output) { action.execute(settings, {
      "record_type" => "invoice",
      "record_id" => "21647",
      "options" => {
        "file_export_type" => "recordpdf",
        "file_compression_type" => "zip"
      }
    }) }

    it ('returns a file') do
      expect(output).to be_kind_of(Object)
      expect(output['file']).to have_key(:name)
      expect(output['file']).to have_key(:description)
      expect(output['file']).to have_key(:contents)
    end
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, {}) }

    it 'returns 3 values' do
      expect(sample_output).to be_kind_of(Object)
      expect(sample_output).to have_key(:name)
      expect(sample_output).to have_key(:description)
      expect(sample_output).to have_key(:contents)
      expect(sample_output['name']).to eq('INV000001.PDF')
      expect(sample_output['description']).to eq('... File Description ... ')
      expect(sample_output['contents']).to eq('... File Contents ...')
    end
  end

  describe 'input_fields' do
    subject(:input_fields) { action.input_fields(settings, {
      "record_type" => "invoice",
      "record_id" => "21647",
    }) }

    it 'contains options field group' do
      options_group = input_fields[0]
      expect(input_fields[0]).to be_kind_of(Object)
      expect(input_fields[0]['name']).to eq('options')
    end

    it 'contains file_export_type field' do
      expect(input_fields[0]['properties'][0]['name']).to eq('file_export_type')
    end

    it 'contains file_compression_type field' do
      expect(input_fields[0]['properties'][1]['name']).to eq('file_compression_type')
    end

    it 'contains template_id field' do
      expect(input_fields[0]['properties'][2]['name']).to eq('template_id')
    end
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields(settings, {}) }
    subject(:name_field) { output_fields[0] }
    subject(:description_field) { output_fields[1] }
    subject(:contents_field) { output_fields[2] }

    it 'returns 3 fields' do
      expect(output_fields.length).to eq(3)
    end

    it 'contains Name field' do
      expect(name_field['name']).to eq('name')
      expect(name_field['label']).to eq('File Name')
      expect(name_field['type']).to eq(:string)
    end

    it 'contains Description field' do
      expect(description_field['name']).to eq('description')
      expect(description_field['label']).to eq('Description')
      expect(description_field['type']).to eq(:string)
    end

    it 'contains Contents field' do
      expect(contents_field['name']).to eq('contents')
      expect(contents_field['label']).to eq('File')
      expect(contents_field['type']).to eq(:string)
    end
  end
end
