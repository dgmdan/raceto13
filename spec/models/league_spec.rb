# frozen_string_literal: true

require 'rails_helper'

RSpec.describe League do
  it 'can see that all teams are available in an empty league' do
    league = League.new(name: 'My Pool')
    expect(league.available_teams.count).to eq(30)
  end
end
