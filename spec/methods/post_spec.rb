# frozen_string_literal: true

RSpec.describe 'methods/post', :vcr do

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc', 'master.key') }

  let(:methods) { connector.methods }

  describe 'execute' do

    let(:create_input) { JSON.parse(File.read("fixtures/methods/post/input/create.json")) }
    let(:create_output) { methods.post(connector.connection, create_input, 'create') }

    it "create" do

      ## Validate Data Type
      expect(create_output).to be_kind_of(::Hash)
      ## By default, the ZAB API always returns a `success` param in the response
      expect(create_output[:success]).to be_truthy
      ## Any post operation for a record will contain an internalid property in the response
      expect(create_output[:internalid]).to be >= 1
      # ZAB Automation Properties
      expect(create_output[:reference_id]).to be >= 1
      ## Given the 'export_id' property of the request body
      expect(create_output[:results]).to be_kind_of(::Array)
      ## Should filter to the one record of the 'export_id' table
      expect(create_output[:results].length).to eq(1)

      ## Validate Export ID Response
      result = create_output[:results][0]
      ## Results are always a search result object
      expect(result).to be_kind_of(::Hash)
      ## The result object should contain the property for internalid and the value match the response id
      expect(result[:internalid][:value]).to eq(create_output[:internalid].to_s)

    end

    let(:update_input) { JSON.parse(File.read("fixtures/methods/post/input/update.json")) }
    let(:update_output) { methods.post(connector.connection, update_input, 'update') }

    it "update" do

      ## Validate Data Type
      expect(update_output).to be_kind_of(::Hash)
      ## By default, the ZAB API always returns a `success` param in the response
      expect(update_output[:success]).to be_truthy
      ## Any post operation for a record will contain an internalid property in the response
      expect(update_output[:internalid]).to be >= 1
      # ZAB Automation Properties
      expect(update_output[:reference_id]).to be >= 1
      ## Given the 'export_id' property of the request body
      expect(update_output[:results]).to be_kind_of(::Array)
      ## Should filter to the one record of the 'export_id' table
      expect(update_output[:results].length).to eq(1)

      ## Validate Export ID Response
      result = update_output[:results][0]
      ## Results are always a search result object
      expect(result).to be_kind_of(::Hash)
      ## The result object should contain the property for internalid and the value match the response id
      expect(result[:internalid][:value]).to eq(update_output[:internalid].to_s)

    end

    let(:update_input) { JSON.parse(File.read("fixtures/methods/post/input/upsert.json")) }
    let(:update_output) { methods.post(connector.connection, update_input, 'upsert') }

    it "upsert" do

      ## Validate Data Type
      expect(update_output).to be_kind_of(::Hash)
      ## By default, the ZAB API always returns a `success` param in the response
      expect(update_output[:success]).to be_truthy
      ## Any post operation for a record will contain an internalid property in the response
      expect(update_output[:internalid]).to be >= 1
      # ZAB Automation Properties
      expect(update_output[:reference_id]).to be >= 1
      ## Given the 'export_id' property of the request body
      expect(update_output[:results]).to be_kind_of(::Array)
      ## Should filter to the one record of the 'export_id' table
      expect(update_output[:results].length).to eq(1)

      ## Validate Export ID Response
      result = update_output[:results][0]
      ## Results are always a search result object
      expect(result).to be_kind_of(::Hash)
      ## The result object should contain the property for internalid and the value match the response id
      expect(result[:internalid][:value]).to eq(update_output[:internalid].to_s)

    end

    let(:automations_input) { JSON.parse(File.read("fixtures/methods/post/input/automations.json")) }
    let(:automations_output) { methods.post(connector.connection, {
      'options' => {
        'automations' => '1,2'
      }
    }, '') }

    it "automations" do

      ## Validate Data Type
      expect(automations_output).to be_kind_of(::Hash)
      ## By default, the ZAB API always returns a `success` param in the response
      expect(automations_output['success']).to be_truthy
      # ZAB Automation Properties
      expect(automations_output['reference_id']).to be_kind_of(Integer)

    end
  end
end
