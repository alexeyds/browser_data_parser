module BrowserDataParser
  class Session
    attr_reader :id, :user_id, :duration_minutes, :browser, :date

    def initialize(line)
      data_array = line.split(',')

      @id = data_array[2].to_i
      @user_id = data_array[1].to_i
      @browser = data_array[3].upcase
      @duration_minutes = data_array[4].to_i
      @date = Date.parse(data_array[5])
    end

    def is_ie?
      @browser.include?("INTERNET EXPLORER")
    end

    def is_chrome?
      @browser.include?("CHROME")
    end
  end
end
