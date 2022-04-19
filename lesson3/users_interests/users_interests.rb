require 'yaml'

require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  Psych == YAML
  @users = Psych.load_file("users.yaml")
end

get "/" do
  redirect "/users"
end

get "/users" do
  @title = 'Users and Interests'

  erb :users
end

get "/users/:name" do
  name = params['name']
  redirect "/" unless @users.keys.include? name.to_sym

  @title = name.capitalize
  @name = name
  @email = @users[name.to_sym][:email]
  @interests = @users[name.to_sym][:interests]

  erb :profile
end

not_found do
  redirect "/"
end

helpers do
  def count_users
    @users.keys.size
  end

  def count_interests
    @users.values.flat_map { |info| info[:interests] }.size 
  end
end