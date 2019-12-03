# frozen_string_literal: true

require 'sinatra'
require './lib/hangman/lib/players'
require './lib/hangman/lib/game'
require './lib/hangman/lib/file_manager.rb'
get '/' do
  erb :start_game
end

post '/play-game' do
  var_hash = {}
  @@game = make_game(params['player-name']) unless defined?(@@game)
  restart_game if params['restart-game']
  if guess_exists(params['guess'])
    guess = params['guess']
    @@game.make_guess(guess)
  end
  var_hash[:feedback] = @@game.feedback
  restart_game if @@game.game_over?
  var_hash[:bad_guesses] = @@game.bad_guesses.join('  ')
  var_hash[:player_name] = @@game.player_name
  var_hash[:hint] = @@game.hints.join(' ')
  var_hash[:guesses_left] = @@game.guesses_left
  erb :play_game, locals: var_hash
end

def guess_exists(guess)
  !params['guess'].nil? && !params['guess'].empty?
end

def make_game(player_name)
  Game.new(Player.new(player_name))
end

def restart_game
  player_name = @@game.player_name
  @@game = Game.new(Player.new(player_name))
end

def unfinished_games
  game_not_over = ->(game) { !game.game_over? }
  FileManager.select_games(&game_not_over)
end
