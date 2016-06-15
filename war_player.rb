class WarPlayer
	attr_reader :hand, :collection_pile, :current_card, :war_cards

	def initialize(hand)
		@hand = hand
		@collection_pile = []
		@war_cards = []
	end

	def play_card
		@current_card = @hand.shift
		if @current_card == nil
			if @collection_pile.empty?
				return nil
			else
				return 'shuffle'
			end
		else
			return @current_card
		end
	end

	def add_current_card_to_war_cards
		@war_cards << @current_card if @current_card
	end

	def switch_collection_pile(shuffled_collection)
		@hand = shuffled_collection
		@collection_pile = []
	end

	def add_to_collection_pile(cards)
		@collection_pile.concat(cards).flatten!
	end

	def reset
		@current_card = nil 
		@war_cards = []
	end
 
end