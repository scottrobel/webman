# frozen_string_literal: true

require_relative 'players'
require 'colorize'
class Game
  attr_reader :player_name, :guesses_left, :secret_word, :feedback, :bad_guesses
  attr_accessor :game_number, :game_saved
  def initialize(player)
    @player_name = player.name
    @guesses_left = 20
    @bad_guesses = []
    @correct_guesses = {} # key is index of correct guess value is letter of correct guess
    @game_saved = false
    set_secret_word
  end

  def hints
    hints = ('_' * secret_word.length).chars
    @correct_guesses.each do |index, char|
      hints[index] = char
    end
    hints
  end

  def get_feedback
    if game_over?
      word = "The word was #{@@game.secret_word}"
      if win?
        'You Win! ' + word
      else
        'better luck next time! ' + word
      end
    else
      @feedback
    end
  end

  def make_guess(char)
    char = char.match(/([a-z])/)
    if !char
      @feedback = 'Invalid Input'
    else
      char = char[1].downcase
      if guesses.include? char
        @feedback = "You already Guessed #{char}"
      elsif secret_word.include?(char)
        update_correct_chars(char)
        @feedback = 'correct'
      else
        update_incorrect_chars(char)
        @feedback = 'incorrect'
      end
    end
  end

  def play_round
    display_bad_guesses
    display_hints
    display_guesses_left
    puts "or type 'save' to save the game"
    guess = get_user_input
    make_guess(guess)
    @guesses_left -= 1
  end

  def game_over?
    win? || loss?
  end

  def to_s
    "game ##{game_number} Player Named '#{@player_name}' #{get_hints.join(' ')} wrong letters#{@bad_guesses}"
  end

  def win?
    secret_word == hints.join('')
  end

  def loss?
    @guesses_left <= 0 && !win?
  end

  private

  def guesses
    @correct_guesses.values.concat(@bad_guesses)
  end

  def display_guesses_left
    puts "you have #{@guesses_left} guesses left. use them wisley"
  end

  def display_hints
    puts get_hints.join(' ').to_s.green
  end

  def get_user_input
    puts 'enter char'
    guess = gets.chomp.downcase
    valid_letters = ('a'..'z').to_a - @bad_guesses - @correct_guesses.values
    until valid_letters.include?(guess) || guess == 'save'
      puts 'invalid char please try again'
      guess = gets.chomp.downcase
      print "#{!valid_letters.include?(guess)}  #{!guess == 'save'} ".blue
    end
    guess == 'save' ? guess : guess.match(/[a-z]/)[0]
  end

  def game_saved?
    @game_saved
 end

  def display_bad_guesses
    puts "Wrong chars [#{@bad_guesses.uniq.join(' ')}]".red
  end

  def update_correct_chars(char)
    @guesses_left -= 1
    secret_word.chars.each_with_index do |secret_letter, index|
      @correct_guesses[index] = char if secret_letter == char
    end
  end

  def update_incorrect_chars(char)
    @guesses_left -= 1
    @bad_guesses << char
  end

  def set_secret_word
    valid_words = File.open(__dir__ + '/../words/valid_words.txt', 'r+')
    valid_words.rewind
    random_line = rand(52_454)
    random_line.times { valid_words.readline } # will read between 0 and 52453 lines
    @secret_word = valid_words.readline.chomp
    print 'secret word set'
  end
end
