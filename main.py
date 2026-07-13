import os
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
import uvicorn

# Import SafeNet AI engine modules
from analyzer import analyze_content, client
from rag_engine import retrieve_relevant_patterns, format_context_for_prompt

app = FastAPI(
    title="SafeNet AI Backend API",
    description="FastAPI service for real-time scam analysis, RAG, and AI safety assistant chatbot.",
    version="1.0.0"
)

# Enable CORS for Flutter mobile/web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Pydantic Request Models ---

class ChatRequest(BaseModel):
    message: str
    history: List[Dict[str, str]]  # list of {"role": "user"|"assistant", "text": "..."}

class TextAnalysisRequest(BaseModel):
    text: str
    type: str

class UrlAnalysisRequest(BaseModel):
    url: str

class ImageAnalysisRequest(BaseModel):
    image_path: str
    scan_type: str
    extracted_text: str

class QrAnalysisRequest(BaseModel):
    qr_content: str

# --- Fallback Chat Responses for Demo Mode ---

def generate_mock_chat_reply(message: str) -> str:
    lower_message = message.lower()
    if "sbi" in lower_message or "otp" in lower_message or "bank" in lower_message or "frozen" in lower_message:
        return (
            "No, this is highly likely a bank KYC scam. Legitimate banks (like SBI, HDFC, or ICICI) "
            "will never ask you for confidential details like OTPs, card PINs, CVV, or passwords via SMS, "
            "email, or telephone call. If someone is pressuring you with threats of freezing your account, "
            "do not share any details. Block the sender immediately."
        )
    elif "phishing" in lower_message:
        return (
            "Phishing is a deceptive technique where attackers send messages pretending to be trusted organizations "
            "(like banks, Amazon, Google, or courier services). Their main goal is to trick you into clicking "
            "suspicious links or sharing credentials. Always check the sender address and domain name carefully!"
        )
    elif "link" in lower_message or "website" in lower_message or "url" in lower_message:
        return (
            "Before clicking a link, look closely for visual spelling errors (e.g., 'paypa1.com' instead of 'paypal.com'). "
            "Safe sites generally use HTTPS, but scammers can have SSL certificates too. The safest action is to "
            "paste the URL into SafeNet AI's scan tool to analyze the domain age and reputation."
        )
    elif "job" in lower_message or "salary" in lower_message or "part-time" in lower_message or "telegram" in lower_message:
        return (
            "Be extremely careful! Scammers are recruit-phishing using Telegram and WhatsApp. They promise high returns "
            "or salary for doing simple tasks (like rating hotels or liking YouTube videos). Later, they will ask you "
            "for a 'document registration fee' or security deposit. Legitimate companies never charge you to hire you."
        )
    elif "qr" in lower_message or "refund" in lower_message:
        return (
            "Remember: Scanning a QR code or entering a UPI PIN is only for sending money, never for receiving it. "
            "If someone tells you to scan a QR code to receive a refund or lottery prize, they are trying to steal from your account."
        )
    else:
        return (
            "Hello! I am your SafeNet AI digital safety assistant. You can ask me security questions, "
            "paste suspicious SMS messages, ask about job offers, or double check banking rules. "
            "Always remember to think before you click, and never share OTPs or send upfront fees!"
        )

# --- Routes ---

@app.get("/")
def read_root():
    mode = "Live Gemini AI Mode" if client else "Demonstration Mock Mode"
    return {
        "status": "online",
        "service": "SafeNet AI Backend API",
        "running_mode": mode
    }

@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    """
    Handles conversational interactions. Queries RAG engine for context,
    and runs Gemini LLM (or mock fallback if API key is not configured).
    """
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message content cannot be empty.")
        
    if not client:
        # Running in mock fallback mode
        reply = generate_mock_chat_reply(request.message)
        return {"reply": reply}
        
    try:
        from google.genai import types
        
        # 1. Retrieve matching scam patterns from RAG engine with fail-safe keyword fallback
        matches = []
        try:
            matches = retrieve_relevant_patterns(request.message, top_k=3)
        except Exception as rag_err:
            print(f"[SafeNet AI] RAG engine embedding failed: {rag_err}. Falling back to keyword search.")
            try:
                with open("scam_patterns.json", "r", encoding="utf-8") as f:
                    patterns = json.load(f)
                query_words = set(request.message.lower().split())
                scored = []
                for p in patterns:
                    pattern_text = f"{p['category']} {p['pattern']} {p['why_scam']}".lower()
                    match_count = sum(1 for w in query_words if len(w) > 3 and w in pattern_text)
                    if match_count > 0:
                        scored.append({
                            "id": p["id"],
                            "category": p["category"],
                            "pattern": p["pattern"],
                            "why_scam": p["why_scam"],
                            "similarity": round(0.5 + min(0.49, 0.1 * match_count), 3),
                        })
                scored.sort(key=lambda x: x["similarity"], reverse=True)
                matches = scored[:3]
            except Exception as kw_err:
                print(f"[SafeNet AI] Fallback keyword matching failed: {kw_err}")
                matches = []
                
        context_str = format_context_for_prompt(matches)
        
        # 2. Build system instructions incorporating retrieved context
        system_instruction = (
            "You are SafeNet AI, an intelligent, empathetic digital safety assistant. "
            "Your goal is to help users understand online safety, recognize potential scams, "
            "and provide practical, non-technical advice to protect themselves from cyber fraud.\n\n"
            f"{context_str}\n\n"
            "Use the above known scam patterns context to inform your responses when relevant. "
            "If the user asks an unrelated question, reply politely but keep the focus on cybersecurity and online safety. "
            "Keep your responses educational, friendly, and actionable."
        )
        
        # 3. Format history and current message into Gemini contents structure
        contents = []
        for msg in request.history:
            role = "user" if msg.get("role") == "user" else "model"
            contents.append(
                types.Content(
                    role=role,
                    parts=[types.Part.from_text(text=msg.get("text", ""))]
                )
            )
            
        contents.append(
            types.Content(
                role="user",
                parts=[types.Part.from_text(text=request.message)]
            )
        )
        
        # 4. Generate AI response using gemini-flash-latest
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=contents,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
            )
        )
        return {"reply": response.text}
        
    except Exception as err:
        print(f"[SafeNet AI Chat Error] {err}")
        return {"reply": f"Sorry, I encountered an issue generating a response: {str(err)}"}

@app.post("/analyze/text")
def analyze_text_endpoint(request: TextAnalysisRequest):
    """
    Evaluates risk score and generates safety report for submitted text content.
    """
    try:
        report = analyze_content(text_input=request.text)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze/url")
def analyze_url_endpoint(request: UrlAnalysisRequest):
    """
    Evaluates reputation risk score and safety markers for a website URL.
    """
    try:
        report = analyze_content(text_input=request.url)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze/image")
def analyze_image_endpoint(request: ImageAnalysisRequest):
    """
    Runs multimodal scam scan on uploaded screenshot/ad images.
    Uses extracted OCR text as backup.
    """
    try:
        report = analyze_content(text_input=request.extracted_text, image_path=request.image_path)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze/qr")
def analyze_qr_endpoint(request: QrAnalysisRequest):
    """
    Evaluates risk score and safety recommendations for a scanned QR payload.
    """
    try:
        report = analyze_content(text_input=request.qr_content)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
