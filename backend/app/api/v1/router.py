from fastapi import APIRouter

from app.api.v1 import ai_chat, auth, map, oopt, quests

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(quests.router)
api_router.include_router(map.router)
api_router.include_router(ai_chat.router)
api_router.include_router(oopt.router)