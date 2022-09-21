module Codewars
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
