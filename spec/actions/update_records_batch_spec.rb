# frozen_string_literal: true

RSpec.describe 'actions/update_records_batch', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:action) { connector.actions.update_records_batch }

  subject(:input) {
    input = JSON.parse(File.read('fixtures/actions/create_record/input.json'))
    options = input['options']
    options['externalKey'] = 'externalid'
    options.delete('export_id')

    # Manipulate the record input selections
    record_fields = input['record_fields'].clone
    record_fields['externalid'] = 'workato-testcustomer-123'
    input.delete('record_fields')

    # Create Array for Tests
    input['records'] = 50.times.map {
      record_fields.clone
    }

    input
  }

  subject(:output) {output = action.execute(settings, input)}

  describe 'execute' do

    context 'Given Valid Input: response' do

      # Request Response
      it 'is an object' do
        expect(output).to be_kind_of(::Object)
      end

      it 'contains a truthy success property' do
        expect(output[:success]).to be_truthy
      end

      # ZAB Automation for ZAB Bulk API
      it 'contains a ZAB Bulk API Reference ID' do
        expect(output[:reference_id]).to be >= 1
      end
    end
  end
end
