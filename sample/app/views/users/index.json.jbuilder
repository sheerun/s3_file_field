json.array!(@users) do |user|
  json.extract! user, :id, :name, :avatar
  json.url user_url(user, format: :json)
end
