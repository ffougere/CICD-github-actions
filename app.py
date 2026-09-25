from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(message="Simple Python app is running")

@app.get("/health")
def health():
    return jsonify(status="ok")
