from flask import Flask, render_template, request, jsonify
from prometheus_flask_exporter import PrometheusMetrics
import os

app = Flask(__name__)
metrics =  PrometheusMetrics(app)

DATA_FILE = "data.txt"

@app.route("/")
def home():
    return render_template("index.html")

@app.post("/submit")
def submit():
    user_text = request.form.get("user_text", "")

    # save to file
    with open(DATA_FILE, "a") as f:
        f.write(user_text + "\n")

    return jsonify({"message": "Saved!", "text": user_text})

@app.get("/data")
def get_data():
    if not os.path.exists(DATA_FILE):
        return jsonify([])

    with open(DATA_FILE, "r") as f:
        lines = [line.strip() for line in f.readlines()]

    return jsonify(lines)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
