# BrowserDataParser

Execute parser as a ruby shell script: ```bin/parse_file```

Execute parser programmatically: 

```rb
require_relative "lib/browser_data_parser"

BrowserDataParser::ParseFile.new.call(
    input_file_path: 'data_large.txt',
    output_file_path: 'data_large_report.json',
    pretty: true
)
```

To run parser's test suite:

`bundle install`\
`rspec`
