class Submission
  include Mandate

  initialize_with :uuid, :filepaths

  def efs_filepaths
    filepaths.map {|filepath| "#{efs_dir}/#{filepath}" }
  end

  def efs_dir
    "#{efs_submissions_dir}/#{uuid}"
  end

  def efs_submissions_dir
    # TODO: get this from the config gem
    ENV.fetch("EFS_DIR", "/mnt/submissions")
  end
end
