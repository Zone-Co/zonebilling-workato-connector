# frozen_string_literal: true

RSpec.describe 'actions/get_record_file_attachments', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { {
    'record_type' => 'customer',
    'record_id' => 6783
  } }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.get_record_file_attachments }

  describe 'execute' do
    subject(:output) { action.execute(settings, input) }

    it 'returns a list of file attachments' do
      expect(output['files']).to be_kind_of(Array)
    end

    it 'returns a list of file attachments with the correct properties' do
      output['files'].each do |file_attachment|
        expect(file_attachment).to be_kind_of(Object)
        expect(file_attachment).to have_key('description')
        expect(file_attachment).to have_key('name')
        expect(file_attachment).to have_key('contents')
      end
    end
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    it 'contains a list of file attachments' do
      expect(sample_output['files']).to be_kind_of(Array)
      expect(sample_output['files'][0]).to be_kind_of(Object)
    end
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields(settings, {}) }
    subject(:files_field) { output_fields[0] }

    it 'is an array' do
      expect(output_fields).to be_kind_of(Array)
    end

    it 'contains a file field' do
      expect(files_field['name']).to eq('files')
      expect(files_field).to be_kind_of(Object)
    end
  end
end
