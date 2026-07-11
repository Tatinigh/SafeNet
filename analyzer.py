import os
import json
from dotenv import load_dotenv
from google import genai
from google.genai import types
from pydantic import BaseModel, Field
from PIL import Image

# Load environment variables from local .env file
load_dotenv()

# Initialize the Gemini Client using the free-tier API key
# Ensure GEMINI_API_KEY is defined in your local .env file
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

class SafeNetResponse(BaseModel):
    """
    Defines the exact structured JSON output required by the SafeNet frontend.
    Enforces Strict data types to ensure reliable parsing in the backend route.
    """
    risk_score: int = Field(
        description="A risk probability score between 0 (completely safe) and 100 (confirmed scam)."
    )
    reasons: list[str] = Field(
        description="A list of specific, educational reasons explaining the identified safety anomalies or red flags."
    )
    recommendations: list[str] = Field(
        description="A list of clear, actionable, non-technical immediate next steps for the user."
    )

def analyze_content(text_input: str = "", image_path: str = None) -> dict:
    """
    Core engine for SafeNet AI. Processes user text, URLs, or image screenshots 
    to classify potential cyber fraud and provide explainable risk metrics.
    
    Args:
        text_input (str): The text content, email body, message, or website URL to analyze.
        image_path (str): The local file path to a screenshot, QR code, or advertisement image.
        
    Returns:
        dict: A parsed dictionary containing risk_score, reasons, and recommendations.
    """
    # System instructions matching the operational vision and scope of SafeNet AI
    system_instruction = (
        "You are the core intelligence engine of SafeNet AI, an expert digital safety guardian. "
        "Your role is to act as a real-time 'second opinion' to protect users from cyber fraud. "
        "Analyze the provided text contents, URLs, or embedded image elements for standard vector indicators of fraud. "
        "Check for standard scam patterns including: fake UPI payment requests, fraudulent QR codes, "
        "phishing emails, artificial urgency/threats, requests for passwords/OTPs, malicious domain URLs, "
        "fake corporate branding, unrealistic financial/job promises, or upfront registration fees. "
        "If an image file is provided, act as an native OCR system: extract all visual text, inspect "
        "graphical anomalies, and analyze the content holistically. "
        "Provide an accurate risk score, detailed objective reasons, and concrete preventive actions."
    )
    
    # Construct the multimodal contents payload array
    contents = []
    
    if text_input.strip():
        contents.append(text_input.strip())
        
    if image_path and os.path.exists(image_path):
        try:
            opened_image = Image.open(image_path)
            contents.append(opened_image)
        except Exception as img_err:
            return {
                "risk_score": 0,
                "reasons": [f"System was unable to open the provided image file: {str(img_err)}"],
                "recommendations": ["Verify the screenshot file format and try uploading again."]
            }
            
    # Fallback to prevent execution of an empty request context
    if not contents:
        return {
            "risk_score": 0,
            "reasons": ["No content parameters were provided for evaluation."],
            "recommendations": ["Please supply text, a URL link, or upload an image asset to analyze."]
        }

    try:
        # Request generation using structured schema validation rules
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=contents,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json",
                response_schema=SafeNetResponse,
            ),
        )
        
        # Safely parse string response content into standard dictionary object
        return json.loads(response.text)

    except Exception as api_err:
        return {
            "risk_score": 0,
            "reasons": [f"Critical API pipeline execution failure: {str(api_err)}"],
            "recommendations": ["The evaluation service is temporarily unavailable. Please retry shortly."]
        }

# --- Standalone Terminal Verification Environment ---
if __name__ == "__main__":
    print("=" * 60)
    print("Running SafeNet AI Engine Verification Suite...")
    print("=" * 60)
    
    # Execution Test Scenario A: Text-Based Job Phishing
    sample_text = "Congratulations! You have been selected by Google. Pay ₹500 for document verification."
    print("\n[Executing Test Case A: Phishing Job Text Request]")
    text_result = analyze_content(text_input=sample_text)
    print(json.dumps(text_result, indent=4))
    
    # Execution Test Scenario B: Urgent Account Verification URL Link
    sample_url = "URGENT: Your HDFC bank account is frozen due to missing KYC updates. Log in now to restore access: http://hdfc-security-update-login.net"
    print("\n[Executing Test Case B: Fake Bank Security Text & Link]")
    url_result = analyze_content(text_input=sample_url)
    print(json.dumps(url_result, indent=4))
    
    print("\n" + "=" * 60)
    print("Verification execution completed. Integration ready.")
    print("=" * 60)