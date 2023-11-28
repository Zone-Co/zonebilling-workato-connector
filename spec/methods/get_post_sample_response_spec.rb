# frozen_string_literal: true

RSpec.describe 'methods/get_post_sample_response', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }


  context 'when response has no options' do

    subject(:result) { connector.methods.get_post_sample_response(connector.connection, {}) }

    it 'returns response body' do
      expect(result).to be_kind_of(::Hash)
    end

    it 'returns response internalid' do
      expect(result['internalid']).to be_kind_of(Integer)
    end
  end

  context 'when response has options' do

    options = {
      'automations' => '1,2',
      'export_id' => 'zab_customer'
    }

    subject(:result) { connector.methods.get_post_sample_response(connector.connection, {
      'options' => options
    }) }

    it 'returns body' do
      expect(result).to be_kind_of(::Hash)
    end

    it 'returns internalid' do
      expect(result['internalid']).to be_kind_of(Integer)
    end

    it 'returns reference_id' do
      expect(result['reference_id']).to be_kind_of(Integer)
    end

    it 'returns results' do
      expect(result['results']).to be_kind_of(Array)
    end
  end
end
