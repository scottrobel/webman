require "./lib/players"
require './lib/game'
require './lib/file_manager.rb'
FileManager.create_valid_words_file 
game_over_conditional = lambda {|game| game.game_over?}
game_not_over = lambda {|game| !game.game_over?}
FileManager.select_games(&lambda {|game| game.game_over?})
FileManager.select_games(&lambda{|game| !game.game_over?})
game = FileManager.get_game
until(game.game_over?)
    game.play_round
end
FileManager.save_game(game) if(game.game_number)
print "Congrads You win!\n".red if(game.win?)
print "Congrads You win!\n".red if(game.loss?)