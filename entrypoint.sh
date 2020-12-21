#!/bin/sh

set -e

if [ -z "$DISTRIBUTION_ID" ]; then
  echo "DISTRIBUTION_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION is not set. Quitting."
  exit 1
fi

# Create a dedicated profile for this action to avoid
# conflicts with other actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile cloudfront-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Use our dedicated profile and suppress verbose messages.
# All other flags are optional via `args:` directive.
sh -c "aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} \
          --paths '${SOURCE_PATH}' \
          --profile cloudfront-action $*"
          
# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile cloudfront-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
