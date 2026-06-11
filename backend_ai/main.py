from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import httpx
import os
import time
import re
from datetime import datetime

app = FastAPI(title="Hayat AI - Hızlı Model Köprüsü")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)

# Ollama bağlantı ayarları
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
MODEL_NAME = os.getenv("MODEL_NAME", "hayat-ai")

class ChatRequest(BaseModel):
    message: str
    name: Optional[str] = None
    blood_type: Optional[str] = None
    allergies: Optional[List[str]] = []
    chronic_diseases: Optional[List[str]] = []
    medications: Optional[List[str]] = []

class ChatResponse(BaseModel):
    response: str
    model: str
    dynamic_buttons: List[str] = []

@app.get("/api/v1/quick_actions")
async def get_quick_actions():
    current_month = datetime.now().month
    actions = [
        {"label": "💔 Kalp Krizi", "query": "Göğsümde şiddetli bir ağrı var, kalp krizi geçiriyor olabilir miyim?"},
        {"label": "🩸 Ağır Kanama", "query": "Durmayan ağır kanamam var, ne yapmalıyım?"},
        {"label": "😮 Nefes Alamıyorum", "query": "Boğazıma bir şey kaçtı, nefes alamıyorum ve boğuluyorum.Ne yapacağım?"},
        {"label": "🧠 Bilinç Kaybı", "query": "Birisi aniden bayıldı ve bilinci tamamen kapalı halde.Ne yapmalıyım?"},
    ]
    if current_month in [6, 7, 8]:
        actions.extend([
            {"label": "🌊 Suda Boğulma", "query": "Suda boğulma tehlikesi geçirdi, yuttuğu suyu nasıl çıkarırım?"},
            {"label": "☀️ Güneş Çarpması", "query": "Aşırı sıcakta kaldım, ateşim var ve kusuyorum.Ne yapmalıyım?"}
        ])
    elif current_month in [12, 1, 2]:
        actions.extend([
            {"label": "♨️ Soba Zehirlenmesi", "query": "Sobadan zehirlenmiş olabilirim, başım dönüyor.Ne yapacağım?"},
            {"label": "❄️ Donma", "query": "Çok soğukta kaldım, ellerimi hissetmiyorum.Ne yapmalıyım?"}
        ])
    else:
        actions.extend([
            {"label": "🐍 Isırık/Sokma", "query": "Böcek veya yılan ısırdı, bölge hızla şişiyor.Ne yapmalıyım?"},
            {"label": "🔥 Yanık", "query": "Vücudumda ciddi bir yanık var, ne yapmalıyım?"}
        ])
    return {"quick_actions": actions}

@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    t_total_start = time.perf_counter()
    
    blood = req.blood_type if req.blood_type else 'Bilinmiyor'
    allergies = ', '.join(req.allergies) if req.allergies else 'Yok'
    diseases = ', '.join(req.chronic_diseases) if req.chronic_diseases else 'Yok'
    meds = ', '.join(req.medications) if req.medications else 'Yok'
    
    enriched_message = f"Benim adım {req.name or 'Bilinmiyor'}. Kan grubum {blood}. Alerjilerim: {allergies}. Kronik hastalıklarım: {diseases}. Kullandığım ilaçlar: {meds}.\n\nŞu anki acil durum sorum: {req.message}"

    messages = [
        {"role": "user", "content": enriched_message}
    ]

    payload = {
        "model": MODEL_NAME,
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": 0.1,
            "num_predict": 350,
            "num_thread": 4
        }
    }

    try:
        t_ollama_start = time.perf_counter()
        async with httpx.AsyncClient(timeout=180.0) as client:
            r = await client.post(f"{OLLAMA_URL}/api/chat", json=payload)
            r.raise_for_status()
            
            data = r.json()
            ai_message = data["message"]["content"].strip()
            
            ai_message = re.sub(r'\*\*(.*?)\*\*', r'\1', ai_message) 
            ai_message = re.sub(r'#{1,6}\s*', '', ai_message)
            ai_message = re.sub(r'(?:Adım\s*\d+:?|\d+\.\s*Adım:?)', '•', ai_message, flags=re.IGNORECASE)
            
            dynamic_buttons = []
            button_matches = re.findall(r'\[BUTON:\s*(.*?)\]', ai_message)
            for btn in button_matches:
                dynamic_buttons.append(btn.strip())
                ai_message = ai_message.replace(f"[BUTON: {btn}]", "")
            
            ai_message = ai_message.strip()
            
        t_ollama_end = time.perf_counter()
        print(f"[PERFORMANS] Ollama Yanıt Üretimi: {t_ollama_end - t_ollama_start:.4f} saniye")
        
        t_total_end = time.perf_counter()
        print(f"[PERFORMANS] TOPLAM İSTEK SÜRESİ: {t_total_end - t_total_start:.4f} saniye")
        
        return ChatResponse(
            response=ai_message,
            model=MODEL_NAME,
            dynamic_buttons=dynamic_buttons
        )
            
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Model zaman aşımına uğradı, donanım kilitlendi!")
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Sistem Hatası: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
