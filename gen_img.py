import base64
import os

transparent_png = b'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='

with open(os.path.join('assets', 'transparent.png'), 'wb') as f:
    f.write(base64.b64decode(transparent_png))
