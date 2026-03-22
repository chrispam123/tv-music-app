import json
import boto3
import random
import os
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    """
    Lambda function that returns a presigned URL for a random music file from S3.

    Args:
        event: Lambda event object (unused in this implementation)
        context: Lambda context object (unused in this implementation)

    Returns:
        dict: API Gateway response with status code and presigned URL
    """
    # Get bucket name from environment variable
    bucket_name = os.environ.get("MUSIC_BUCKET_NAME")

    if not bucket_name:
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"error": "MUSIC_BUCKET_NAME environment variable not set"}
            ),
        }

    # Initialize S3 client
    s3_client = boto3.client("s3")

    try:
        # List all objects in the bucket
        response = s3_client.list_objects_v2(Bucket=bucket_name)

        # Check if bucket has any objects
        if "Contents" not in response or len(response["Contents"]) == 0:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "No music files found in bucket"}),
            }

        # Select a random object
        random_object = random.choice(response["Contents"])
        object_key = random_object["Key"]

        # Generate presigned URL (valid for 1 hour)
        presigned_url = s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": bucket_name, "Key": object_key},
            ExpiresIn=3600,
        )

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"url": presigned_url, "filename": object_key}),
        }

    except ClientError as e:
        return {"statusCode": 500, "body": json.dumps({"error": f"S3 error: {str(e)}"})}
