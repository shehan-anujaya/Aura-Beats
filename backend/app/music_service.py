import httpx
from typing import Optional, Dict

class MusicService:
    def __init__(self):
        self.base_url = "https://itunes.apple.com/search"

    async def find_song_metadata(self, title: str, artist: str) -> Dict[str, Optional[str]]:
        """
        Searches for a song on iTunes and returns its artwork and preview URL.
        """
        params = {
            "term": f"{title} {artist}",
            "media": "music",
            "entity": "song",
            "limit": 1
        }
        
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(self.base_url, params=params)
                if response.status_code == 200:
                    results = response.json().get("results", [])
                    if results:
                        track = results[0]
                        return {
                            "imageUrl": track.get("artworkUrl100"),
                            "previewUrl": track.get("previewUrl")
                        }
        except Exception as e:
            print(f"Error fetching metadata for {title} by {artist}: {e}")
            
        return {"imageUrl": None, "previewUrl": None}
