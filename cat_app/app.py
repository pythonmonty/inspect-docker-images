from flask import Flask, render_template_string
from random_cat_generator.cat import get_cat_image_url

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Random Cat Photo</title>
</head>
<body>
    <h1>Random Cat Photo</h1>
    {% if image_url %}
      <img src="{{ image_url }}" alt="Cat Image" style="max-width: 100%; height: auto;">
    {% else %}
      <p>Could not load cat image. Please try again.</p>
    {% endif %}
    <br>
    <button onclick="window.location.reload();">Refresh</button>
</body>
</html>
"""


def create_app():
    app = Flask(__name__)

    @app.route('/')
    def index():
        image_url = get_cat_image_url()
        return render_template_string(HTML_TEMPLATE, image_url=image_url)

    return app


if __name__ == "__main__":
    create_app().run(host="0.0.0.0", port=3000)
