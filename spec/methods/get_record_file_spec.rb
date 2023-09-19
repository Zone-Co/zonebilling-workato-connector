# frozen_string_literal: true

RSpec.describe 'methods/get_record_file', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }



  context 'given only a specific record and record ID' do

    subject(:result_only) { connector.methods.get_record_file(connector.connection, {
      'record_type' => 'invoice',
      'record_id' => 33450
    }) }

    it 'should return a file formatted object' do
      expect(result_only['file']).to be_kind_of(Object)
      expect(result_only['file']).to have_key('name')
      expect(result_only['file']).to have_key('description')
      expect(result_only['file']).to have_key('contents')
      expect(result_only['success']).to be_truthy
    end
  end

  context 'given only a specific record, record ID and type' do

    subject(:result_with_type) { connector.methods.get_record_file(connector.connection, {
      'record_type' => 'invoice',
      'record_id' => 33450,
      'options' => {
        'file_export_type' => 'recordpdf',
      }
    }) }

    it 'should return a file formatted object' do
      expect(result_with_type['file']).to be_kind_of(Object)
      expect(result_with_type['file']).to have_key('name')
      expect(result_with_type['file']).to have_key('description')
      expect(result_with_type['file']).to have_key('contents')
      expect(result_with_type['file']['file_type']).to eq("PDF")
      expect(result_with_type['file']['name']).to include('.pdf')
      expect(result_with_type['success']).to be_truthy
    end
  end

  context 'given only a specific record, record ID, type, and compression' do

    subject(:result_with_type) { connector.methods.get_record_file(connector.connection, {
      'record_type' => 'invoice',
      'record_id' => 33450,
      'options' => {
        'file_export_type' => 'recordpdf',
        'file_compression_type' => 'zip'
      }
    }) }

    it 'should return a file formatted object' do
      expect(result_with_type['file']).to be_kind_of(Object)
      expect(result_with_type['file']).to have_key('name')
      expect(result_with_type['file']).to have_key('description')
      expect(result_with_type['file']).to have_key('contents')
      expect(result_with_type['file']['file_type']).to eq("ZIP")
      expect(result_with_type['file']['name']).to include('.ZIP')
      expect(result_with_type['file']['name']).to include('.pdf')
      expect(result_with_type['success']).to be_truthy
    end
  end
end
