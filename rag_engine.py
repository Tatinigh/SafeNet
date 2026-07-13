import os
import json
from dotenv import load_dotenv
from google import genai
import numpy as np

load_dotenv()

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

EMBED_MODEL = "gemini-embedding-2"

PATTERNS_PATH = os.path.join(os.path.dirname(__file__), "scam_patterns.json")
CACHE_PATH = os.path.join(os.path.dirname(__file__), "embeddings_cache.json")


def _load_patterns() -> list[dict]:
    with open(PATTERNS_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def _embed_text(text: str) -> list[float]:
    result = client.models.embed_content(
        model=EMBED_MODEL,
        contents=text,
    )
    return result.embeddings[0].values


def build_or_load_embeddings(force_rebuild: bool = False) -> list[dict]:
    patterns = _load_patterns()

    if not force_rebuild and os.path.exists(CACHE_PATH):
        with open(CACHE_PATH, "r", encoding="utf-8") as f:
            cached = json.load(f)
        cached_ids = {c["id"] for c in cached}
        current_ids = {p["id"] for p in patterns}
        if cached_ids == current_ids:
            return cached

    print(f"[rag_engine] Building embeddings for {len(patterns)} scam patterns...")
    for p in patterns:
        #Embed category + pattern + why_scam 
        combined_text = f"{p['category']}: {p['pattern']} {p['why_scam']}"
        p["embedding"] = _embed_text(combined_text)

    with open(CACHE_PATH, "w", encoding="utf-8") as f:
        json.dump(patterns, f)

    print(f"[rag_engine] Cached embeddings to {CACHE_PATH}")
    return patterns


def _cosine_similarity(a: list[float], b: list[float]) -> float:
    a_arr, b_arr = np.array(a), np.array(b)
    denom = (np.linalg.norm(a_arr) * np.linalg.norm(b_arr))
    if denom == 0:
        return 0.0
    return float(np.dot(a_arr, b_arr) / denom)


def retrieve_relevant_patterns(query_text: str, top_k: int = 3, min_similarity: float = 0.5) -> list[dict]:
    
    if not query_text or not query_text.strip():
        return []

    patterns = build_or_load_embeddings()
    query_embedding = _embed_text(query_text.strip())

    scored = []
    for p in patterns:
        sim = _cosine_similarity(query_embedding, p["embedding"])
        if sim >= min_similarity:
            scored.append({
                "id": p["id"],
                "category": p["category"],
                "pattern": p["pattern"],
                "why_scam": p["why_scam"],
                "similarity": round(sim, 3),
            })

    scored.sort(key=lambda x: x["similarity"], reverse=True)
    return scored[:top_k]


def format_context_for_prompt(matches: list[dict]) -> str:
    
    if not matches:
        return "No closely matching known scam patterns were found in the knowledge base."

    lines = ["Relevant known scam patterns retrieved from the knowledge base:"]
    for m in matches:
        lines.append(
            f"- [{m['category']}] {m['pattern']} (Why it's a scam: {m['why_scam']}) "
            f"[match confidence: {m['similarity']}]"
        )
    return "\n".join(lines)


if __name__ == "__main__":
    test_input = "Congratulations! You have been selected by Google. Pay Rs 500 for document verification."
    print("Building/loading embeddings (first run will call the embedding API)...\n")
    results = retrieve_relevant_patterns(test_input)
    print(format_context_for_prompt(results))
