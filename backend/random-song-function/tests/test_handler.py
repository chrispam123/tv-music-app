import json
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError
from src.handler import lambda_handler


class TestLambdaHandler:
    """Test suite for the Lambda handler function."""

    @patch.dict("os.environ", {"MUSIC_BUCKET_NAME": "test-bucket"})
    @patch("src.handler.boto3.client")
    def test_successful_presigned_url_generation(self, mock_boto_client):
        """Test that handler returns presigned URL for a random file."""
        # Mock S3 client and its responses
        mock_s3 = MagicMock()
        mock_boto_client.return_value = mock_s3

        # Mock list_objects_v2 response
        mock_s3.list_objects_v2.return_value = {
            "Contents": [
                {"Key": "song1.mp3"},
                {"Key": "song2.mp3"},
                {"Key": "song3.mp3"},
            ]
        }

        # Mock generate_presigned_url response
        mock_s3.generate_presigned_url.return_value = (
            "https://presigned-url.example.com"
        )

        # Call the handler
        response = lambda_handler({}, {})

        # Assertions
        assert response["statusCode"] == 200
        assert "body" in response

        body = json.loads(response["body"])
        assert "url" in body
        assert body["url"] == "https://presigned-url.example.com"
        assert "filename" in body
        assert body["filename"] in ["song1.mp3", "song2.mp3", "song3.mp3"]

        # Verify S3 client was called correctly
        mock_s3.list_objects_v2.assert_called_once_with(Bucket="test-bucket")
        mock_s3.generate_presigned_url.assert_called_once()

    @patch.dict("os.environ", {})
    def test_missing_bucket_name_environment_variable(self):
        """Test that handler returns error when MUSIC_BUCKET_NAME is not set."""
        response = lambda_handler({}, {})

        assert response["statusCode"] == 500
        body = json.loads(response["body"])
        assert "error" in body
        assert "MUSIC_BUCKET_NAME" in body["error"]

    @patch.dict("os.environ", {"MUSIC_BUCKET_NAME": "test-bucket"})
    @patch("src.handler.boto3.client")
    def test_empty_bucket(self, mock_boto_client):
        """Test that handler returns 404 when bucket has no files."""
        mock_s3 = MagicMock()
        mock_boto_client.return_value = mock_s3

        # Mock empty bucket response
        mock_s3.list_objects_v2.return_value = {}

        response = lambda_handler({}, {})

        assert response["statusCode"] == 404
        body = json.loads(response["body"])
        assert "error" in body
        assert "No music files found" in body["error"]

    @patch.dict("os.environ", {"MUSIC_BUCKET_NAME": "test-bucket"})
    @patch("src.handler.boto3.client")
    def test_s3_client_error(self, mock_boto_client):
        """Test that handler handles S3 ClientError gracefully."""
        mock_s3 = MagicMock()
        mock_boto_client.return_value = mock_s3

        # Mock S3 client error
        mock_s3.list_objects_v2.side_effect = ClientError(
            {"Error": {"Code": "AccessDenied", "Message": "Access Denied"}},
            "ListObjectsV2",
        )

        response = lambda_handler({}, {})

        assert response["statusCode"] == 500
        body = json.loads(response["body"])
        assert "error" in body
        assert "S3 error" in body["error"]

    @patch.dict("os.environ", {"MUSIC_BUCKET_NAME": "test-bucket"})
    @patch("src.handler.boto3.client")
    def test_cors_headers_present(self, mock_boto_client):
        """Test that response includes CORS headers."""
        mock_s3 = MagicMock()
        mock_boto_client.return_value = mock_s3

        mock_s3.list_objects_v2.return_value = {"Contents": [{"Key": "song1.mp3"}]}
        mock_s3.generate_presigned_url.return_value = (
            "https://presigned-url.example.com"
        )

        response = lambda_handler({}, {})

        assert response["statusCode"] == 200
        assert "headers" in response
        assert response["headers"]["Access-Control-Allow-Origin"] == "*"
        assert response["headers"]["Content-Type"] == "application/json"
