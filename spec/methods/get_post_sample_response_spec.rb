# frozen_string_literal: true

RSpec.describe 'methods/get_post_sample_response', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }


  context 'when response has no options' do

    subject(:result_without_options) { connector.methods.get_post_sample_response(connector.connection, {}) }

    it 'returns response body' do
      expect(result_without_options).to be_kind_of(Object)
    end

    it 'returns response internalid' do
      expect(result_without_options[:internalid]).to be_kind_of(Integer)
    end
  end

  context 'when response has options' do

    options = {
      automations: '1,2',
      export_id: 'zab_customer'
    }

    subject(:result_with_options) { connector.methods.get_post_sample_response(connector.connection, { options: options }) }

    it 'returns body' do
      expect(result_with_options).to be_kind_of(Object)
    end

    it 'returns internalid' do
      expect(result_with_options[:internalid]).to be_kind_of(Integer)
    end

    it 'returns reference_id' do
      expect(result_with_options[:reference_id]).to be_kind_of(Integer)
    end

    it 'returns results' do
      expect(result_with_options['results']).to be_kind_of(Array)
    end
  end
end
