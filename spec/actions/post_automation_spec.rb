# frozen_string_literal: true

RSpec.describe 'actions/post_automation', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:action) { connector.actions.post_automation }

  subject(:input) {
    JSON.parse(File.read('fixtures/actions/post_automation/input.json'))
  }

  subject(:output) {output = action.execute(settings, input)}

  describe 'execute' do

    context 'Given Valid Input: response' do

      # Request Response
      it 'is an object' do
        expect(output).to be_kind_of(::Object)
      end

      # ZAB Automation Properties
      it 'contains a ZAB Automation reference id' do
        expect(output[:reference_id]).to be >= 1
      end
    end
  end
end
