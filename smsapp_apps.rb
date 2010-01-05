
class HelloWorld < Smsapp
  def incoming(longcode, keyword, phone, message, timestamp)
    Smsapp::App_Logger.info "message = #{message}"
    send_message(phone, "hello world!, message = #{message}")
  end
end

class PnrAlert < Smsapp
  def incoming(longcode, keyword, phone, message, timestamp)
    v = fetch_kvpair("notice",phone)
    if v
      send_message(phone, "Your notice was: #{v}")
    else
      store_kvpair("notice",message,phone)
      send_message(phone, "Thank you")
    end
  end
end

class SudokuPuzzle
  def initialize(difficulty)
    @diff = difficulty
    @puzzle = "This is a #{@diff} difficulty puzzle"
  end

  def to_s
    @puzzle
  end

  def self.from_s(puzzle_string)
    diff = puzzle_string.scan(/This is a (\w+) difficulty puzzle/)[0][0]
    SudokuPuzzle.new(diff)
  end

  def solve
    "This is the solution of the #{@diff} puzzle"
  end
end

class Sudoku < Smsapp
  def incoming(longcode, keyword, phone, message, timestamp)
    command = message.split(' ')[0].upcase
    if command == 'SOLVE'
      prev_puzzle = fetch_kvpair("previous_puzzle",phone)
      if prev_puzzle.nil?
        send_message(phone, "You have not requested a puzzle yet. Try '#{keyword} EASY' to generate a puzzle")
      else
        puzz = SudokuPuzzle.from_s(prev_puzzle)
        send_message(phone, puzz.solve.to_s)
      end
    else
      difficulty = command
      sud = SudokuPuzzle.new(difficulty)
      send_message(phone, sud.to_s)
      store_kvpair("previous_puzzle", sud.to_s, phone)
    end
  end
end

class PollSetup < Smsapp
  def incoming(longcode, keyword, phone, message, timestamp)
    if keyword == 'POLL'
      #creating a new poll
      words = message.split(' ')
      poll_name = words.slice!(0)
      poll_expiry = words.slice!(0).to_i
      #words is now the array of poll options
    elsif keyword == 'VOTE'
    end
  end
end

class AuctionSetup < Smsapp
  def incoming(longcode, keyword, phone, message, timestamp)
    if keyword == 'AUCTION'
    elsif keyword == 'BID'
    end
  end
end

