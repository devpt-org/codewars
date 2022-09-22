# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2022 Hugo Peixoto <hugo.peixoto@gmail.com>

require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define do
  create_table :users, if_not_exists: true do |t|
    t.string :username
    t.json :profile
    t.json :completed_challenges
  end

  create_table :challenges, if_not_exists: true do |t|
    t.string :kata
    t.integer :year
    t.integer :week
  end
end
