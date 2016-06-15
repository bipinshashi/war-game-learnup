require_relative './api.rb'
require_relative './player.rb'

class WarGame

	def initialize
		@api = WarAPI.new
		@heirarchy = ['2','3','4','5','6','7','8','9','10','J', 'Q', 'K', 'A']
	end

	def start(name, email)
		response = @api.new_game(name, email)
		@game_id = response['data']['id']
		@player1 = Player.new(response['data']['one'])
		@player2 = Player.new(response['data']['two'])
		puts '-------------'
		puts 'INITIAL HAND'
		puts '-------------'
		puts "player1 cards : #{@player1.hand}"
		puts "player2 cards : #{@player2.hand}"
		run_gameplay
	end

	private
	
	def run_gameplay
		war_mode = false
		while true
			play_hand_result = play_hand
			if play_hand_result == 'true'
				compare_result = compare(@player1.current_card, @player2.current_card)
				p "player1: #{@player1.current_card}, player2: #{@player2.current_card}, compare: #{compare_result}"
				if compare_result == 0
					#enter war mode
					p "WAR MODE!!"
					@player1.add_current_card_to_war_cards
					@player2.add_current_card_to_war_cards
					war_mode = true
					break
				elsif compare_result == 1
					@player1.add_to_collection_pile([@player1.current_card, @player2.current_card, @player1.war_cards, @player2.war_cards])
				else
					@player2.add_to_collection_pile([@player1.current_card, @player2.current_card, @player1.war_cards, @player2.war_cards])
				end
				@player1.reset
				@player2.reset
			else
				display_winner(play_hand_result)
				return
			end
		end
		if war_mode
			war_mode = false
			play_war_result = play_war
			if play_war_result == nil 
				run_gameplay 
			else 
				display_winner(play_war_result)
				return
			end
		end
	end

	def play_war
		winner = nil
		(0..2).each do |i|
			play_hand_result = play_hand
			if play_hand_result != 'true'
				winner = play_hand_result
				break
			else
				@player1.add_current_card_to_war_cards
				@player2.add_current_card_to_war_cards
			end
		end
		return winner
	end

	def play_hand
		card1, card2 = @player1.play_card, @player2.play_card
		if card1 == nil && card2 == nil
			return 'tie'
		elsif card1 == nil
			#declare player 2 as winner
			return 'two'
		elsif card2 == nil
			#declare player 1 as winner
			return 'one'
		end
		if card1 == 'shuffle' && card2 == 'shuffle'
			shuffle_deck(['one', 'two'])
			@player1.play_card
			@player2.play_card
		elsif card1 == 'shuffle'
			shuffle_deck(['one'])
			@player1.play_card
		elsif card2 == 'shuffle'
			shuffle_deck(['two'])
			@player2.play_card
		end
		return 'true'
	end

	def shuffle_deck(player_keys)
		query_hash = {}
		puts "shuffling #{player_keys}"
		player_keys.each do |key|
			if key == 'one'
				query_hash['one'] = @player1.collection_pile
			elsif key == 'two'
				query_hash['two'] = @player2.collection_pile
			end
		end
		shuffle_response = @api.shuffle_deck(@game_id, query_hash)
		if shuffle_response["success"] == true
			shuffle_response["data"].keys.each do |key|
				if key == "one"
					@player1.switch_collection_pile(shuffle_response["data"]["one"])
				elsif key == "two"
					@player2.switch_collection_pile(shuffle_response["data"]["two"])
				end
			end
		else
			puts "shuffle card response false!! #{shuffle_response}"
		end
	end

	def compare(card1, card2)
		#returns 0 if tie, 1 if card 1 > card 2 or else 2
		card1 = card1.split("")[0..-2].join
		card2 = card2.split("")[0..-2].join
		card1_index = @heirarchy.index(card1)
		card2_index = @heirarchy.index(card2)
		if card1_index == card2_index
			return 0
		elsif card1_index > card2_index
			return 1
		else
			return 2
		end
	end

	def display_winner(winner)
		puts "winner is #{winner}!!!  game_id: #{@game_id}"
		response = @api.declare_winner(@game_id, winner)
		puts response
	end
end

WarGame.new.start('bipen','bipen.sasi@gmail.com')