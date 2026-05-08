import os
import uuid
import json
from datetime import datetime
from flask import Flask, request, jsonify, render_template, redirect, url_for
from werkzeug.utils import secure_filename
from services.image_processing import process_image
from services.model_service import predict_disease, get_dashboard_metrics

app = Flask(__name__)

# Configuration
UPLOAD_FOLDER = os.path.join('static', 'uploads')
HISTORY_FILE = os.path.join('static', 'scan_history.json')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16 MB max

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def load_history():
    if os.path.exists(HISTORY_FILE):
        try:
            with open(HISTORY_FILE, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return []
    return []

def save_scan_to_history(record):
    history = load_history()
    history.insert(0, record)  # newest first
    history = history[:100]    # keep last 100 scans
    with open(HISTORY_FILE, 'w') as f:
        json.dump(history, f, indent=2)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4().hex}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(filepath)

        # Pre-process image
        try:
            processed_info = process_image(filepath)
            
            # Predict using model (or mock fallback)
            prediction = predict_disease(filepath)
            
            result = {
                'success': True,
                'image_url': f'/static/uploads/{unique_filename}',
                'disease': prediction['disease'],
                'confidence': prediction['confidence'],
                'confidence_value': prediction['confidence_value'],
                'symptoms': prediction['symptoms'],
                'severity': prediction['severity'],
                'treatments': prediction['treatments'],
                'prevention': prediction['prevention'],
                'processing_info': processed_info
            }

            # Save scan to history log
            save_scan_to_history({
                'id': unique_filename.split('_')[0],
                'timestamp': datetime.now().isoformat(),
                'disease': prediction['disease'],
                'confidence': prediction['confidence'],
                'severity': prediction['severity'],
                'image_url': f'/static/uploads/{unique_filename}'
            })

            return jsonify(result), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        return jsonify({'error': 'Invalid file type'}), 400

@app.route('/api/metrics', methods=['GET'])
def metrics():
    data = get_dashboard_metrics()
    # Inject real scan count from history
    history = load_history()
    data['total_scans'] = len(history) if history else data['total_scans']
    return jsonify(data)

@app.route('/api/history', methods=['GET'])
def history():
    return jsonify(load_history())

@app.errorhandler(404)
def not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(e):
    return render_template('500.html'), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
