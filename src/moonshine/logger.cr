require "time"

class Moonshine::Logger
  # Default logger class for Moonshine

  def initialize()

  end

  def log(text)
    log_text = Time.now.to_s + " | " + text
    puts log_text
  end
end