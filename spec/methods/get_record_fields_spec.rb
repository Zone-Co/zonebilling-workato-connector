# frozen_string_literal: true

RSpec.describe 'methods/get_record_fields', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result_with_record_type) { connector.methods.get_record_fields(connector.connection, 'customer') }

  context 'when the record type is given' do

    it 'returns the record fields' do
      expect(result_with_record_type).to be_kind_of(Array)
    end

    it 'returns the record fields formatted correctly' do
      result_with_record_type.each do |field|
        name = field[0]
        script_id = field[1]

        expect(name).to be_kind_of(String)
        expect(script_id).to be_kind_of(String)
        expect(script_id).to_not include(' ')
      end
    end
  end
end
