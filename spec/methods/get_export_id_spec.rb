# frozen_string_literal: true

RSpec.describe 'methods/get_export_id', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }


  context 'when export_id is provided' do

    request_params = {
      'options' => {
        'export_id' => 'zab_customer'
      }
    }
    subject(:result) { connector.methods.get_export_id(connector.connection, request_params) }

    it 'returns a success result' do
      expect(result).to be_a(Object)
      expect(result['success']).to be_truthy
    end

    it 'returns page properties' do
      expect(result['page']).to be >= 1
      expect(result['total_pages']).to be >= 1
      expect(result['total_results']).to be >= 1
      expect(result['results_returned']).to be >= 1
    end
    
    it 'returns results property' do
      expect(result['results']).to be_kind_of(Array)
      expect(result['results'].length).to eq(result['results_returned'])
    end

    it 'returns results that are objects' do

      result['results'].each do |result_object|
        expect(result_object).to be_kind_of(Object)
      end
    end
  end

  context 'when internal_id is provided' do

    request_params = {
      'internal_id' => 6783,
      'options' => {
        'export_id' => 'zab_customer'
      }
    }
    subject(:result_with_internalid) { connector.methods.get_export_id(connector.connection, request_params) }

    it 'returns a success result' do
      expect(result_with_internalid).to be_a(Object)
      expect(result_with_internalid['success']).to be_truthy
    end

    it 'returns page properties' do
      expect(result_with_internalid['page']).to be == 1
      expect(result_with_internalid['total_pages']).to be == 1
      expect(result_with_internalid['total_results']).to be == 1
      expect(result_with_internalid['results_returned']).to be == 1
    end

    it 'returns results property' do
      expect(result_with_internalid['results']).to be_kind_of(Array)
      expect(result_with_internalid['results'].length).to eq(result_with_internalid['results_returned'])
    end

    it 'returns correct result' do
      expect(result_with_internalid['results'][0]['internalid']['value']).to eq('6783')
    end
  end
end
