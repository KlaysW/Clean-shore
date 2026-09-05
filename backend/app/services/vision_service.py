import json

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

from app.core.config import settings
from app.schemas.ai import VisionAnalysisResult

VISION_SYSTEM_PROMPT = """
Ты — специализированная нейросеть компьютерного зрения экспертного уровня для эко-платформы "Чистый берег".
Твоя задача — детально проанализировать фотографию прибрежной зоны (пляж, береговая линия, водоем) и выявить степень экологического загрязнения.

КРИТЕРИИ ОЦЕНКИ (contamination_level: 0 - 100):
- 0-10: Идеально чистый берег, природный ландшафт без следов пребывания человека.
- 11-30: Низкий уровень (1-2 мелких предмета: одиночный окурки, крышка, следы пикника).
- 31-60: Средний уровень (заметные группы мусора: ПЭТ-бутылки, пакеты, пищевая упаковка, стеклянная тара).
- 61-85: Высокий уровень (стихийная свалка, выброшенные рыболовные сети, остатки стройматериалов, покрышки).
- 86-100: Экологическая катастрофа (массовые завалы пластика, разлив масел/нефтепродуктов, опасные отходы).

ДЕТЕКТИРУЕМЫЕ МАТЕРИАЛЫ (materials):
Классифицируй и укажи в массиве только те типы мусора на русском языке, которые четко видны на фото (например: "ПЭТ-бутылки", "Полиэтиленовые пакеты", "Стеклянная тара", "Алюминиевые банки", "Автомобильные покрышки", "Рыболовные сети", "Микропластик/Нуддлы", "Древесные отходы").

ТРЕБОВАНИЯ К ФОРМАТУ ОТВЕТА:
Верни STRICTLY и ONLY валидный JSON без маркдаун-разметки (без ```json ... ```), без вводных и завершающих фраз.

Структура JSON:
{
  "contamination_level": <целое число от 0 до 100>,
  "materials": [<список найденных материалов на русском языке>],
  "confidence": <число с плавающей точкой от 0.0 до 1.0, отражающее уверенность детекции>
}

Если на снимке отсутствует мусор:
{"contamination_level": 0, "materials": [], "confidence": 0.95}
"""


class VisionServiceError(Exception):
    pass


class VisionService:
    def __init__(self) -> None:
        self._base_url = settings.OPENROUTER_BASE_URL
        self._api_key = settings.OPENROUTER_API_KEY
        self._model = settings.OPENROUTER_VISION_MODEL

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": settings.OPENROUTER_HTTP_REFERER,
            "X-Title": settings.OPENROUTER_APP_TITLE,
        }

    def _build_payload(self, image_url: str, context_hint: str | None) -> dict:
        user_text = "Проанализируй это изображение на предмет загрязнения побережья."
        if context_hint:
            user_text += f" Контекст: {context_hint}"

        return {
            "model": self._model,
            "messages": [
                {"role": "system", "content": VISION_SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": user_text},
                        {"type": "image_url", "image_url": {"url": image_url}},
                    ],
                },
            ],
            "temperature": 0.2,
            "max_tokens": 500,
        }

    @staticmethod
    def _parse_response(raw_content: str) -> VisionAnalysisResult:
        cleaned = raw_content.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.strip("`")
            if cleaned.startswith("json"):
                cleaned = cleaned[4:]
        cleaned = cleaned.strip()

        try:
            data = json.loads(cleaned)
            return VisionAnalysisResult(**data)
        except (json.JSONDecodeError, TypeError, ValueError) as exc:
            raise VisionServiceError(
                f"Не удалось распарсить ответ Vision API: {exc}"
            ) from exc

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=8),
        reraise=True,
    )
    async def analyze_image(
        self, image_url: str, context_hint: str | None = None
    ) -> VisionAnalysisResult:
        payload = self._build_payload(image_url, context_hint)
        endpoint = f"{str(self._base_url).rstrip('/')}/chat/completions"

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                endpoint,
                headers=self._headers(),
                json=payload,
            )
            response.raise_for_status()
            data = response.json()

        try:
            raw_content = data["choices"][0]["message"]["content"]
        except (KeyError, IndexError) as exc:
            raise VisionServiceError(
                f"Неожиданная структура ответа OpenRouter: {exc}"
            ) from exc

        return self._parse_response(raw_content)


vision_service = VisionService()