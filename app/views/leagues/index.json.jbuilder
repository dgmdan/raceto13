# frozen_string_literal: true

json.array!(@leagues) do |league|
  json.extract! league, :id, :name, :user_id
  json.url league_url(league, format: :json)
end
