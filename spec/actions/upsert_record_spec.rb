# frozen_string_literal: true

RSpec.describe 'actions/upsert_record', :vcr do

  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:output) { JSON.parse(File.read('fixtures/actions/create_record_input.json')) }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.upsert_record }

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

    context 'Given Valid Input' do

      # Request Response
      it 'response is an object' do
        expect(output).to be_kind_of(::Object)
      end

      it 'response contains a truthy success property' do
        expect(output[:success]).to be_truthy
      end

      it 'response contains a record id' do
        expect(output[:internalid]).to be >= 1
      end

      # ZAB Automation Properties
      it 'response contains a ZAB Automation reference id' do
        expect(output[:reference_id]).to be >= 1
      end

      it 'response contains a results property' do
        expect(output[:results]).to be_kind_of(::Array)
      end

      it 'response results array length is 1' do
        expect(output[:results].length).to eq(1)
      end
    end
  end
end
