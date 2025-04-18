import pytest
from unittest.mock import patch
from cat_app.app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.testing = True
    with app.test_client() as client:
        yield client


@patch("cat_app.app.get_cat_image_url")
def test_index_success(mock_get_cat_image_url, client):
    mock_url = "https://example.com/cat.jpg"
    mock_get_cat_image_url.return_value = mock_url

    response = client.get('/')
    assert response.status_code == 200
    assert b"Random Cat Photo" in response.data
    assert bytes(mock_url, "utf-8") in response.data
    assert b"<img" in response.data


@patch("cat_app.app.get_cat_image_url")
def test_index_failure(mock_get_cat_image_url, client):
    mock_get_cat_image_url.return_value = None

    response = client.get('/')
    assert response.status_code == 200
    assert b"Could not load cat image" in response.data
    assert b"<img" not in response.data
