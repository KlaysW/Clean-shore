from pydantic import BaseModel, Field


class VisionAnalysisResult(BaseModel):
    contamination_level: int = Field(ge=0, le=100)
    materials: list[str] = Field(default_factory=list)
    confidence: float = Field(ge=0.0, le=1.0)


class VisionAnalysisRequest(BaseModel):
    image_url: str
    context_hint: str | None = None


class ChatMessageRole:
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)
    history: list[ChatMessage] = Field(default_factory=list)


class ChatResponse(BaseModel):
    reply: str
    suggested_prompts: list[str] = Field(
        default_factory=lambda: [
            "Как сортировать пластик?",
            "Что такое ДЗЗ?",
            "Как передать данные в ООПТ?",
        ]
    )