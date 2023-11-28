# frozen_string_literal: true

RSpec.describe 'methods/is_transaction_type', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  transaction_types = [
    'invoice',
    'cashsale',
    'salesorder',
    'creditmemo',
    'cashrefund',
    'vendorbill',
    'vendorcredit',
    'vendorpayment',
    'expensereport',
    'opportunity',
    'estimate',
    'returnauthorization',
    'purchaseorder',
    'customerdeposit'
  ]

  transaction_types.each do |transaction_type|

    it "return true when record type is #{transaction_type}" do
      result =  connector.methods.is_transaction_type(transaction_type)

      expect(result).to be_truthy
    end
  end

  other_record_types = [
    'customer',
    'contact',
    'customrecordzab_subscription',
    'addressbook'
  ]

  other_record_types.each do |record_type|
    it "return false when record type is #{record_type}" do
      result =  connector.methods.is_transaction_type(record_type)

      expect(result).to be_falsey
    end
  end
end
