# frozen_string_literal: true

RSpec.describe 'methods/get_record_types', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result) { connector.methods.get_record_types(connector.connection) }

  context 'gather record types' do

    it 'return a list of record types' do
      expect(result).to be_kind_of(Array)
    end

    it 'returns the record types formatted correctly' do
      result.each do |field|
        name = field[0]
        script_id = field[1]

        expect(name).to be_kind_of(String)
        expect(script_id).to be_kind_of(String)
        expect(script_id).to_not include(' ')
      end
    end
  end

end
