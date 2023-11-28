# frozen_string_literal: true

RSpec.describe 'actions/create_records_batch', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:action) { connector.actions.create_records_batch }

  subject(:input) {
    input = JSON.parse(File.read('fixtures/methods/post/input/upsert.json'))
  }
  context 'execute' do

    subject(:output) { action.execute(settings, {
      "record_type": input['record_type'],
      "options": input['options'],
      "records": [
        input['record_fields'],
        input['record_fields']
      ]
    })}

    # Request Response
    it 'response is valid' do
      expect(output).to be_kind_of(::Hash)
      expect(output['success']).to be_truthy
      expect(output['reference_id']).to be_kind_of(Integer)
    end
  end
end
