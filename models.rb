class User < ActiveRecord::Base
  def self.register(username)
    self.create(
      username: username,
      profile: Codewars.profile(username),
    )
  end

  def refresh!
    update!(
      completed_challenges: Codewars.completed_challenges(username),
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
