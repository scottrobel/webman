# frozen_string_literal: true

require './lib/players'
require './lib/game'
require './lib/file_manager.rb'
FileManager.create_valid_words_file
game_over_conditional = ->(game) { game.game_over? }
game_not_over = ->(game) { !game.game_over? }
FileManager.select_games(&->(game) { game.game_over? })
FileManager.select_games(&->(game) { !game.game_over? })
game = FileManager.get_game
game.play_round until game.game_over?
FileManager.save_game(game) if game.game_number
print "Congrads You win!\n".red if game.win?
print "Congrads You win!\n".red if game.loss?
