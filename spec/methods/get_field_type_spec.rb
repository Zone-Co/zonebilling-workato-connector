# frozen_string_literal: true

RSpec.describe 'methods/get_field_type', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  context 'should return the correct field type' do

      subject(:result_float) { connector.methods.get_field_type('float') }

      it 'for float' do
        expect(result_float).to eq('number')
      end

      subject(:result_currency) { connector.methods.get_field_type('currency') }

      it 'for currency' do
        expect(result_currency).to eq('number')
      end

      subject(:result_textarea) { connector.methods.get_field_type('textarea') }

      it 'for text area' do
        expect(result_textarea).to eq('plain-text-area')
      end

      subject(:result_datetime) { connector.methods.get_field_type('datetime') }

      it 'for date time' do
        expect(result_datetime).to eq('date_time')
      end

      subject(:result_url) { connector.methods.get_field_type('url') }

      it 'for url' do
        expect(result_url).to eq('url')
      end

      subject(:result_select) { connector.methods.get_field_type('select') }

      it 'for select' do
        expect(result_select).to eq('text')
      end
  end
end
