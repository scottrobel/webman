# frozen_string_literal: true

require 'colorize'
$saved_games = File.open(File.expand_path(File.dirname(__FILE__)) + '/../saved_games.txt', 'r+')
module FileManager
  def self.create_valid_words_file
    unless File.exist?(File.expand_path(File.dirname(__FILE__)) + '/../words/valid_words.txt')
      valid_words = File.open(File.expand_path(File.dirname(__FILE__)) + '/../words/valid_words.txt', 'w+')
      until text_file.eof?
        word = text_file.readline
        word_length = word.chomp.length
        valid_words.write(word) if word_length <= 12 && word_length >= 5
      end
      puts 'file created'
    end
  end

  def self.get_saved_game(game_number)
    saved_game = FileManager.get_saved_games[game_number]
    saved_game.game_saved = false
    saved_game
  end

  def self.get_game
    if !FileManager.get_saved_games.empty?
      unfinished_game_numbers_array = FileManager.get_saved_games.map do |game|
        game.game_saved = false
        game
      end.reject(&:game_over?).map(&:game_number)
      game = nil
      while game.nil?
        print_game = lambda do |game|
          game.game_saved = false
          print game.game_over? ? game.to_s.red + "    Finished\n".green : game.to_s.blue + "    unfinished\n".green
        end
        FileManager.get_saved_games.each(&print_game)
        puts "would you like to resume one of these games\nEnter a game number to resume an unfinished game\nn/no = create new game"
        answer = gets.chomp.downcase
        game_number = answer.match(/[0-9]/) ? answer.to_i : 'not a game number'
        if answer == 'n' || answer == 'no'
          game = FileManager.make_game_from_user_input
          end
        if unfinished_game_numbers_array.include?(game_number)
          game = FileManager.get_saved_game(game_number)
          end
      end
    else
      game = FileManager.make_game_from_user_input
    end
    puts game
    game
  end

  def self.make_game_from_user_input
    puts 'creating new game'.green
    puts 'enter your name'
    name = gets.chomp
    Game.new(Player.new(name))
  end

  def self.save_game(game)
    largest_game_number = FileManager.get_saved_games[-1].game_number
    if !game.game_number
      game.game_saved = true
      games = FileManager.get_saved_games
      game.game_number = largest_game_number ? largest_game_number + 1 : 0
      games << game
      marshaled_games = games.map { |game| Marshal.dump(game) }
      $saved_games = File.open(File.expand_path(File.dirname(__FILE__)) + '/../saved_games.txt', 'w+')
      $saved_games.write(marshaled_games.join('_____'))
      puts 'file was saved'
    else
      game.game_saved = true
      games = FileManager.get_saved_games
      games[game.game_number] = game
      marshaled_games = games.map { |game| Marshal.dump(game) }
      $saved_games = File.open('./saved_games.txt', 'w+')
      $saved_games.write(marshaled_games.join('_____'))
      puts 'file was resaved'
    end
  end

  def self.display_saved_games
    FileManager.get_saved_games.each do |game|
      if !game.game_over?
        puts game.to_s.green
      else
        puts "#{game} Game over".red
      end
    end
  end

  def self.get_saved_games
    $saved_games.rewind
    $saved_games.read.split('_____').map { |game| Marshal.load(game) }
  end

  def self.select_games(&lambda_condition)
    FileManager.get_saved_games.select(&lambda_condition)
  end
end
