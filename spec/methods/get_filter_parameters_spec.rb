# frozen_string_literal: true

RSpec.describe 'methods/get_filter_parameters', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  context 'when options are provided' do

    subject(:result_with_options) { connector.methods.get_filter_parameters({
      'options' => {
        'export_id' => 'zab_customer',
        'page_size' => 100,
        'page' => 1
      },
      'dynamic_filters' => {
        'filters' => [
          {
            'type' => 'filter',
            'operator' => 'is',
            'field_id' => 'subsidiary',
            'value' => '1'
          },
          {
            'type' => 'filter',
            'operator' => 'contains',
            'field_id' => 'name',
            'value' => 'workato'
          }
        ]
      }
    }) }

    it 'returns a formatted params hash' do
      expect(result_with_options['export_id']).to eq('zab_customer')
      expect(result_with_options['page_size']).to eq(100)
      expect(result_with_options['page']).to eq(1)
      expect(result_with_options['filter_is_subsidiary']).to eq('1')
      expect(result_with_options['filter_contains_name']).to eq('workato')
    end

  end
end
