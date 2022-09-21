require 'sinatra'
require 'pg'
require 'active_record'
require 'net/http'

ActiveRecord::Base.establish_connection
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :username
    t.json :profile
    t.json :completed_challenges
  end

  create_table :challenges, force: true do |t|
    t.string :kata
    t.integer :year
    t.integer :week
  end
end

module CodewarsAPI
  def self.profile(username)
    JSON.parse(Net::HTTP::get(URI("https://www.codewars.com/api/v1/users/#{username}")))
  end

  def self.completed_challenges(username, page = 0)
    response = JSON.parse(Net::HTTP::get(URI("https://www.codewars.com/api/v1/users/#{username}/code-challenges/completed?page=#{page}")))

    if page + 1 < response["totalPages"]
      response["data"] + completed_challenges(username, page + 1)
    else
      response["data"]
    end
  end
end

class User < ActiveRecord::Base
  def self.register(username)
    self.create(
      username: username,
      profile: CodewarsAPI.profile(username),
    )
  end

  def refresh!
    update!(
      completed_challenges: CodewarsAPI.completed_challenges(username),
    )
  end

  def points(challenges)
    challenges.map do |challenge|
      self
        .completed_challenges
        .find { |c| c["id"] == challenge.kata }
        &.then do |c|
          Date.parse(c["completedAt"]).strftime("%Yw%-V") == "#{challenge.year}w#{challenge.week}" ? 3 : 1
        end
    end
  end

  def score(challenges)
    points(challenges).reject(&:nil?).sum
  end
end

class Challenge < ActiveRecord::Base; end

User.register('hugopeixoto').refresh!
User.register('GunterJameda').refresh!
User.register('joaoportela').refresh!
User.register('simaob').refresh!

Challenge.find_or_create_by!(year: 2022, week: 38, kata: '50654ddff44f800200000004')
Challenge.find_or_create_by!(year: 2022, week: 39, kata: '550498447451fbbd7600041c')
Challenge.find_or_create_by!(year: 2022, week: 40)
Challenge.find_or_create_by!(year: 2022, week: 41)

get '/' do
  challenges = Challenge.all
  users = User.all.sort_by { |u| -u.score(challenges) }

  ERB
    .new(File.read("index.html.erb"), trim_mode: "<>-")
    .result_with_hash(users: users, challenges: challenges)
end
