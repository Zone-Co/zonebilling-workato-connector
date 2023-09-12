# frozen_string_literal: true

RSpec.describe 'actions/update_record', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:action) { connector.actions.update_record }

  subject(:input) {
    input = JSON.parse(File.read('fixtures/actions/create_record/input.json'))
    # Change Company Name for Tests
    input['record_fields']['externalid'] = 'workato-testcustomer-123'
    input['options']['externalKey'] = 'externalid'

    input
  }

  subject(:output) {output = action.execute(settings, input)}

  # Custom Export Results
  let(:output_results) { output['results'] }
  let(:output_result) { output_results[0] }

  describe 'execute' do

    context 'Given Valid Input: response' do

      # Request Response
      it 'is an object' do
        expect(output).to be_kind_of(::Object)
      end

      it 'contains a truthy success property' do
        expect(output[:success]).to be_truthy
      end

      it 'contains a record id' do
        expect(output[:internalid]).to be >= 1
      end

      # ZAB Automation Properties
      it 'contains a ZAB Automation reference id' do
        expect(output[:reference_id]).to be >= 1
      end

      it 'contains a results property' do
        expect(output[:results]).to be_kind_of(::Array)
      end

      it 'results array length is 1' do
        expect(output[:results].length).to eq(1)
      end

      it 'result result is an object' do
        expect(output[:results][0]).to be_kind_of(::Object)
      end

      it 'result [internalid] matches' do
        result = output[:results][0]
        expect(result[:internalid][:value]).to eq(output[:internalid].to_s)
      end
    end
  end
end
