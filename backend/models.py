"""Data models for the 5W1H Analysis API."""
from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


class ComplexityLevel(str, Enum):
    BASIC = "Basic"
    INTERMEDIATE = "Intermediate"
    ADVANCED = "Advanced"


class AnalyzeRequest(BaseModel):
    """Request model for topic analysis."""
    profession: str = Field(..., min_length=1, max_length=100,
                           description="User's profession for context-aware responses")
    topic: str = Field(..., min_length=3, max_length=2000,
                      description="Topic or keyword to analyze using 5W1H framework")


class FiveWOneH(BaseModel):
    """Model representing the 5W1H answers."""
    what: str = Field(..., description="What - Definition and description")
    why: str = Field(..., description="Why - Reasons and motivations")
    who: str = Field(..., description="Who - Key people, organizations, or entities involved")
    where: str = Field(..., description="Where - Locations and contexts")
    when: str = Field(..., description="When - Timeline and temporal aspects")
    how: str = Field(..., description="How - Methods, processes, and implementation")


class AnalyzeResponse(BaseModel):
    """Response model for topic analysis."""
    complexity: ComplexityLevel = Field(..., description="Inferred complexity level of the topic")
    answers: FiveWOneH = Field(..., description="5W1H structured answers")
    cached: bool = Field(default=False, description="Whether response was retrieved from cache")


class ErrorResponse(BaseModel):
    """Error response model."""
    error: str
    detail: Optional[str] = None


class HealthResponse(BaseModel):
    """Health check response."""
    status: str
    version: str
