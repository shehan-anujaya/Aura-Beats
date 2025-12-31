import httpx
import json

class OllamaClient:
    def __init__(self, base_url="http://localhost:11434/api"):
        self.base_url = base_url
        self.model = "qwen2.5:3b"

    async def check_connection(self):
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(f"{self.base_url}/tags")
                return response.status_code == 200
        except Exception:
            return False

    async def get_song_suggestions(self, mood: str, history: list):
        system_prompt = """
        You are AuraBeats, a deeply emotional and intelligent music assistant.
        Your goal is to suggest songs based on the user's mood and vibe.
        You MUST reply with a strictly valid JSON array of objects.
        Each object must have: "title", "artist", "genre", "mood", "reason".
        Do not include any markdown formatting like ```json ... ```. Just the raw JSON.
        """
        
        messages = [{"role": "system", "content": system_prompt}]
        messages.extend(history)
        messages.append({"role": "user", "content": mood})

        async with httpx.AsyncClient(timeout=30.0) as client:
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
                return json.loads(content)
            else:
                raise Exception(f"Ollama API error: {response.text}")
