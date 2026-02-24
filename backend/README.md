# 5W1H Analysis Backend

FastAPI backend for the 5W1H Analysis application, powered by Google's Gemini API.

## Features

- **Gemini 2.5 Flash Integration**: Latest Gemini model for analysis
- **Google Search Grounding**: Real-time information retrieval
- **Response Caching**: Memory-based caching with TTL
- **Profession-aware Responses**: Context-adapted content
- **Complexity Detection**: Automatic topic complexity assessment

## Setup

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `.env.example` to `.env` and add your Gemini API key:

```bash
cp .env.example .env
```

Edit `.env`:
```
GEMINI_API_KEY=your_actual_gemini_api_key
CACHE_TTL_SECONDS=3600
```

### 3. Get a Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Click "Get API Key" in the left sidebar
4. Create a new API key or copy an existing one
5. Add the key to your `.env` file

### 4. Run the Server

```bash
# Development mode with auto-reload
python main.py

# Or using uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## API Documentation

Once the server is running, access the interactive documentation at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Endpoints

#### POST /analyze-topic

Analyze a topic using the 5W1H framework.

**Request Body:**
```json
{
  "profession": "Software Engineer",
  "topic": "Quantum Computing in cryptography"
}
```

**Response:**
```json
{
  "complexity": "Advanced",
  "answers": {
    "what": "Definition and description...",
    "why": "Reasons and motivations...",
    "who": "Key entities involved...",
    "where": "Locations and contexts...",
    "when": "Timeline and history...",
    "how": "Methods and processes..."
  },
  "cached": false
}
```

#### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

#### DELETE /cache

Clear all cached results.

## Architecture

```
backend/
├── main.py           # FastAPI application and routes
├── models.py         # Pydantic data models
├── gemini_service.py # Gemini API integration
├── cache_service.py  # Response caching
├── requirements.txt  # Python dependencies
├── .env.example      # Environment template
└── README.md         # This file
```

### Key Components

#### Gemini Service (`gemini_service.py`)
- Manages Gemini API connection
- Builds dynamic prompts with profession context
- Enables Google Search grounding for real-time info
- Parses and structures responses

#### Cache Service (`cache_service.py`)
- In-memory caching using aiocache
- SHA256-based cache key generation
- Configurable TTL (default: 1 hour)
- Reduces API calls and latency

#### Models (`models.py`)
- Request/response Pydantic models
- Complexity level enumeration
- Input validation

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| GEMINI_API_KEY | Google Gemini API key | Required |
| CACHE_TTL_SECONDS | Cache time-to-live | 3600 |

## Production Deployment

### Using Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t 5w1h-backend .
docker run -p 8000:8000 --env-file .env 5w1h-backend
```

### Using Gunicorn

```bash
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000
```

## Error Handling

The API returns structured error responses:

```json
{
  "error": "Error type",
  "detail": "Detailed error message"
}
```

Common status codes:
- 400: Invalid request (empty fields, validation errors)
- 500: Server error (API failures, unexpected errors)
- 503: Service unavailable (Gemini API issues)

## License

MIT License
