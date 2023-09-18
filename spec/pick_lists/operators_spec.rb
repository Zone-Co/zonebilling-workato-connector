# frozen_string_literal: true

RSpec.describe 'pick_lists/operators', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:pick_list) { connector.pick_lists.operators(settings) }

  it 'returns the list of operators' do
    expect(pick_list).to eq(
      [
        ["After", "after"],
        ["All of", "allof"],
        ["Any", "any"],
        ["Any Of", "anyof"],
        ["Before", "before"],
        ["Between", "between"],
        ["Contains", "contains"],
        ["Does not contain", "doesnotcontain"],
        ["Does not start with", "doesnotstartswith"],
        ["Equal To", "equalto"],
        ["Greater Than", "greaterthan"],
        ["Greater Than or Equal To", "greaterthanorequalto"],
        ["Has Keywords", "haskeywords"],
        ["Is", "is"],
        ["Is Empty", "isempty"],
        ["Is Not", "isnot"],
        ["Is Not Empty", "isnotempty"],
        ["Less Than", "lessthan"],
        ["Less Than or Equal To", "lessthanorequalto"],
        ["None Of", "noneof"],
        ["Not After", "notafter"],
        ["Not All Of", "notallof"],
        ["Not Before", "notbefore"],
        ["Not Between", "notbetween"],
        ["Not Equal To", "notequalto"],
        ["Not Greater Than", "notgreaterthan"],
        ["Not Greater Than or Equal To", "notgreaterthanorequalto"],
        ["Not Less Than", "notlessthan"],
        ["Not Less Than or Equal To", "notlessthanorequalto"],
        ["Not On", "noton"],
        ["Not On or After", "notonorafter"],
        ["Not On or Before", "notonorbefore"],
        ["Not Within", "notwithin"],
        ["On", "on"],
        ["On or After", "onorafter"],
        ["On or Before", "onorbefore"],
        ["Starts With", "startswith"],
        ["Within", "within"]
      ]
    )
  end


end
