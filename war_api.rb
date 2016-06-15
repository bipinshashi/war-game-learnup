require 'httparty'

class WarAPI
  include HTTParty
  base_uri 'http://war.learnup.com'

  def new_game(name, email)
    self.class.post("/games", 
      body: {name: name, email: email}.to_json,
      headers: { 'Content-Type' => 'application/json' })
  end

  def shuffle_deck(game_id, options)
    self.class.post("/games/#{game_id}/shuffle_deck", 
      body: options.to_json, 
      headers: { 'Content-Type' => 'application/json' })
  end

  def declare_winner(game_id,winner)
    self.class.get("/games/#{game_id}/declare_winner/#{winner}",
      headers: { 'Content-Type' => 'application/json' })
  end
end

