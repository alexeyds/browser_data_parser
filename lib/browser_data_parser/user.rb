module BrowserDataParser
  class User
    attr_reader :id, :first_name, :last_name

    def initialize(line)
      data_array = line.split(',')

      @id = data_array[1].to_i
      @first_name = data_array[2]
      @last_name = data_array[3]
    end

    def full_name
      "#{@first_name} #{@last_name}"
    end
  end
end
