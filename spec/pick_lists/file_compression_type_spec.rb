# frozen_string_literal: true

RSpec.describe 'pick_lists/file_compression_type', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.file_compression_type(settings) }

  it 'returns the list of compression types' do
    expect(pick_list).to eq([
      ['CPIO', 'cpio'],
      ['TAR', 'tar'],
      ['TBZ2', 'tbz2'],
      ['TGZ', 'tgz'],
      ['ZIP', 'zip']
    ])
  end
end
