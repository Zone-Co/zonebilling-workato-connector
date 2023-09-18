# frozen_string_literal: true

RSpec.describe 'pick_lists/file_export_type', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.file_export_type(settings) }

  it 'returns the list of operators' do
    expect(pick_list).to eq([
      ['PDF', 'recordpdf'],
      ['HTML', 'recordhtml']
    ])
  end
end
