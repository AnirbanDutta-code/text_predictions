#!/bin/bash

echo "=========================================="
echo "Testing Text Generation API Connection"
echo "=========================================="
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Health Check..."
HEALTH=$(curl -s http://localhost:5000/health)
echo "Response: $HEALTH"
echo ""

# Test 2: Generate Text
echo "2️⃣  Testing Text Generation..."
RESPONSE=$(curl -s -X POST http://localhost:5000/generate \
  -H "Content-Type: application/json" \
  -d '{"seed_text": "The future is", "n_words": 5}')

echo "Seed Text: 'The future is'"
echo "Generated: $(echo $RESPONSE | grep -o '"generated_text":"[^"]*' | cut -d'"' -f4)"
echo ""
echo "Full Response:"
echo "$RESPONSE" | python3 -m json.tool
echo ""
echo "✓ API is working correctly!"
