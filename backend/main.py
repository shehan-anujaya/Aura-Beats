from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
from app.ollama_client import OllamaClient

app = FastAPI(title="AuraBeats Backend")
ollama_client = OllamaClient()

class Message(BaseModel):
    role: str
    content: str

class SuggestionRequest(BaseModel):
    mood: str
    history: List[Message]

@app.get("/health")
async def health_check():
    return {"status": "ok", "ollama_connected": await ollama_client.check_connection()}

@app.post("/suggestions")
async def get_suggestions(request: SuggestionRequest):
    try:
        suggestions = await ollama_client.get_song_suggestions(
            mood=request.mood,
            history=[{"role": m.role, "content": m.content} for m in request.history]
        )
        return {"suggestions": suggestions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
