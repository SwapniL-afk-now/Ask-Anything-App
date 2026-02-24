"""Main FastAPI application for 5W1H Analysis API."""
import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from dotenv import load_dotenv

from models import (
    AnalyzeRequest,
    AnalyzeResponse,
    FiveWOneH,
    ErrorResponse,
    HealthResponse,
    ComplexityLevel
)
from cache_service import cache_service
from gemini_service import get_gemini_service

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Application metadata
APP_VERSION = "1.0.0"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    logger.info("Starting 5W1H Analysis API...")
    try:
        # Initialize Gemini service
        get_gemini_service()
        logger.info("Gemini service initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Gemini service: {e}")
        raise
    yield
    # Shutdown
    logger.info("Shutting down 5W1H Analysis API...")


# Create FastAPI app
app = FastAPI(
    title="5W1H Analysis API",
    description="API for analyzing topics using the 5W1H framework with Gemini AI",
    version=APP_VERSION,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve Frontend Static Files
frontend_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "frontend")
if os.path.isdir(frontend_path):
    app.mount("/app", StaticFiles(directory=frontend_path, html=True), name="frontend")


@app.get("/")
async def root():
    """Root endpoint - redirect to frontend app."""
    return RedirectResponse(url="/app/")


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    return HealthResponse(status="healthy", version=APP_VERSION)


@app.post("/analyze-topic", response_model=AnalyzeResponse,
          responses={
              400: {"model": ErrorResponse},
              500: {"model": ErrorResponse},
              503: {"model": ErrorResponse}
          })
async def analyze_topic(request: AnalyzeRequest):
    """
    Analyze a topic using the 5W1H framework.

    This endpoint:
    1. Checks cache for existing analysis
    2. If not cached, calls Gemini API with grounding
    3. Returns structured 5W1H answers adapted to the user's profession
    """
    try:
        # Validate input
        if not request.profession.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Profession cannot be empty"
            )
        if not request.topic.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Topic cannot be empty"
            )

        # Check cache first
        cached_result = await cache_service.get(request.profession, request.topic)
        if cached_result:
            logger.info(f"Cache hit for profession='{request.profession}', topic='{request.topic[:50]}...'")
            return AnalyzeResponse(
                complexity=ComplexityLevel(cached_result["complexity"]),
                answers=FiveWOneH(**cached_result["answers"]),
                cached=True
            )

        # Get Gemini service
        gemini_service = get_gemini_service()

        # Analyze topic
        logger.info(f"Analyzing topic for profession='{request.profession}', topic='{request.topic[:50]}...'")
        result = await gemini_service.analyze_topic(
            profession=request.profession,
            topic=request.topic
        )

        # Cache the result
        await cache_service.set(request.profession, request.topic, result)

        # Return response
        return AnalyzeResponse(
            complexity=result["complexity"],
            answers=FiveWOneH(**result["answers"]),
            cached=False
        )

    except HTTPException:
        raise
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error analyzing topic: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An error occurred while analyzing the topic: {str(e)}"
        )


@app.delete("/cache")
async def clear_cache():
    """Clear all cached analysis results."""
    await cache_service.clear_all()
    return {"message": "Cache cleared successfully"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
