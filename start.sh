#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Text Prediction- Quick Start${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if running from correct directory
if [ ! -d "text_completation" ] || [ ! -d "backend" ]; then
    echo -e "${RED}Error: Please run this script from /home/satam/facial${NC}"
    exit 1
fi

# Start Backend
echo -e "${YELLOW}Starting Backend Server...${NC}"
cd backend

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 not found!${NC}"
    exit 1
fi

# Install requirements if not already installed
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Installing Python dependencies...${NC}"
    pip install -r requirements.txt > /dev/null 2>&1
fi

# Run Flask in background
python3 app.py &
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
echo -e "${GREEN}  URL: http://localhost:5000${NC}\n"

# Wait a moment for backend to start
sleep 2

# Start Frontend
echo -e "${YELLOW}Starting Frontend Server...${NC}"
cd ../text_completation

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm not found! Please install Node.js${NC}"
    kill $BACKEND_PID
    exit 1
fi

# Install dependencies if not already installed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing Node dependencies...${NC}"
    npm install > /dev/null 2>&1
fi

# Run Vite in background
npm run dev &
FRONTEND_PID=$!
echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
echo -e "${GREEN}  URL: http://localhost:5173${NC}\n"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Both servers are running!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "\n${YELLOW}Backend:${NC}  http://localhost:5000"
echo -e "${YELLOW}Frontend:${NC} http://localhost:5173\n"
echo -e "${YELLOW}Press Ctrl+C to stop both servers${NC}\n"

# Trap Ctrl+C to stop both processes
trap "
    echo -e '\n${YELLOW}Stopping servers...${NC}'
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    echo -e '${GREEN}✓ Servers stopped${NC}'
    exit 0
" SIGINT

# Wait for both processes
wait
