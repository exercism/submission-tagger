class Submission
  include Mandate

  initialize_with :uuid, :filepaths

  def efs_filepaths = filepaths.map {|filepath| "#{efs_dir}/#{filepath}" }
  def efs_dir = "#{efs_submissions_dir}/#{uuid}"
  def efs_submissions_dir = ENV.fetch("EFS_DIR", "/mnt/submissions") # TODO: get this from the config gem
end
