#!/usr/bin/env bash

# Synopsis:
# Run the submission tagger on a submission using the Docker image.

# Arguments:
# $1: path to submission directory
# $2: path to output directory (optional)

# Output:
# Tag the submission in the passed-in submission directory.
# If the output directory is specified, also write the response to that directory.

# Example:
# ./bin/run-in-docker.sh path/to/submission/directory/

# If any required arguments is missing, print the usage and exit
if [[ $# -lt 1 ]]; then
    echo "usage: ./bin/run-in-docker.sh path/to/submission/directory/ [path/to/output/directory/]"
    exit 1
fi

submission_dir=$(realpath "${1%/}")
submission_uuid=$(basename "${submission_dir}")
submission_filepaths=$(find ${submission_dir} -type f ! -name *response.json -printf "%P\n" | xargs)

if [ ! -z "${2}" ]; then
    output_dir=$(realpath "${2%/}")
    output_dir_mount="--mount type=bind,src="${output_dir}",dst=/mnt/output"
fi

container_port=9876

# Build the Docker image, unless SKIP_BUILD is set
if [[ -z "${SKIP_BUILD}" ]]; then
    docker build --rm -t exercism/submission-tagger .
fi

# Run the Docker image using the settings mimicking the production environment
container_id=$(docker run \
    --detach \
    --publish ${container_port}:8080 \
    --mount type=bind,src="${submission_dir}",dst=/mnt/submissions/${submission_uuid} \
    ${output_dir_mount} \
    exercism/submission-tagger)

echo "${submission_uuid}: tagging submission..."

# Call the function with the correct JSON event payload
body_json=$(jq -n --arg u "${submission_uuid}" --arg f "${submission_filepaths}" --arg o "${output_dir}" '{submission_uuid: $u, submission_filepaths: ($f | split(" ")), output_dir: (if $o == "" then null else "/mnt/output" end)}')
event_json=$(jq -n --arg b "${body_json}" '{body: $b}')
curl -XPOST http://localhost:${container_port}/2015-03-31/functions/function/invocations -d "${event_json}"

echo "${submission_uuid}: done"

docker stop $container_id > /dev/null
