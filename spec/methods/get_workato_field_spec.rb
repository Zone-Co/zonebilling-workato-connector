# frozen_string_literal: true

RSpec.describe 'methods/get_workato_field', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }



  context 'when NetSuite field is a mandatory custom select field' do

    custom_select_mandatory = {
      "id"  =>  "custrecord_workato_c_parent",
      "type"  =>  "select",
      "label"  =>  "Parent",
      "mandatory"  =>  true,
    }

    subject(:result) { connector.methods.get_workato_field(custom_select_mandatory, true) }

    it 'returns with the correct name' do
      expect(result['name']).to eq('custrecord_workato_c_parent')
    end

    it 'returns with the correct label' do
      expect(result['label']).to eq('Parent')
    end

    it 'returns with the correct hint' do
      expect(result['hint']).to eq('<b>Field ID: </b>custrecord_workato_c_parent')
    end

    it 'returns optional' do
      expect(result['optional']).to be_falsey
    end

    it 'returns a select field' do
      expect(result['control_type']).to eq(:integer)
    end

    it 'returns a toggle field' do
      expect(result['toggle_hint']).to eq('Value')
      expect(result['toggle_field']).to be_kind_of(Object)
      expect(result['toggle_field']['name']).to eq('custrecord_workato_c_parent-text')
      expect(result['toggle_field']['label']).to eq('Parent (in Text)')
      expect(result['toggle_field']['type']).to eq(:string)
      expect(result['toggle_field']['control_type']).to eq(:text)
      expect(result['toggle_field']['toggle_hint']).to eq('Text')
      expect(result['toggle_field']['hint']).to eq('<b>Field ID: </b>custrecord_workato_c_parent.text')
    end
  end
end
