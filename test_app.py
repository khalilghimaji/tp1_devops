import pytest
from unittest.mock import patch
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_homepage_returns_200(client):
    with patch('app.redis_client') as mock_redis:
        mock_redis.incr.return_value = 42
        response = client.get('/')
        assert response.status_code == 200

def test_homepage_contains_visit_count(client):
    with patch('app.redis_client') as mock_redis:
        mock_redis.incr.return_value = 7
        response = client.get('/')
        assert b'7' in response.data

def test_redis_incr_called(client):
    with patch('app.redis_client') as mock_redis:
        mock_redis.incr.return_value = 1
        client.get('/')
        mock_redis.incr.assert_called_once_with('hits')