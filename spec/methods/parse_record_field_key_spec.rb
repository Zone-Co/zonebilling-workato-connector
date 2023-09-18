# frozen_string_literal: true

RSpec.describe 'methods/parse_record_field_key', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  subject(:result_with) { connector.methods.parse_record_field_key('name-text') }
  subject(:result_without) { connector.methods.parse_record_field_key('name') }
  subject(:result_bad_formatting) { connector.methods.parse_record_field_key('name-field') }

  it 'field contains text' do
    expect(result_with).to eq('name.text')
  end

  it 'field does not contain text' do
    expect(result_without).to eq('name')
  end

  it 'field has poor formatting' do
    expect(result_bad_formatting).to eq('name')
  end
end
