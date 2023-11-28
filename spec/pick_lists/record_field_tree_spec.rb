# frozen_string_literal: true

RSpec.describe 'pick_lists/record_field_tree', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list_no_selection) { connector.pick_lists.record_field_tree(settings) }

  describe('before selection') do

    it 'returns a list' do
      expect(pick_list_no_selection).to be_kind_of(Array)
    end

    it 'returns a full list of Record Types' do
      expect(pick_list_no_selection.length).to be >= 40 ## There should be at least 40 returned
    end

    it 'each result has a property and a name' do
      pick_list_no_selection.each do |result|
        label = result[0]
        script_id = result[1]
        child_options = result[2]
        is_parent = result[3]

        expect(label).to be_kind_of(String)
        expect(script_id).to be_kind_of(String)
        expect(script_id).to_not include(' ') ## Script ID should not contain spaces
        expect(child_options).to be(nil)
        expect(is_parent).to be_truthy
      end
    end
  end

  subject(:pick_list_with_selection) { connector.pick_lists.record_field_tree(settings, {:__parent_id => 'customer' }) }

  describe('after selection') do

    it 'returns a list' do
      expect(pick_list_with_selection).to be_kind_of(Array)
    end

    it 'returns a full list of Record Types' do
      expect(pick_list_with_selection.length).to be >= 40 ## There should be at least 40 returned
    end

    it 'returns a list with the child fields' do

      ## Filter to just the child fields
      child_fields = pick_list_with_selection.select { |result|
        label = result[0]
        script_id = result[1]
        child_options = result[2]
        is_parent = result[3]

        script_id.include?('customer.') && !is_parent
      }

      expect(child_fields).to be_kind_of(Array)
      expect(child_fields.length).to be >= 10 ## There should be at least 10 fields returned
    end
  end
end
