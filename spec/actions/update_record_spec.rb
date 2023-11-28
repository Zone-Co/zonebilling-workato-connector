# frozen_string_literal: true

RSpec.describe 'actions/update_record', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:action) { connector.actions.update_record }

  subject(:input) {
    input = JSON.parse(File.read('fixtures/methods/post/input/update.json'))
  }
  subject(:output) { action.execute(settings, input) }

  context 'execute' do

    # Request Response
    it 'is an object with success' do

      ## General Response
      expect(output).to be_kind_of(::Hash)
      expect(output['success']).to be_truthy

      expect(output['internalid']).to be >= 1 ## Any post operation for a record will contain an internalid property in the response
      expect(output['reference_id']).to be >= 1 # ZAB Automation Properties
    end
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    it 'contains internalid' do
      expect(sample_output['internalid']).to be == 101
      expect(sample_output).to have_key('internalid')
    end

    it 'contains reference_id' do
      expect(sample_output['reference_id']).to be == 123
      expect(sample_output).to have_key('reference_id')
    end
  end

  describe 'input_fields' do
    subject(:input_fields) { action.input_fields(settings, input) }

    it 'is an array' do
      expect(input_fields).to be_kind_of(Array)
    end

    it 'contains options group' do
      expect(input_fields[0]['name']).to eq('options')
    end

    it 'contains record fields group' do
      expect(input_fields[1]['name']).to eq('record_fields')
    end
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields(settings, input) }

    it 'contains internalid' do
      expect(output_fields[0]['name']).to eq('internalid')
    end

    it 'contains reference_id' do
      expect(output_fields[1]['name']).to eq('reference_id')
    end
  end
end
