require "rails_helper"

RSpec.describe GoFish::Book, type: :model do
  let(:rank) { "K" }
  let(:rank_index) { 11 }

  it "has a rank" do
    book = GoFish::Book.new(rank)
    expect(book.rank).to eq rank
  end

  describe "#value" do
    it "returns the index of the given rank" do
      book = GoFish::Book.new(rank)
      expect(book.value).to be rank_index
    end
  end

  describe "#from_json" do
    let(:rank) { "4" }
    let(:json) { { "rank" => rank } }

    it "receives a json hash and returns a GoFish::Book" do
      book = GoFish::Book.from_json(json)
      expect(book).to be_a_kind_of GoFish::Book
      expect(book.rank).to eq rank
    end
  end
end
