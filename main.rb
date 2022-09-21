require 'sinatra'
require 'pg'
require 'net/http'
require 'active_record'

require './database.rb'
require './codewars.rb'
require './models.rb'

User.all.each(&:refresh!)

get '/' do
  challenges = Challenge.all
  users = User.all.sort_by { |u| -u.score(challenges) }

  ERB
    .new(File.read("index.html.erb"), trim_mode: "<>-")
    .result_with_hash(users: users, challenges: challenges)
end
