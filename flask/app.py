from flask import Flask
import firebase_admin
from firebase_admin import credentials, firestore
import threading
import time

app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("./serviceAccountKey.json")  # Path to your service account key
firebase_admin.initialize_app(cred)

# Initialize Firestore client
db = firestore.client()

# Function to query Firestore
def query_firestore():
    users_ref = db.collection('users')  # Replace 'users' with your Firestore collection
    docs = users_ref.stream()
    
    for doc in docs:
        print(f'{doc.id} => {doc.to_dict()}')

# Function to query Firestore every 5 seconds
def periodic_firestore_query():
    while True:
        query_firestore()
        time.sleep(5)

# Flask route for the homepage
@app.route('/')
def home():
    return "Flask server with Firestore is running."

# Start a separate thread for periodic Firestore queries
def start_periodic_task():
    query_thread = threading.Thread(target=periodic_firestore_query)
    query_thread.daemon = True
    query_thread.start()

if __name__ == '__main__':
    # Start periodic Firestore querying in a separate thread
    start_periodic_task()

    # Run the Flask app
    app.run(host='0.0.0.0', port=3000)