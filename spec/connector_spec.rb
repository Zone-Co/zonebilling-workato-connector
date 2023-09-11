# frozen_string_literal: true

RSpec.describe 'connector', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  it { expect(connector).to be_present }

  describe 'acquire' do

    context 'given valid credentials' do
      # Assign the output variable as the output of your test lambda
      # Default call of ZAB API Export: zab_api_export, page=1, page_size=5
      subject(:output) {connector.test(settings)}

      it 'response object is returned' do
        expect(output).to be_kind_of(::Object)
      end

      it 'response contains truthy success property' do
        expect(output['success']).to be_truthy
      end

      it 'response page property is 1' do
        expect(output['page']).to be == 1
      end

      it 'response results property is less than or equal to 5' do
        expect(output['results_returned']).to be <= 5
      end

      it 'response results property is an array' do
        expect(output['results']).to be_kind_of(::Array)
      end
    end
  end
end
