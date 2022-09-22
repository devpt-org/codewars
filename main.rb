# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2022 Hugo Peixoto <hugo.peixoto@gmail.com>

require 'sinatra'

require './database.rb'
require './models.rb'

User.all.each(&:refresh!)

get '/' do
  challenges = Challenge.all
  users = User.all.sort_by { |u| -u.score(challenges) }

  ERB
    .new(File.read("index.html.erb"), trim_mode: "<>-")
    .result_with_hash(users: users, challenges: challenges)
end
