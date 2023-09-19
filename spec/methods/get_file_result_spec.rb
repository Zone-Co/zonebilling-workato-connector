# frozen_string_literal: true

RSpec.describe 'methods/get_file_result', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  results = {
    'file' => {
      "name" => "Template File",
      "description" => "Template File description",
      "contents" => "Template File contents",
     }
  }

  subject(:result) { connector.methods.get_file_result(results) }

  it 'should return a file formated object' do
    expect(result).to be_kind_of(Object)
  end

  it 'should return a file with name' do
    expect(result['name']).to eq('Template File')
  end

  it 'should return a file with description' do
    expect(result['description']).to eq('Template File description')
  end

  it 'should return a file with contents' do
    expect(result['contents']).to eq('Template File contents')
  end
end
