# frozen_string_literal: true

RSpec.describe 'methods/validate_response', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  context 'when response is valid' do

    subject(:result_body) { {
      'success' => true,
      'internalid' => 123
    }}
    subject(:result_success) { connector.methods.validate_response(200, result_body, {}) }

    it 'returns response body' do
      expect(result_success).to be_kind_of(Object)
    end

    it 'returns response status' do
      expect(result_success[:success]).to be_truthy
    end
  end

  context 'when response in an array' do

    subject(:result_body_array) { [
      {
        'success' => true,
        'internalid' => 123
      },
      {
        'success' => true,
        'internalid' => 456
      },
    ]}
    subject(:result_success_with_array) { connector.methods.validate_response(200, result_body_array, {}) }

    it 'returns response body' do
      expect(result_success_with_array).to be_kind_of(Array)
    end

    it 'returns response status' do
      expect(result_success_with_array[0][:success]).to be_truthy
    end
  end

  context 'when response is invalid' do

    subject(:result_body_with_failure) { {
      'success' => false,
    }}

    it 'returns error' do
      error_caught = false

      begin
        subject(:result_failure) { connector.methods.validate_response(200, result_body_with_failure, {}) }
      rescue
        error_caught = true
      ensure
        expect(error_caught).to be_truthy ## This always will hit
      end
    end
  end
end
