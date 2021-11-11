require 'json'
require_relative 'report_builder'
require_relative 'user'
require_relative 'session'

module BrowserDataParser
  class ParseFile
    def call(input_file_path:, output_file_path:, pretty: false)
      report_builder = ReportBuilder.new

      File.open(input_file_path).each_line do |line|
        if line.start_with?('user')
          report_builder.current_user = User.new(line)
        elsif line.start_with?('session')
          report_builder.add_session(Session.new(line))
        end
      end

      File.open(output_file_path, 'w') do |file|
        report = report_builder.finalize_report
        file.write(pretty ? JSON.pretty_generate(report) : JSON.generate(report))
        file.write("\n")
      end
    end
  end
end
