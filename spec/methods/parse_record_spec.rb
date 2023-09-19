# frozen_string_literal: true

RSpec.describe 'methods/parse_record', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }
  let(:input) { JSON.parse(File.read('fixtures/methods/post/input/create.json'))}

  subject(:result) { connector.methods.parse_record(input) }

  it 'contains a record property' do
    expect(result).to have_key('body')
    expect(result['record']).to be_kind_of(Object)
  end

  it 'contains a sublist property' do
    expect(result).to have_key('sublists')
    expect(result['sublists']).to be_kind_of(Object)
  end

  it 'contains internalid within record property' do
    expect(result['body']).to have_key('internalid')
  end

  it 'contains sublist name within sublist property' do
    expect(result['sublists']).to have_key('currency')
    expect(result['sublists']['currency']).to be_kind_of(Array)
  end
end
