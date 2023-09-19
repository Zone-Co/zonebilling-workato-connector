# frozen_string_literal: true

RSpec.describe 'actions/get_process_status', :vcr do

  subject(:output) { connector.actions.get_process_status(input) }

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  # Or add more fine grained tests for each action definition block
  let(:action) { connector.actions.get_process_status }
  let(:input) { { "process_id" => "389" } }


  describe 'execute' do
    subject(:output) { action.execute(settings, input) }

    it ('returns a response') do
      expect(output).to be_kind_of(Object)
      expect(output['status']).to be_kind_of(Object)
      expect(output['response']).to be_kind_of(Object)
      expect(output['response']['processed_count']).to be_kind_of(Integer)
      expect(output['response']['error_count']).to be_kind_of(Integer)
    end

  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    it 'contains status field' do
      expect(sample_output['status']).to be_kind_of(Object)
      expect(sample_output['status']['id']).to be_kind_of(String)
      expect(sample_output['status']['text']).to be_kind_of(String)
    end

    it 'contains response field' do
      expect(sample_output['response']).to be_kind_of(Object)
      expect(sample_output['response']['processed_count']).to be_kind_of(Integer)
      expect(sample_output['response']['error_count']).to be_kind_of(Integer)
      expect(sample_output['response']['results']).to be_kind_of(Array)
      expect(sample_output['response']['errors']).to be_kind_of(Array)
    end
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields(settings, input) }
    subject(:status_field) { output_fields[0] }
    subject(:response_field) { output_fields[1] }

    it 'returns 2 fields' do
      expect(output_fields.length).to eq(2)
    end

    it 'contains Status field' do
      expect(status_field['name']).to eq('status')
      expect(status_field['label']).to eq('Status')
      expect(status_field['type']).to eq('object')
      expect(status_field['properties']).to be_kind_of(Array)
    end

    it 'contains Response field with toggle' do
      expect(response_field['name']).to eq('response')
      expect(response_field['label']).to eq('Response')
      expect(response_field['type']).to eq('object')
      expect(response_field['properties']).to be_kind_of(Array)
    end
  end
end
