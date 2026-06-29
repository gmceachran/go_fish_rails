class PagesController < ApplicationController
  Rule = Struct.new(:title, :description)

  def rules
    @rules = [
      Rule.new(
        title: "Object of the Game",
        description: 'The goal is to win the most "books" of cards. A book is any four of a kind, such as four kings, four aces, and so on.'
      ),
      Rule.new(
        title: "Rank of Cards",
        description: "The cards rank from ace (high) to two (low). The suits are not important, only the card numbers are relevant, such as two 3s, two 10s, and so on."
      ),
      Rule.new(
        title: "The Deal",
        description: "If playing with one to two other players, each player is dealt seven cards. If playing with three to four other players, each player is dealt five cards."
      ),
      Rule.new(
        title: "The Play",
        description: "When it is your turn, select an opponent and any rank of a card you currently possess. If the selected opponent has card(s) of the given rank, sed cards will be taken from the opponent's hand and given to you. If you get one or more cards of the named rank that was asked for, you are entitled to ask the same or another player for a card. You can ask for the same card or a different one. So long as you succeed in getting cards (making a catch), your turn continues. When you make a catch, the card will be displayed to the other players so that the catch is verified. If you have an empty hand, you may draw from the deck. If the deck is empty, your turn is skipped."
      ),
      Rule.new(
        title: "Books",
        description: "When any player gets all cards of a suit, a book is made. When all thirteen books are made, the game is over and the winner declared."
      ),
      Rule.new(
        title: "Win Conditions",
        description: "The player with the most books wins. If two players have the same number of books, the player with the highest ranking book wins."
      )
    ]
  end
end
