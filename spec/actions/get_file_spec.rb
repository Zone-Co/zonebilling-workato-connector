# frozen_string_literal: true

RSpec.describe 'actions/get_file', :vcr do

  subject(:output) { connector.actions.get_file(input) }

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.get_file }

  describe 'execute' do
    subject(:output) { action.execute(settings, {
      "record_id" => "2228"
    }) }

    it ('returns a file') do
      expect(output).to be_kind_of(::Hash)
      expect(output['file']).to have_key(:name)
      expect(output['file']).to have_key(:description)
      expect(output['file']).to have_key(:contents)
    end
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, {}) }

    it 'returns 3 values' do
      expect(sample_output).to be_kind_of(::Hash)
      expect(sample_output).to have_key(:name)
      expect(sample_output).to have_key(:description)
      expect(sample_output).to have_key(:contents)
      expect(sample_output['name']).to eq('INV000001.PDF')
      expect(sample_output['description']).to eq('... File Description ... ')
      expect(sample_output['contents']).to eq('... File Contents ...')
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
