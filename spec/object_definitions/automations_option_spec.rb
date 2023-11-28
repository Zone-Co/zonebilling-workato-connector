# frozen_string_literal: true

RSpec.describe 'object_definition/automations_option', :vcr do

  # Spec describes the most commons blocks of an object definition.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:object_definition) { connector.object_definitions.automations_option }

  describe 'fields' do
    subject(:schema_fields) { object_definition.fields(settings, {}) }
    subject(:automations_field) { schema_fields[0] }
    subject(:toggle_field) { automations_field['toggle_field'] }

    it 'returns 1 field' do
      expect(schema_fields.length).to eq(1)
    end

    it 'contains Automations field' do
      expect(automations_field['name']).to eq('automations')
      expect(automations_field['label']).to eq('Automations')
      expect(automations_field['delimiter']).to eq(',')
      expect(automations_field['pick_list']).to eq('automations')
      expect(automations_field['toggle_hint']).to eq('Select')
      expect(automations_field['extends_schema']).to be_truthy
      expect(automations_field['sticky']).to be_truthy
    end

    it 'contains Automations field with toggle' do
      expect(toggle_field['name']).to eq('automations')
      expect(toggle_field['label']).to eq('Automations')
      expect(toggle_field['toggle_hint']).to eq('ID')
      expect(toggle_field['type']).to eq(:string)
      expect(toggle_field['control_type']).to eq(:text)
      expect(toggle_field['change_on_blur']).to be_truthy
      expect(toggle_field['extends_schema']).to be_truthy
    end
  end
end
