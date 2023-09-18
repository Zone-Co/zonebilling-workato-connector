# frozen_string_literal: true

RSpec.describe 'pick_lists/record_types', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.record_types(settings) }

  it 'returns a list' do
      expect(pick_list).to be_kind_of(Array)
  end

  it 'returns a full list of Record Types' do
    expect(pick_list.length).to be >= 40 ## There should be at least 40 returned
  end

  it 'each result has a property and a name' do
    pick_list.each do |result|
      expect(result).to be_kind_of(Array)

      name = result[0]
      script_id = result[1]

      expect(name).to be_kind_of(String)
      expect(script_id).to be_kind_of(String)
      expect(script_id).to_not include(' ') ## Script ID should not contain spaces
    end
  end
end
