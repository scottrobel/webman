require_relative "players"
require 'colorize'
class Game
    attr_reader :player_name
    attr_accessor :game_number, :game_saved
    def initialize(player)
        @player_name = player.name
        @guesses_left = 20
        @bad_guesses = []
        @correct_guesses = {}#key is index of correct guess value is letter of correct guess
        @game_saved = false
        set_secret_word
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
        win? || loss? || game_saved?
    end
    def to_s
        "game ##{game_number} Player Named '#{@player_name}' #{get_hints.join(" ")} wrong letters#{@bad_guesses}"
    end
    def win?
        secret_word == get_hints.join("")
    end
    def loss?
        @guesses_left == 0 && !win?
    end
    private
    def display_guesses_left
        puts "you have #{@guesses_left} guesses left. use them wisley"
    end
    def make_guess(char)
        if(char == "save")
            FileManager.save_game(self)
        elsif(secret_word.include?(char))
            update_correct_chars(char)
            puts "correct"
        else
            update_incorrect_chars(char)
            puts "incorrect"
        end
        puts "you win" if(win?)
    end
    def display_hints
        puts "#{get_hints.join(" ")}".green
    end
    def get_user_input
        puts "enter char"
        guess = gets.chomp.downcase
        valid_letters = ("a".."z").to_a - @bad_guesses - @correct_guesses.values
        until(valid_letters.include?(guess) || guess == "save")
            puts "invalid char please try again"
            guess = gets.chomp.downcase 
            print "#{!valid_letters.include?(guess)}  #{!guess == "save"} ".blue
        end
        (guess == "save")? guess : guess.match(/[a-z]/)[0]
    end
     def game_saved?
        @game_saved
    end
    def display_bad_guesses
        puts "Wrong chars [#{@bad_guesses.uniq.join(" ")}]".red
    end
    def get_hints
        hints = ("_" * secret_word.length).chars
        @correct_guesses.each do |index, char|
            hints[index] = char
        end
        hints
    end
    def update_correct_chars(char)
        secret_word.chars.each_with_index do |secret_letter,index|
            if(secret_letter == char)
                @correct_guesses[index] = char
            end
        end
    end
    def update_incorrect_chars(char)
        @bad_guesses << char
    end
    def set_secret_word
        valid_words = File.open(File.expand_path(File.dirname(__FILE__)) + '/../words/valid_words.txt', 'r+')
        valid_words.rewind
        random_line = rand(52454)
        random_line.times{valid_words.readline}#will read between 0 and 52453 lines
        @secret_word = valid_words.readline.chomp
        print "secret word set"
    end
    def secret_word
        @secret_word
    end
end