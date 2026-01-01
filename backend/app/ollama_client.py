from .music_service import MusicService
import httpx
import json
import asyncio

class OllamaClient:
    def __init__(self, base_url="http://localhost:11434/api"):
        self.base_url = base_url
        self.model = "qwen3:8b"
        self.music_service = MusicService()

    async def check_connection(self):
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(f"{self.base_url}/tags")
                return response.status_code == 200
        except Exception:
            return False

    async def get_song_suggestions(self, mood: str, history: list):
        # ... (existing prompt logic)
        system_prompt = """
        You are AuraBeats, a deeply emotional and intelligent music assistant.
        Your goal is to suggest 3-5 songs based on the user's mood, vibe, or current situation.
        
        CRITICAL RULES:
        1. Respond ONLY with a valid JSON array of objects.
        2. Each object must have: "title", "artist", "genre", "mood", "reason".
        3. The "reason" should explain why this specific song matches the user's vibe (max 15 words).
        4. Do NOT include any markdown formatting, preamble, or postamble. Just the raw JSON array.
        5. If the user's input is unclear, suggest general "vibe-check" songs.
        """
        
        messages = [{"role": "system", "content": system_prompt}]
        for msg in history:
            messages.append({"role": msg["role"], "content": msg["content"]})
        
        messages.append({"role": "user", "content": f"My current vibe: {mood}"})

        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    f"{self.base_url}/chat",
                    json={
                        "model": self.model,
                        "messages": messages,
                        "stream": False,
                        "format": "json"
                    }
                )
                
                if response.status_code == 200:
                    content = response.json()["message"]["content"]
                    if "```json" in content:
                        content = content.split("```json")[1].split("```")[0].strip()
                    elif "```" in content:
                        content = content.split("```")[1].split("```")[0].strip()
                    
                    suggestions = json.loads(content)
                    
                    # Enrich with media metadata
                    enriched_suggestions = []
                    tasks = []
                    for s in suggestions:
                        tasks.append(self.music_service.find_song_metadata(s["title"], s["artist"]))
                    
                    metadata_results = await asyncio.gather(*tasks)
                    
                    for s, meta in zip(suggestions, metadata_results):
                        s["imageUrl"] = meta["imageUrl"]
                        s["previewUrl"] = meta["previewUrl"]
                        enriched_suggestions.append(s)
                        
                    return enriched_suggestions
                else:
                    raise Exception(f"Ollama API error: {response.status_code} - {response.text}")
        except httpx.ReadTimeout:
            raise Exception("Ollama timed out while generating suggestions.")
        except json.JSONDecodeError as e:
            raise Exception(f"Failed to parse AI response: {e}")
        except Exception as e:
            raise Exception(f"Unexpected error: {e}")
