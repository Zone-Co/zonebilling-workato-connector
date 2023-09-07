# frozen_string_literal: true

RSpec.describe 'connector', :vcr do

  # Spec describes the most commons blocks of an connector. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  it { expect(connector).to be_present }

  describe 'test' do
    subject(:output) { connector.test(settings) }

    context 'given valid credentials' do
      it 'establishes valid connection' do
        expect(output).to be_truthy
      end

      it 'returns response that is formatted properly' do
        # large Test responses might also cause connections to be evaluated wrongly
        expect(output.to_s.length).to be < 5000
        expect(output['list']).to be_kind_of(::Array)
      end
    end
  end
end
