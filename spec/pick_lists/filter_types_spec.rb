# frozen_string_literal: true

RSpec.describe 'pick_lists/filter_types', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.filter_types(settings) }

  it 'returns the list of filter types' do
    expect(pick_list).to eq([
      ['Default', 'filter'],
      ['Date', 'filterdate'],
      ['Date/Time', 'filterdatetime']
    ])
  end
end
