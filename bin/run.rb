#!/usr/bin/env ruby

require("./lib/submission_tagger")

event = JSON.parse(ARGV[0])
response = LinesOfCodeCounter.process(event: event, context: {})
puts response.to_json
