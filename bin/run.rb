#!/usr/bin/env ruby

require("./lib/submission_tagger")

event = JSON.parse(ARGV[0])
response = SubmissionTagger.process(event: event, context: {})
puts response.to_json
