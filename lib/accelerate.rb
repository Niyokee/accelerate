# frozen_string_literal: true

require "json"
require "octokit"
require "csv"
# require "accelerate/version"

module Accelerate
  module Pulls
    class Collection
      def initialize(pulls)
        @pulls = pulls
      end

      def write_to_csv
        CSV.open("test.csv", "w") do |test|
          pulls.each { |pull| test << pull.to_h.values }
        end
      end

      private

      attr_reader :pulls
    end

    class Translator
      def initialize(response)
        @response = response
      end

      def to_pulls
        to_json.map { |json| Pull.new(json) }
      end

      private

      def to_json(*_args)
        JSON.parse(response)
      end

      attr_reader :response
    end
  end

  class Pull
    def initialize(pull)
      @pull = pull
    end

    def author
      pull.dig("user", "login")
    end

    def number
      pull["number"]
    end

    def url
      pull["url"]
    end

    def title
      pull["title"]
    end

    def opened_at
      Time.parse(pull["created_at"])
    end

    def merged_at
      Time.parse(pull["merged_at"])
    end

    def lead_time
      diff = (merged_at - opened_at)
      sec_to_min(diff)
    end

    def to_h
      {
        author:,
        number:,
        url:,
        title:,
        opened_at: opened_at.strftime("%Y-%m-%d %H:%M"),
        merged_at: merged_at.strftime("%Y-%m-%d %H:%M"),
        lead_time: lead_time.ceil
      }
    end

    private

    attr_reader :pull

    def sec_to_min(sec)
      sec / 60
    end
  end

  class Client
    def initialize
      @client = Octokit::Client.new(access_token: "access_token")
    end

    def pull_requests(repo, options = {})
      client.pulls(repo, options)
    end

    private

    attr_reader :client
  end
end
