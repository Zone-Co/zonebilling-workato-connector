# frozen_string_literal: true

RSpec.describe 'methods/get_record_details', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  context 'no record type given' do

    it 'should raise an error' do
      error_thrown = false
      begin
        subject(:result_no_record_type) { connector.methods.get_record_details(connector.connection, '') }
        expect { result_no_record_type }.to be_truthy
      rescue
          error_thrown = true
      ensure
          expect(error_thrown).to be_truthy
      end
    end
  end

  context 'valid record type given' do

    subject(:result_with_record_type) { connector.methods.get_record_details(connector.connection, 'customer') }

    it 'should return an object' do
      expect(result_with_record_type).to be_a(Object)
    end

    it 'should return a success' do
      expect(result_with_record_type[:success]).to be_truthy
    end

    it 'should return fields' do
      expect(result_with_record_type[:fields]).to be_kind_of(Array)
    end

    it 'should return sublists' do
      expect(result_with_record_type[:sublists]).to be_kind_of(Array)
    end
  end


end
