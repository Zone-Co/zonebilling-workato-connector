# frozen_string_literal: true

RSpec.describe 'methods/get_record_file_attachments', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.get_record_file_attachments(connector.connection, {
    'record_type' => 'customer',
    'record_id' => 6783
  }) }

  context 'record type and ID are provided' do

    it 'returns a list of file attachments' do
      expect(result['files']).to be_kind_of(Array)
    end

    it 'returns a list of file attachments with the correct properties' do
      result['files'].each do |file_attachment|
        expect(file_attachment).to be_kind_of(::Hash)
        expect(file_attachment).to have_key('description')
        expect(file_attachment).to have_key('name')
        expect(file_attachment).to have_key('contents')
      end
    end
  end
end
