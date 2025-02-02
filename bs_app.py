from flask import Flask
import firebase_admin
from firebase_admin import credentials, firestore, messaging
import threading
import time
import subprocess

app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("./local-note-ac0e7-firebase-adminsdk-n5sit-c580008cbb.json")  # Path to your service account key
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
        # subprocess.run(["xcrun", "simctl", "push", "booted", "com.mhacks.localnote2", "pushes/pushes1.json"]) 
        time.sleep(30)

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
    # start_periodic_task()

    # subprocess.run(["xcrun", "simctl", "push", "booted", "com.mhacks.localNote2", "pushes/pushes1.json"]) 

    def listener(col_snapshot, changes, read_time):
        subprocess.run(["xcrun", "simctl", "push", "booted", "com.mhacks.localNote2", "pushes/pushes1.json"]) 

    db.collection('notes').on_snapshot(listener)


    # Run the Flask app
    app.run(host='0.0.0.0', port=3000)