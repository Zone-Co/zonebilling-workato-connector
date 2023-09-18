# frozen_string_literal: true

RSpec.describe 'pick_lists/api_exports', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.api_exports(settings) }

  it 'returns a list of ZAB API exports in the account' do
    expect(pick_list).to be_kind_of(Array)
  end

  it 'returns a full list of ZAB API exports' do
    expect(pick_list.length).to be >= 20 ## Default bundle contains >20 API exports
  end

  it 'each result has a property and a name' do
    pick_list.each do |result|
      expect(result).to be_kind_of(Array)

      name = result[0]
      property = result[1]

      expect(name).to be_kind_of(String)
      expect(property).to be_kind_of(String)
      expect(property).to include('_')
    end
  end
end
