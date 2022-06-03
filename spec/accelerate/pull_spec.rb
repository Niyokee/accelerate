# frozen_string_literal: true

require "spec_helper"

RSpec.describe Accelerate::Pull do
  let!(:json) do
    f = File.read(fixture_path("response/pull.json")) { |f| JSON.parse(f) }
    JSON.parse(f).first
  end

  describe "#to_h" do
    it do
      expected_hash = {
        author: "user_name",
        number: 99_999,
        url: "https://api.github.com/repos/test_org/test_repo/pulls/99999",
        title: "title",
        opened_at: "2022-05-14 19:25",
        merged_at: "2022-05-20 23:55",
        lead_time: 8911
      }
      Accelerate::Pulls::Collection.new(JSON.parse(File.read(fixture_path("response/pull.json")) { |f| JSON.parse(f) })).write_to_csv

      expect(described_class.new(json).to_h).to eq expected_hash
    end
  end
end
