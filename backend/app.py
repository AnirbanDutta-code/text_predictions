from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import pickle
import os
from pathlib import Path
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences

app = Flask(__name__)
CORS(app)

# Get the base directory
BASE_DIR = Path(__file__).resolve().parent

# Load model and tokenizer
try:
    # Try to load from environment variable first, then fall back to local paths
    model_path = os.getenv('MODEL_PATH', str(BASE_DIR.parent / "model" / "lstm_model.h5"))
    lstm_model = load_model(model_path)
    print(f"✓ Model loaded from {model_path}")
except Exception as e:
    print(f"✗ Error loading model: {e}")
    lstm_model = None

try:
    tokenizer_path = os.getenv('TOKENIZER_PATH', str(BASE_DIR.parent / "model" / "Tokenizer.pkl"))
    with open(tokenizer_path, 'rb') as file:
        tokenizer = pickle.load(file)
    print(f"✓ Tokenizer loaded from {tokenizer_path}")
except Exception as e:
    print(f"✗ Error loading tokenizer: {e}")
    tokenizer = None

# Configuration
MAX_LEN = 745

# Create index to word mapping
if tokenizer:
    index_to_word = {index: word for word, index in tokenizer.word_index.items()}
else:
    index_to_word = {}

def predict_next_word(model, text, tokenizer, max_len):
    """Predict the next word based on input text"""
    try:
        texts = text.lower()
        seq1 = tokenizer.texts_to_sequences([texts])[0]
        seq = pad_sequences([seq1], maxlen=max_len, padding='pre')
        
        predict = model.predict(seq, verbose=0)
        predict_index = np.argmax(predict)
        
        next_word = index_to_word.get(predict_index, "")
        return next_word
    except Exception as e:
        print(f"Error in predict_next_word: {e}")
        return ""

def generate_text(model, tokenizer, seed_text, max_len, n_words):
    """Generate text by predicting words sequentially"""
    try:
        current_text = seed_text
        for _ in range(n_words):
            next_word = predict_next_word(model, current_text, tokenizer, max_len)
            if next_word == "":
                break
            current_text += " " + next_word
        return current_text
    except Exception as e:
        print(f"Error in generate_text: {e}")
        return seed_text

@app.route('/generate', methods=['POST'])
def generate():
    """API endpoint to generate text"""
    if not lstm_model or not tokenizer:
        return jsonify({
            'error': 'Model or tokenizer not loaded',
            'generated_text': ''
        }), 500
    
    try:
        data = request.get_json()
        seed_text = data.get('seed_text', '')
        n_words = data.get('n_words', 10)
        
        # Validate input
        if not seed_text or not isinstance(seed_text, str):
            return jsonify({
                'error': 'Invalid seed_text',
                'generated_text': ''
            }), 400
        
        # Generate text
        generated_text = generate_text(lstm_model, tokenizer, seed_text, MAX_LEN, int(n_words))
        
        return jsonify({
            'success': True,
            'generated_text': generated_text,
            'seed_text': seed_text,
            'words_generated': int(n_words)
        }), 200
        
    except Exception as e:
        print(f"Error in /generate endpoint: {e}")
        return jsonify({
            'error': str(e),
            'generated_text': ''
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'model_loaded': lstm_model is not None,
        'tokenizer_loaded': tokenizer is not None
    }), 200

@app.route('/', methods=['GET'])
def index():
    """Root endpoint"""
    return jsonify({
        'message': 'Text Generation API',
        'version': '1.0',
        'endpoints': {
            'POST /generate': 'Generate text from seed text',
            'GET /health': 'Health check'
        }
    }), 200

if __name__ == '__main__':
    print("\n" + "="*50)
    print("Text Generation API Server")
    print("="*50)
    port = int(os.getenv('PORT', 5000))
    print(f"Server starting on http://0.0.0.0:{port}")
    print("Endpoints:")
    print("  - POST /generate (seed_text, n_words)")
    print("  - GET /health")
    print("="*50 + "\n")
    
    # Don't use debug=True in production
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(debug=debug_mode, host='0.0.0.0', port=port)
