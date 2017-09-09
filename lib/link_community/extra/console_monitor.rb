# frozen_string_literal: true

module LinkCommunity
  class ConsoleMonitor
    attr_reader :counter

    def initialize(message, expected, display_at = 100)
      @message = message
      @expected = expected
      @display_at = display_at
      @last_message_size = 0
      @counter = 0.0
      start
    end

    def total_steps
      @total_steps ||= (@expected * (@expected - 1)) / 2
    end

    def past_steps
      (@counter * (@counter - 1)) / 2
    end

    def start
      @start = Time.now
      puts "start...: #{@expected} records"
      @last_message_size = 0
    end

    def counter_msg
      format("%d records", @counter)
    end

    def elapsed
      Time.now - @start
    end

    def elapsed_msg
      if elapsed < 60
        format("%ds", elapsed)
      else
        format("%0.1fmin", elapsed / 60)
      end
    end

    def rate
      past_steps / elapsed
    end

    def rate_msg
      format("%d steps/s", rate)
    end

    def eta
      (total_steps - past_steps) / rate
    end

    def eta_msg
      if eta < 60
        format("%ds", eta)
      else
        format("%dmin", eta / 60)
      end
    end

    def printf
      @counter += 1

      return unless (@counter % @display_at).zero?
      # print "\b" * @last_message_size

      args = yield(self)

      message = format(@message, *args)
      @last_message_size = message.size
      print message
      STDOUT.flush
    end

    def finish
      puts
    end
  end
end
