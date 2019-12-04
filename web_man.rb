# frozen_string_literal: true

require 'sinatra'
require './lib/hangman/lib/players'
require './lib/hangman/lib/game'
require './lib/hangman/lib/file_manager.rb'
enable :sessions
get '/' do
  erb :start_game
end
get '/play-game' do
  redirect to('/')
end 
post '/play-game' do
  var_hash = {}
  if params['restart-game']
    player_name = session[:game].player_name
    restart_game
  end
  player_name = params['player-name']
  session[:game] = make_game(player_name) if !defined?(session[:game]) || new_name?(player_name)
  if guess_exists(params['guess'])
    guess = params['guess']
    session[:game].make_guess(guess)
  end
  var_hash[:feedback] = session[:game].get_feedback
  restart_game if session[:game].game_over?
  var_hash[:bad_guesses] = session[:game].bad_guesses.join('  ')
  var_hash[:player_name] = session[:game].player_name
  var_hash[:hint] = session[:game].hints.join(' ')
  var_hash[:guesses_left] = session[:game].guesses_left
  erb :play_game, locals: var_hash
end

def new_name?(name_param)
  session[:game].nil? || (name_param != session[:game].player_name && !name_param.nil?)
end

def guess_exists(guess)
  !params['guess'].nil? && !params['guess'].empty?
end

def make_game(player_name)
  Game.new(Player.new(player_name))
end

def restart_game
  player_name = session[:game].player_name
  session[:game] = make_game(player_name)
end

def unfinished_games
  game_not_over = ->(game) { !game.game_over? }
  FileManager.select_games(&game_not_over)
end
