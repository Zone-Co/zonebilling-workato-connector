# frozen_string_literal: true

RSpec.describe 'methods/get_external_references', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  input = {
    'external_references' => [
      {
        'field_id' => "custrecordzab_s_customer",
        'related_field_id' => "customer.externalid",
      },
      {
        'field_id' => "custrecordzab_s_master_contract",
        'related_field_id' => "customrecordzab_mastercontract.externalid",
      }
    ]
  }


  context('external references are given') do

    subject(:result) { connector.methods.get_external_references(input) }

    it 'option 1 is formatted correctly' do
      expect(result[0]).to be_kind_of(Object)
      expect(result[0]['fieldId']).to eq('custrecordzab_s_customer')
      expect(result[0]['relatedRecordType']).to eq('customer')
      expect(result[0]['relatedFieldId']).to eq('externalid')
    end

    it 'option 2 is formatted correctly' do
      expect(result[1]).to be_kind_of(Object)
      expect(result[1]['fieldId']).to eq('custrecordzab_s_master_contract')
      expect(result[1]['relatedRecordType']).to eq('customrecordzab_mastercontract')
      expect(result[1]['relatedFieldId']).to eq('externalid')
    end
  end
end
