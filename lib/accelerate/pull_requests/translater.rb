# frozen_string_literal: true

require "json"

module Accelerate
  module PullRequests
    class Translator
      def initialize(response)
        @response = response
      end

      def to_pull_requests
        to_json.map { |json| PullRequest.new(json) }
      end

      def to_json(*_args)
        Json.parse(response)
      end

      attr_reader :response
    end
  end
end
