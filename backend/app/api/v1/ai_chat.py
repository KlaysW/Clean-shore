from fastapi import APIRouter, Depends, HTTPException, status

from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.ai import ChatRequest, ChatResponse
from app.services.llm_service import LLMServiceError, llm_service

router = APIRouter(prefix="/ai-chat", tags=["Eco-Assistant"])


@router.post("/message", response_model=ChatResponse)
async def send_message(
    payload: ChatRequest,
    _current_user: User = Depends(get_current_user),
) -> ChatResponse:
    try:
        reply = await llm_service.get_reply(payload.message, payload.history)
    except LLMServiceError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Эко-Ассистент временно недоступен: {exc}",
        ) from exc

    return ChatResponse(reply=reply)