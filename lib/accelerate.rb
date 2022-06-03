# frozen_string_literal: true

require "json"
require "octokit"
require "csv"
require "accelerate/version"

module Accelerate
  class Main
    def initialize(access_token:, filename:, repo:)
      @access_token = access_token
      @filename = filename
      @repo = repo
    end

    def call
      response = get_pulls({ state: "closed", sort: "long-running" })
      pulls = Accelerate::Pulls::Translator.new(response).to_pulls
      Accelerate::Pulls::Collection.new(pulls).write_to_csv(filename)
    end

    private

    def client
      Accelerate::Client.new(access_token)
    end

    def get_pulls(options)
      client.pull_requests(repo, options)
    end

    attr_reader :access_token, :filename, :repo
  end

  module Pulls
    class Collection
      def initialize(pulls)
        @pulls = pulls
      end

      def write_to_csv(filename, mode = "a")
        CSV.open(filename, mode, **csv_options) do |test|
          pulls.each { |pull| test << pull.to_h.values }
        end
      end

      private

      def csv_options
        {
          headers: %w[author number url title opened_at merged_at lead_time],
          row_sep: "\n"
        }
      end

      attr_reader :pulls
    end

    class Translator
      def initialize(response)
        @response = response
      end

      def to_pulls
        response.map { |r| Pull.new(r.to_h) }
      end

      attr_reader :response
    end
  end

  class Pull
    def initialize(pull)
      @pull = pull
    end

    def author
      pull.dig(:user, :login)
    end

    def number
      binding.irb
      "##{pull[:number]}"
    end

    def url
      pull[:url]
    end

    def title
      pull[:title]
    end

    def opened_at
      pull[:created_at]
    end

    def merged_at
      pull[:merged_at]
    end

    def lead_time
      return nil if merged_at.nil? || opened_at.nil?

      diff = (merged_at - opened_at)
      minutes = sec_to_min(diff).ceil
      formatted_duration(minutes)
    end

    def formatted_duration(total_minute)
      hours = total_minute / 60
      minutes = (total_minute) % 60
      "#{hours}:#{minutes}"
    end

    def to_h
      {
        number:,
        title:,
        lead_time: lead_time,
        author:,
        opened_at: opened_at.strftime("%Y-%m-%d %H:%M"),
        merged_at: merged_at&.strftime("%Y-%m-%d %H:%M"),
        url:
      }
    end

    private

    attr_reader :pull

    def sec_to_min(sec)
      sec / 60
    end
  end

  class Client
    def initialize(access_token)
      @client = Octokit::Client.new(access_token:)
    end

    def pull_requests(repo, options = {})
      client.pulls(repo, options)
    end

    private

    attr_reader :client
  end
end
