require "json"
require "mandate"
require "fileutils"
require "./lib/submission_tagger/generate_tags"
require "./lib/submission_tagger/process_request"
require "./lib/submission_tagger/submission"

module SubmissionTagger
  def self.process(event:, context:)
    ProcessRequest.(event, context)
  end
end
