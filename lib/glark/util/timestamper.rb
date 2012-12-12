#!/usr/bin/ruby -w
# -*- ruby -*-

module TimeStamper
  def stamp msg = self
    @start ||= Time.new
    duration = Time.new - @start
    printf "%10.6f %-20s %s\n", duration, self.class.to_s, msg.to_s
  end

  def interval msg = self
    @last ||= @start
    last = @last || Time.new
    @last = Time.new
    duration = @last - last
    printf "%10.6f %-20s %s\n", duration, self.class.to_s, msg.to_s
  end
end
