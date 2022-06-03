# frozen_string_literal: true

require "spec_helper"

RSpec.describe Accelerate::Pulls::Translator do
  let!(:response) do
    File.read(fixture_path("response/pull.json")) { |f| JSON.parse(f) }
  end

  describe "#to_pulls" do
    it "translates a http response to the array of Accelerate::Pull" do
      expect(described_class.new(response).to_pulls.first.class).to eq Accelerate::Pull
      expect(described_class.new(response).to_pulls.length).to eq 1
    end
  end
end
