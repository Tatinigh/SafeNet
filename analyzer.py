import os
from dotenv import load_dotenv
from google import genai
from google.genai import types
from pydantic import BaseModel, Field

# 1. Load your API key from your local .env file
load_dotenv()

# 2. Initialize the free Google Gemini client
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

# 3. Define the exact JSON layout your frontend needs
class SafeNetResponse(BaseModel):
    risk_score: int = Field(description="A score from 0 to 100 representing scam probability")
    reasons: list[str] = Field(description="Educational points explaining why it looks like a scam")
    recommendations: list[str] = Field(description="Actionable next steps for the user")

def analyze_content(user_input: str) -> dict:
    system_instruction = (
        "You are the core engine of SafeNet AI, an expert digital safety guardian. "
        "Analyze the user-submitted content for scams, phishing, or fraud. "
        "Evaluate it for threatening language, unrealistic promises, or fake links."
    )
    
    try:
        # Call Gemini and force it to respond strictly in our JSON format
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=user_input,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json",
                response_schema=SafeNetResponse,
            ),
        )
        
        # Return the clean JSON string text as a dictionary
        import json
        return json.loads(response.text)

    except Exception as e:
        return {
            "risk_score": 0,
            "reasons": [f"Error during AI analysis: {str(e)}"],
            "recommendations": ["Please try again shortly."]
        }

# --- Quick Test Loop ---
if __name__ == "__main__":
    test_text = "Congratulations! You have been selected by Google. Pay ₹500 for document verification."
    print("Testing SafeNet AI Engine...")
    result = analyze_content(test_text)
    print(result)