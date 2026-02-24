"""Gemini API service for 5W1H analysis with grounding and URL context."""
import os
import json
import re
from typing import Optional, Dict, Any
from google import genai
from google.genai import types
from models import ComplexityLevel, FiveWOneH


class GeminiService:
    """Service for interacting with Gemini API with grounding and URL context."""

    MODEL_ID = "gemini-2.5-flash"

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY environment variable is required")

        self.client = genai.Client(api_key=self.api_key)

    def _build_system_instruction(self, profession: str) -> str:
        """Build system instruction with profession context."""
        return f"""<role>
You are an expert research assistant that explains topics using the 5W1H framework (What, Why, Who, Where, When, How).
Your explanations must adapt to the user's profession ({profession}) and the complexity of the topic.
</role>

<instructions>
1. First, analyze the topic and determine its complexity level (Basic, Intermediate, or Advanced).
2. Structure your response using the 5W1H framework with clear headings.
3. Adapt the depth, terminology, and examples to suit a {profession}'s perspective.
4. Use grounded, up-to-date information from your search results.
5. Be concise for simple topics and more detailed for complex topics.
6. Maintain professional tone appropriate for the user's background.
</instructions>

<output_format>
You MUST respond with a valid JSON object in exactly this format:
{{
    "complexity": "Basic|Intermediate|Advanced",
    "answers": {{
        "what": "Clear definition and description of the topic",
        "why": "Reasons, motivations, and significance",
        "who": "Key people, organizations, or entities involved",
        "where": "Locations, contexts, and scope",
        "when": "Timeline, history, and temporal aspects",
        "how": "Methods, processes, and implementation details"
    }}
}}
</output_format>

<constraints>
- Respond ONLY with valid JSON, no markdown formatting or code blocks
- Each field should contain substantive information (at least 2-3 sentences)
- Use terminology appropriate for a {profession}
- Include specific, factual information from search results when available
</constraints>"""

    def _build_user_prompt(self, topic: str) -> str:
        """Build user prompt with topic."""
        return f"""<context>
The user wants to understand the following topic using the 5W1H framework.
</context>

<task>
Analyze this topic: {topic}

Provide a comprehensive 5W1H analysis with:
1. First determine the complexity level
2. Answer What, Why, Who, Where, When, and How
3. Use grounded information from search results
4. Adapt language and depth to the profession

Return ONLY valid JSON.
</task>"""

    def _parse_response(self, response_text: str) -> Dict[str, Any]:
        """Parse the Gemini response into structured data."""
        # Clean up the response - remove any markdown formatting
        cleaned = response_text.strip()

        # Remove markdown code blocks if present
        if cleaned.startswith("```"):
            cleaned = re.sub(r'^```(?:json)?\s*', '', cleaned)
            cleaned = re.sub(r'\s*```$', '', cleaned)

        try:
            data = json.loads(cleaned)
            return data
        except json.JSONDecodeError:
            # Try to extract JSON from the response
            json_match = re.search(r'\{[\s\S]*\}', cleaned)
            if json_match:
                try:
                    return json.loads(json_match.group())
                except json.JSONDecodeError:
                    pass

            # Return default structure if parsing fails
            return {
                "complexity": "Intermediate",
                "answers": {
                    "what": cleaned,
                    "why": "Information not available in structured format",
                    "who": "Please try again with a more specific topic",
                    "where": "N/A",
                    "when": "N/A",
                    "how": "N/A"
                }
            }

    async def analyze_topic(self, profession: str, topic: str) -> Dict[str, Any]:
        """
        Analyze a topic using 5W1H framework with Google Search grounding.

        Args:
            profession: User's profession for context-aware responses
            topic: Topic to analyze

        Returns:
            Dictionary containing complexity and 5W1H answers
        """
        # Configure tools: Google Search for grounding
        grounding_tool = types.Tool(
            google_search=types.GoogleSearch()
        )

        # Build configuration
        config = types.GenerateContentConfig(
            tools=[grounding_tool],
            system_instruction=self._build_system_instruction(profession),
            temperature=1.0,  # Default for Gemini 2.5
            max_output_tokens=4096,
        )

        # Generate content
        response = self.client.models.generate_content(
            model=self.MODEL_ID,
            contents=self._build_user_prompt(topic),
            config=config,
        )

        # Parse response
        parsed = self._parse_response(response.text)

        # Validate and normalize complexity
        complexity_str = parsed.get("complexity", "Intermediate").upper()
        try:
            parsed["complexity"] = ComplexityLevel[complexity_str]
        except KeyError:
            parsed["complexity"] = ComplexityLevel.INTERMEDIATE

        # Ensure all answer fields exist
        default_answers = {
            "what": "Information not available",
            "why": "Information not available",
            "who": "Information not available",
            "where": "Information not available",
            "when": "Information not available",
            "how": "Information not available"
        }

        answers = parsed.get("answers", {})
        parsed["answers"] = {**default_answers, **answers}

        # Extract grounding metadata if available
        if hasattr(response, 'candidates') and response.candidates:
            candidate = response.candidates[0]
            if hasattr(candidate, 'grounding_metadata') and candidate.grounding_metadata:
                parsed["grounding_metadata"] = {
                    "web_search_queries": getattr(candidate.grounding_metadata, 'web_search_queries', []),
                }

        return parsed


# Global service instance
gemini_service: Optional[GeminiService] = None


def get_gemini_service() -> GeminiService:
    """Get or create Gemini service instance."""
    global gemini_service
    if gemini_service is None:
        gemini_service = GeminiService()
    return gemini_service
