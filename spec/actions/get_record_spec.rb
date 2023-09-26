# frozen_string_literal: true

RSpec.describe 'actions/get_record', :vcr do

  subject(:output) { connector.actions.get_record(input) }

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { {
    'export_id' => 'zab_customer',
    'internal_id' => 7086
  } }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.get_record }

  context 'execute' do
    subject(:output) { action.execute(settings, input) }

    context 'Given Valid Input' do

      it 'response is successful' do
        expect(output).to be_kind_of(::Hash)
      end

      it 'response data is valid' do
        expect(output['internalid']['value'].to_i).to eq(input['internal_id'])
      end
    end

  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    it 'response is successful' do
      expect(output).to be_kind_of(::Hash)
    end
  end

  describe 'input_fields' do
    subject(:input_fields) { action.input_fields(settings, input) }

    it 'response contains options' do
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
