# frozen_string_literal: true

RSpec.describe 'actions/post_automation', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:action) { connector.actions.post_automation }

  context 'valid request' do

    subject(:output) { action.execute(settings, {
      'automations' => '1,2'
    })}

    # Request Response
    it 'returns a reference id' do
      expect(output).to be_kind_of(::Hash)
      expect(output['reference_id']).to be >= 1
    end
  end
end
