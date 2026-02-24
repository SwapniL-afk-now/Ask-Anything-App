# 5W1H Analysis App

A full-stack web application that helps users from different professions analyze any topic using structured **5W1H** (What, Why, Who, Where, When, How) answers, dynamically adapted to topic complexity and professional background.

## Architecture

```
5W/
├── backend/           # Python FastAPI backend
│   ├── main.py        # API server
│   ├── gemini_service.py  # Gemini integration
│   ├── cache_service.py   # Response caching
│   └── models.py      # Data models
│
├── five_w_app/        # Flutter frontend
│   ├── lib/
│   │   ├── screens/   # UI screens
│   │   ├── services/  # API client
│   │   ├── providers/ # State management
│   │   └── models/    # Data models
│   └── assets/
│
├── docs/              # API documentation
└── frontend/          # UI reference designs
```

## Quick Start

### Prerequisites

- Python 3.11+
- Flutter SDK 3.4+
- Gemini API key

### 1. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

# Run server
python main.py
```

### 2. Frontend Setup

```bash
cd five_w_app

# Install dependencies
flutter pub get

# Run app
flutter run
```

### 3. Access the App

- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Flutter App: Run on your preferred device

## Features

### Frontend
- **Profession Selection**: Choose from 20+ professions across categories
- **Topic Input**: Search or describe any topic
- **Results Display**: Clean 5W1H breakdown with complexity indicators
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Smooth Animations**: Modern UI with flutter_animate

### Backend
- **Gemini 2.5 Flash**: Latest Gemini model for accurate analysis
- **Google Search Grounding**: Real-time, fact-checked information
- **Profession Adaptation**: Responses tailored to professional context
- **Complexity Detection**: Automatic Basic/Intermediate/Advanced classification
- **Response Caching**: Reduced latency and API costs

## API Reference

### POST /analyze-topic

**Request:**
```json
{
  "profession": "Engineer",
  "topic": "Quantum Computing in cryptography"
}
```

**Response:**
```json
{
  "complexity": "Advanced",
  "answers": {
    "what": "...",
    "why": "...",
    "who": "...",
    "where": "...",
    "when": "...",
    "how": "..."
  },
  "cached": false
}
```

## Configuration

### Backend (.env)
```
GEMINI_API_KEY=your_key_here
CACHE_TTL_SECONDS=3600
```

### Frontend (lib/services/api_service.dart)
```dart
static const String baseUrl = 'http://localhost:8000';
```

## Supported Professions

- **Technology**: Software Engineer, Data Scientist, Product Manager, UX Designer, DevOps Engineer
- **Healthcare**: Doctor, Nurse, Pharmacist
- **Business**: Marketer, Financial Analyst, Entrepreneur, Sales Manager
- **Legal**: Lawyer, Legal Researcher
- **Education**: Student, Teacher, Researcher
- **Creative**: Graphic Designer, Writer, Journalist
- **Engineering**: Civil, Mechanical, Electrical Engineer

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter, Provider, google_fonts |
| Backend | FastAPI, Pydantic, uvicorn |
| AI | Google Gemini 2.5 Flash |
| Grounding | Google Search |
| Caching | aiocache (in-memory) |

## Project Status

Ready for development and testing.

## License

MIT License
