# frozen_string_literal: true

RSpec.describe 'actions/get_records', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { {
    'export_id' => 'zab_customer'
  } }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.get_records }

  context 'execute' do
    subject(:output) { action.execute(settings, input) }

    context 'Given Valid Input' do

      it 'response is successful' do
        expect(output).to be_kind_of(Object)
      end

      it 'response contains page properties' do
        expect(output['page']).to be >= 1
        expect(output['total_pages']).to be >= 1
        expect(output['results_returned']).to be >= 1
        expect(output['results_returned']).to be >= 1
      end
    end
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    it 'is object' do
      expect(sample_output).to be_kind_of(Object)
    end

    it 'response contains page properties' do
      expect(sample_output['page']).to be >= 1
      expect(sample_output['total_pages']).to be >= 1
      expect(sample_output['results_returned']).to be >= 1
      expect(sample_output['results_returned']).to be >= 1
    end
  end

  describe 'input_fields' do
    subject(:input_fields) { action.input_fields(settings, input) }

    it 'response contains export id' do
      expect(input_fields[0]['name']).to eq('options')
    end
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields(settings, input) }

    it 'is an array' do
      expect(output_fields).to be_kind_of(Array)
    end
  end
end
