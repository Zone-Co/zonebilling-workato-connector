# frozen_string_literal: true

RSpec.describe 'pick_lists/automations', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.automations(settings) }

  it 'returns a list of ZAB Automations in the account' do
      expect(pick_list).to be_kind_of(Array)
  end

  it 'returns a full list of ZAB Automations' do
    expect(pick_list.length).to be >= 1 ## There should be at least 1 configed in the Demo Account
  end

  it 'each result has a property and a name' do
    pick_list.each do |result|
      expect(result).to be_kind_of(Array)

      name = result[0]
      property = result[1]

      expect(name).to be_kind_of(String)
      expect(name).to include('ZABAUTO')
      expect(name).to include('(')
      expect(name).to include(')')
      expect(property.to_i).to be_kind_of(Integer)
    end
  end
end
