#!/usr/bin/env bash

# Synopsis:
# Run the submission tagger on a submission.

# Arguments:
# $1: path to submission directory
# $2: path to output directory (optional)

# Output:
# Tag the submission in the passed-in submission directory.
# If the output directory is specified, also write the response to that directory.

# Example:
# ./bin/run.sh path/to/submission/directory/

# If any required arguments is missing, print the usage and exit
if [[ $# -lt 1 ]]; then
    echo "usage: ./bin/run.sh path/to/submission/directory/ [path/to/output/directory/]"
    exit 1
fi

submission_dir=$(realpath "${1%/}")
submission_uuid=$(basename "${submission_dir}")
submission_filepaths=$(find ${submission_dir} -type f ! -name *response.json -printf "%P\n" | xargs)
submission_parent_dir=$(realpath ${submission_dir}/..)

if [ ! -z "${2}" ]; then
    output_dir=$(realpath "${2%/}")
fi

echo "${submission_uuid}: tagging submission..."

# Call the function with the correct JSON event payload
body_json=$(jq -n --arg u "${submission_uuid}" --arg f "${submission_filepaths}" --arg o "${output_dir}" '{submission_uuid: $u, submission_filepaths: ($f | split(" ")), output_dir: (if $o == "" then null else $o end)}')
event_json=$(jq -n --arg b "${body_json}" '{body: $b}')
EFS_DIR="${submission_parent_dir}" ruby "./bin/run.rb" "${event_json}"

echo "${submission_uuid}: done"
