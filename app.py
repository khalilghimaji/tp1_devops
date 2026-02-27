import os
import socket
import redis
from flask import Flask

app = Flask(__name__)

# Connect to Redis using the service name defined in docker-compose
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'db-service'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    decode_responses=True
)

@app.route('/')
def index():
    # Increment the hits counter
    hits = redis_client.incr('hits')
    # Get the container hostname (acts as container ID)
    container_id = socket.gethostname()
    return f"""
    <html>
      <body style="font-family: Arial; text-align: center; margin-top: 100px;">
        <h1>🚀 Visit Counter</h1>
        <p>Bonjour ! Cette page a été vue <strong>{hits}</strong> fois.</p>
        <p>Je suis le conteneur <strong>{container_id}</strong>.</p>
      </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)