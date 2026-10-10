import os
import json
import httpx
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

app = FastAPI()

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
MODEL_NAME = "gemma:2b"

class PosQueryRequest(BaseModel):
    word: str
    sentence: str

@app.post("/api/classify")
async def classify_word(req: PosQueryRequest):
    prompt = (
        f"Analyze the word '{req.word}' in the context of the sentence: '{req.sentence}'. "
        f"Classify its Part of Speech into exactly one of these lowercase codes: "
        f"n (noun), v (verb), adj (adjective), adv (adverb), prep (preposition), pron (pronoun), det (determiner), aux (auxiliary). "
        f"Return ONLY valid JSON in this exact format: {{\"word\": \"{req.word}\", \"pos\": \"code\"}}"
    )
    
    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": False,
        "format": "json"
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.post(f"{OLLAMA_HOST}/api/generate", json=payload)
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Ollama classification failed")
            
            data = response.json()
            result_text = data.get("response", "{}")
            parsed = json.loads(result_text)
            return {"word": req.word, "pos": parsed.get("pos", "n")}
        except Exception as e:
            # Fallback heuristic if Ollama is unreachable
            return {"word": req.word, "pos": "n"}

app.mount("/", StaticFiles(directory="public", html=True), name="public")