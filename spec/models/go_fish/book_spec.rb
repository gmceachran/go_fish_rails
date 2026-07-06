require "rails_helper"

RSpec.describe GoFish::Book, type: :model do
  describe '#value' do
    it 'returns the index of the given rank' do
      book = GoFish::Book.new('4')
      expect(book.value).to be 2
    end
  end
end
