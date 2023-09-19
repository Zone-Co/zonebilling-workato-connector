# frozen_string_literal: true

RSpec.describe 'actions/create_record', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:action) { connector.actions.create_record }

  subject(:input) {
    input = JSON.parse(File.read('fixtures/methods/post/input/upsert.json'))
  }
  subject(:output) { action.execute(settings, input) }

  context 'execute' do

    # Request Response
    it 'is an object with success' do

      ## General Response
      expect(output).to be_kind_of(::Object)
      expect(output['success']).to be_truthy

      expect(output['internalid']).to be >= 1 ## Any post operation for a record will contain an internalid property in the response

      ## Given the 'export_id' property of the request body
      expect(output['results']).to be_kind_of(::Array)
      expect(output['results'].length).to eq(1)

      ## The result object should contain the property for internalid and the value match the response id
      result = output['results'][0]
      expect(result).to be_kind_of(::Object)
      expect(result['internalid']['value']).to eq(output['internalid'].to_s)
    end
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    it 'contains internalid' do
      expect(sample_output['internalid']).to be == 101
      expect(sample_output).to have_key('internalid')
    end

    it 'contains results' do
      expect(sample_output['results']).to be_kind_of(Object)
      expect(sample_output).to have_key('results')
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

    it 'contains results' do
      expect(output_fields[1]['name']).to eq('results')
    end
  end
end
