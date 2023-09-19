# frozen_string_literal: true

RSpec.describe 'methods/get', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  context 'valid request' do

    subject(:result) { connector.methods.get(connector.connection, {
     'export_id' => 'zab_customer'
    }) }

    it 'response is successful' do
      expect(result).to be_kind_of(Object)
      expect(result['success']).to be_truthy
    end

    it 'response contains page properties' do
      expect(result[:page]).to be >= 1
      expect(result[:total_pages]).to be >= 1
      expect(result[:results_returned]).to be >= 1
      expect(result[:results_returned]).to be >= 1
    end

    it 'response results' do
      expect(result[:results]).to be_kind_of(Array)
      result[:results].each do |result_object|
        expect(result_object).to be_kind_of(Object)
      end
    end
  end

  context 'invalid request' do

    it 'error is thrown' do
      error_thrown = false
      begin
        subject(:result) { connector.methods.get(connector.connection, {
         'export_id' => ''
        }) }
      rescue
          error_thrown = true
      ensure
          expect(error_thrown).to be_truthy
      end
    end
  end
end
