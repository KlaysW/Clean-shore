import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

from app.core.config import settings
from app.schemas.ai import ChatMessage, ChatMessageRole

ECO_ASSISTANT_SYSTEM_PROMPT = """
Ты — Эко-Ассистент платформы "Чистый берег", дружелюбный ИИ-консультант по экологии.

Твоя область компетенции строго ограничена:
- сортировка и переработка мусора;
- дистанционное зондирование Земли (ДЗЗ) и спутниковый мониторинг;
- аэрофотосъёмка и экологический анализ территорий;
- морская и прибрежная экология;
- порядок взаимодействия с Особо Охраняемыми Природными Территориями (ООПТ);
- принципы работы платформы "Чистый берег" (квесты, рейтинг, карта загрязнений).

Правила:
1. Отвечай кратко, дружелюбно, на русском языке.
2. Если вопрос выходит за пределы твоей компетенции — вежливо верни разговор
   к теме экологии и платформы "Чистый берег".
3. Не давай медицинских, юридических или финансовых консультаций.
4. Используй markdown для форматирования (списки, выделение), если это уместно.
"""

MAX_HISTORY_MESSAGES = 12


class LLMServiceError(Exception):
    pass


class LLMService:
    def __init__(self) -> None:
        self._base_url = str(settings.OPENROUTER_BASE_URL).rstrip("/")
        self._api_key = settings.OPENROUTER_API_KEY
        self._model = settings.OPENROUTER_LLM_MODEL

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": settings.OPENROUTER_HTTP_REFERER,
            "X-Title": settings.OPENROUTER_APP_TITLE,
        }

    def _build_messages(
        self, message: str, history: list[ChatMessage]
    ) -> list[dict[str, str]]:
        trimmed_history = history[-MAX_HISTORY_MESSAGES:]
        messages = [{"role": ChatMessageRole.SYSTEM, "content": ECO_ASSISTANT_SYSTEM_PROMPT}]
        
        for m in trimmed_history:
            if m.content and m.content.strip():
                messages.append({"role": str(m.role), "content": m.content.strip()})
                
        messages.append({"role": ChatMessageRole.USER, "content": message.strip()})
        return messages

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=8),
        reraise=True,
    )
    async def get_reply(self, message: str, history: list[ChatMessage]) -> str:
        payload = {
            "model": self._model,
            "messages": self._build_messages(message, history),
            "temperature": 0.6,
            "max_tokens": 700,
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{self._base_url}/chat/completions",
                headers=self._headers(),
                json=payload,
            )
            response.raise_for_status()
            data = response.json()

        try:
            return data["choices"][0]["message"]["content"].strip()
        except (KeyError, IndexError) as exc:
            raise LLMServiceError(
                f"Неожиданная структура ответа OpenRouter: {exc}"
            ) from exc


llm_service = LLMService()