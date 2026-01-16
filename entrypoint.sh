#!/bin/bash
set -e

if [ -z "$S3_BUCKET" ]; then
    echo "ERROR: S3_BUCKET environment variable is required"
    exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "ERROR: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required"
    exit 1
fi

MOUNT_CMD="mount-s3"

if [ -n "$AWS_ENDPOINT_URL" ]; then
    MOUNT_CMD="$MOUNT_CMD --endpoint-url $AWS_ENDPOINT_URL"
fi

if [ -n "$AWS_REGION" ]; then
    MOUNT_CMD="$MOUNT_CMD --region $AWS_REGION"
fi

MOUNT_CMD="$MOUNT_CMD $S3_BUCKET /mnt/s3 --allow-other --allow-delete --allow-overwrite"

if [ -n "$AWS_ENDPOINT_URL" ]; then
    MOUNT_CMD="$MOUNT_CMD --force-path-style"
fi

echo "Mounting S3 bucket: $S3_BUCKET"
$MOUNT_CMD --foreground &

sleep 5

if ! mountpoint -q /mnt/s3; then
    echo "ERROR: Failed to mount S3 bucket"
    exit 1
fi

echo "S3 bucket mounted at /mnt/s3"

echo "Starting Samba..."
exec smbd --foreground --no-process-group
