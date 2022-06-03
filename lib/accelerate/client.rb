# frozen_string_literal: true

require "octokit"

class Client
  def initialize
    @client = Octokit::Client.new(access_token: "token")
  end

  def pull_requests(repo, options = {})
    client.pulls(repo, options)
  end

  private

  attr_reader :client
end
