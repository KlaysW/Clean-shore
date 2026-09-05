### SYSTEM PROMPT & TECHNICAL SPECIFICATION: CLEAN SHORE (ЧИСТЫЙ БЕРЕГ)

**Role:** You are acting as a Senior Product Manager, Lead Full-Stack Architect, and UX/UI Designer.
**Context:** Production-ready specification and implementation prompt for the "Clean Shore" (Чистый берег) platform—a gamified ecological monitoring solution tailored for the Space Hackathon, backed by "SR Data" and Yandex Cloud.

---

### 1. PRODUCT STRATEGY & GO-TO-MARKET

#### 1.1 Target Audience Matrix & Value Proposition

* **Audience 1: Youth & Students (14–25 years)**
* *Motivation:* Gamification, social recognition, competitive ranking, real-world ecological impact, entry-level exposure to Earth Remote Sensing (ERS/ДЗЗ) and Spatial AI technologies.
* *Barriers:* Lack of ecological awareness, low motivation for standard voluntary work without incentives, abstract nature of space technology.
* *Value Proposition:* Turn ecological cleanup into an interactive AR/AI quest, earn rating points, climb regional leaderboards, learn satellite/drone image analysis, and directly influence environmental health.


* **Audience 2: Protected Natural Territories (ООПТ) Staff & Environmental Inspectors**
* *Motivation:* Automated field verification, crowdsourced shoreline monitoring, real-time heatmaps, reduction of manual inspection overhead, direct reporting tools.
* *Barriers:* Limited personnel for vast coastal coverage, delayed detection of illegal dump sites, fragmented analytical tools.
* *Value Proposition:* Turn thousands of citizens into active field sensors; receive verified PostGIS spatial datasets, high-confidence AI pollution detection reports, and direct interaction channels for targeted cleanups.



#### 1.2 Full User Journey & Funnel

1. **Awareness & Onboarding:** User learns about the project through educational institutions, social media, or local eco-campaigns. User downloads the Flutter app or accesses the React landing page.
2. **Educational Gateway:** Integrated micro-courses on Earth Remote Sensing (ДЗЗ), satellite imagery analysis, and pollution sorting guide the user through foundational knowledge.
3. **Field Activity (Active Monitoring):** User opens the interactive Yandex Map / Heatmap overlay, executes "Pollution Search" (takes geotagged photos analyzed by OpenRouter Vision API), and earns initial rating points (50–250 pts).
4. **Field Activity (Cleanup Verification):** User executes "Pollution Cleanup", taking "Before" and "After" photos. Dual-stage Vision AI verifies the delta in pollution reduction, updating PostGIS data and awarding higher rating scores (200–2000 pts).
5. **Retention & Community:** User interacts with the Eco-Assistant LLM chat, tracks regional rank on the Leaderboard (Top 50), unlocks badges, and staff/volunteers coordinate through the "Professional ООПТ Mode".

---

### 2. ARCHITECTURE & TECHNICAL SPECIFICATION

#### 2.1 Complete Technology Stack

* **Client Frontend (Web):** React 18, TypeScript, TailwindCSS, Vite, Yandex Maps API v3.
* **Client Frontend (Mobile):** Flutter 3.x, Dart, `flutter_bloc`, `camera`, `geolocator`, `flutter_map` / Yandex Maps Mobile SDK.
* **Backend API Gateway & Core:** Python 3.11, FastAPI, Pydantic v2, SQLAlchemy 2.0 (AsyncIO), Alembic.
* **Database & GIS:** PostgreSQL 16 + PostGIS 3.4 Extension.
* **AI Engine & External Services:**
* OpenRouter API (Accessing GPT-4o / Claude-3.5-Sonnet Vision models for multi-class waste detection and 0–100 contamination scoring).
* OpenRouter API (Accessing LLM for contextual Eco-Assistant chat with system-prompt constraints).
* Storage: S3-Compatible Object Storage (Yandex Cloud Object Storage) for images (`before`, `after`, `detection`).


#### 2.2 System Architecture Diagram

```
  [ Mobile App (Flutter) ]       [ Web Landing / Admin (React) ]
             |                                 |
             +-----------------+---------------+
                               | (HTTPS / REST API JSON)
                               v
                  [ FastAPI Server (Python) ]
                               |
       +-----------------------+-----------------------+
       |                       |                       |
       v                       v                       v
[ PostGIS / DB ]      [ S3 Image Store ]     [ OpenRouter API ]
(Spatial Data)         (Yandex Cloud)         - Vision ML Engine
                                              - LLM Eco Chat Engine

```

#### 2.3 Detailed Directory Structure

```
clean-shore/
├── README.md
├── backend/
│   ├── requirements.txt
│   ├── alembic/
│   │   ├── env.py
│   │   └── versions/
│   └── app/
│       ├── main.py
│       ├── core/
│       │   ├── config.py
│       │   ├── database.py
│       │   └── security.py
│       ├── api/
│       │   ├── v1/
│       │   │   ├── router.py
│       │   │   ├── auth.py
│       │   │   ├── quests.py
│       │   │   ├── map.py
│       │   │   ├── ai_chat.py
│       │   │   └── oopt.py
│       │   └── dependencies.py
│       ├── models/
│       │   ├── user.py
│       │   ├── pollution_spot.py
│       │   └── leaderboard.py
│       ├── schemas/
│       │   ├── user.py
│       │   ├── spot.py
│       │   └── ai.py
│       └── services/
│           ├── vision_service.py
│           ├── llm_service.py
│           ├── spatial_service.py
│           └── s3_service.py
├── mobile_app/
│   ├── pubspec.yaml
│   ├── android/
│   ├── ios/
│   └── lib/
│       ├── main.dart
│       ├── core/
│       │   ├── theme/
│       │   ├── constants/
│       │   └── network/
│       ├── logic/
│       │   ├── auth/
│       │   ├── map/
│       │   ├── camera/
│       │   └── leaderboard/
│       └── presentation/
│           ├── screens/
│           │   ├── auth_screen.dart
│           │   ├── map_screen.dart
│           │   ├── quest_screen.dart
│           │   ├── camera_screen.dart
│           │   ├── ai_chat_screen.dart
│           │   ├── leaderboard_screen.dart
│           │   └── profile_screen.dart
│           └── widgets/
│               ├── heatmap_layer.dart
│               ├── bottom_sheet_spot.dart
│               └── score_badge.dart
└── web_site/
    ├── package.json
    ├── vite.config.ts
    ├── src/
    │   ├── main.tsx
    │   ├── App.tsx
    │   ├── components/
    │   │   ├── Hero.tsx
    │   │   ├── ERSSection.tsx
    │   │   ├── InteractiveMap.tsx
    │   │   └── OOPTPortal.tsx
    │   └── assets/

```

---

### 3. DATABASE SCHEMA & DATA FLOW LOGIC

#### 3.1 PostGIS Data Schema (SQL)

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    nickname VARCHAR(100) NOT NULL,
    rating_points INT DEFAULT 0,
    region VARCHAR(100) DEFAULT 'Main Region',
    is_oopt_staff BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pollution_spots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id),
    cleaner_id UUID REFERENCES users(id),
    location GEOMETRY(Point, 4326) NOT NULL,
    pollution_score_before INT CHECK (pollution_score_before BETWEEN 0 AND 100),
    pollution_score_after INT CHECK (pollution_score_after BETWEEN 0 AND 100),
    detected_materials TEXT[],
    photo_before_url TEXT NOT NULL,
    photo_after_url TEXT,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, IN_PROGRESS, CLEANED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_spots_spatial ON pollution_spots USING GIST (location);

```

#### 3.2 Spatial Deduplication & Analysis Logic

1. **Deduplication Threshold:** When a user takes a photo for "Pollution Search", the backend queries PostGIS:
```sql
SELECT id, ST_DistanceSphere(location, ST_MakePoint(:lon, :lat)) AS distance
FROM pollution_spots
WHERE ST_DWithin(location::geography, ST_MakePoint(:lon, :lat)::geography, 15)
  AND status = 'ACTIVE';

```


2. **Duplicate Handling:** If a record exists within 15 meters, the system flags the spot as "Already Identified", rejects duplicate rating point allocation, and alerts the user.
3. **Vision Processing Workflow:**
* Image + Lat/Lon uploaded via API -> Saved to S3 -> URL passed to OpenRouter Vision Engine.
* Model returns structured JSON: `{ contamination_level: int, materials: list, confidence: float }`.
* DB entry created/updated -> Heatmap weight refreshed -> User awarded rating points (`contamination_level * coefficient`).



---

### 4. DETAILED UI/UX SPECIFICATIONS (FLUTTER APP)

#### 4.1 Auth Screen

* **Brand Assets:** Wave vector graphics, header "Чистый берег", subtitle "Экологический мониторинг и квесты".
* **Inputs:** Email input field, Password input field, Primary Action Button ("Начать спасать планету") styled with vibrant eco-green gradient (`#2ECC71` to `#27AE60`).
* **SSO Interactivity:** External OAuth buttons ("Яндекс", "Google", "VK").

#### 4.2 Map Screen (Tab 1 - Core Dashboard)

* **Top App Bar:** Branding title, user rating points indicator pill ("340 баллов").
* **Filter Chips Bar:** Horizontal scroll chips: `Все`, `Требуют уборки` (red marker with trash icon), `Очищено` (green checkmark pin).
* **Map Container:** Yandex Maps SDK integration with dynamic GeoJSON / Heatmap overlay rendering PostGIS spatial points. Floating Action Button for GPS centering.
* **Interactive Bottom Sheet:** Triggered on pin tap. Displays urgency status ("Требует внимания"), distance ("230 м от вас"), AI detection breakdown ("Пластик, Стекло • Уровень: 87/100 • Спутниковый слой ДЗЗ"), and call-to-action button "Перейти к уборке".

#### 4.3 Quests & AR Camera (Tab 2)

* **Mode Toggle:** Segmented Control (Mode A: "Поиск загрязнений" / Mode B: "Уборка места").
* **Viewfinder UI:** Fullscreen live camera feed with scanning grid animation overlay.
* **Analysis Popup Modal:** Displays progress ring, pollution score readout (e.g., "85 / 100" in crimson text), AI classification tags ("Обнаружено: Стекло, ПЭТ бутылки, Алюминий"), and dual buttons: "Отправить в базу" and "Переснять".

#### 4.4 Eco-Assistant AI Chat (Tab 3)

* **Header:** Status bar "Эко-Ассистент — ИИ Консультант онлайн".
* **Preset Prompt Chips:** Tap-to-send contextual prompts ("Как сортировать пластик?", "Что такое ДЗЗ?", "Как передать данные в ООПТ?").
* **Chat Stream:** Bubbles differentiating AI system response and user messages, with support for markdown links and formatting.

#### 4.5 Regional Leaderboard (Tab 4)

* **Top 3 Podium:** Visual 1st, 2nd, 3rd place stands with custom avatars, user handles, and trophy icons.
* **Scrollable Ranks (4-50):** List view with avatar, nickname, completed quests, and point tallies.
* **Fixed User Rank Bar:** Sticky bottom panel showing current user position ("Вы (ЭкоГерой) — 14 место • До топ-10 еще 510 баллов").

#### 4.6 User Profile & Professional ООПТ Mode (Tab 5)

* **Header Card:** User avatar, nickname, email, gear settings icon.
* **Stats Grid:** Cards for "Найдено загрязнений", "Убрано территорий", "Очки рейтинга".
* **Professional ООПТ Integration Card:** Dedicated section for verified nature reserve staff. Text: "Свяжитесь напрямую с Особо Охраняемыми Природными Территориями (ООПТ) для участия в инспекциях", accompanied by an action button "Связаться с ООПТ".
* **Footer:** Logout button ("Выйти").

---

### 5. IMPLEMENTATION ROADMAP, ECONOMICS, & KPIS

#### 5.1 Project Milestones (6-Month Horizon)

* **Months 1–2 (Pilot MVP):** Core Backend setup, PostGIS schema, OpenRouter Vision/LLM integration, Flutter MVP (Map, Camera, Search Quest).
* **Months 3–4 (Testing & ООПТ Pilot):** Deployment on Yandex Cloud, testing with youth groups in coastal pilot regions, activation of "Professional ООПТ Mode", React landing page launch.
* **Months 5–6 (Scale & Community Expansion):** Integration of satellite Earth Remote Sensing (ДЗЗ) baseline heatmaps from "SR Data", regional leaderboards across coastal administrative units.

#### 5.2 Key Performance Indicators (KPIs)

* **User Acquisition:** Number of active mobile app downloads (Target: 10,000+ youth users in Year 1).
* **Educational Conversion:** % of app users completing the intro ERS/ДЗЗ micro-course (Target: >40%).
* **Environmental Impact:** Total confirmed pollution points added to PostGIS; total cleaned areas verified via "Before/After" Vision AI (Target: 2,500+ shoreline areas cleaned).
* **B2B / Government Engagement:** Number of verified ООПТ inspectors using the platform for field verification.

#### 5.3 Resource Allocation & Budget Estimate

* **Development Team:** 1 Lead Architect, 1 Backend (Python) Engineer, 1 Mobile (Flutter) Engineer, 1 UX/UI Designer.
* **Infrastructure Costs (Monthly Estimate):**
* Yandex Cloud (Managed PostgreSQL, K8s/VMs, Object Storage): ~$250/month.
* OpenRouter API (Vision ML + LLM calls): ~$150/month (scalable per query volume).
* Yandex Maps API License: Open-source / Startup tier usage.



---

### 6. MASTER PROMPT FOR CODE GENERATION

Act as a Principal Full-Stack Engineer and System Architect. Implement the production-ready code structure for the "Clean Shore" (Чистый берег) platform using Python 3.11 (FastAPI), PostgreSQL + PostGIS, OpenRouter API, and Flutter.

### TASK REQUIREMENTS:
1. Implement Backend (FastAPI):
   - PostgreSQL/PostGIS database connection using SQLAlchemy 2.0 AsyncIO.
   - Pydantic models for request/response handling.
   - Spatial API endpoints for handling "Pollution Search" and "Pollution Cleanup" with 15-meter PostGIS deduplication using ST_DWithin.
   - Service wrapper for OpenRouter API calling Vision ML models to evaluate image pollution score (0-100) and identify waste materials.
   - Eco-Assistant chat endpoint backed by OpenRouter LLM.

2. Implement Database Migration Schema (Alembic/SQLAlchemy):
   - User table (with OOPT flag and leaderboard ratings).
   - PollutionSpot table (with PostGIS Geometry Point, status, before/after photo URLs, and pollution scores).

3. Structure the Flutter client application architecture:
   - Provide clean BLoC / State Management structure covering Map, Quest Camera, AI Chat, Leaderboard, and Profile.

Ensure all code follows high performance standards, async paradigms, strict type annotations, and robust error handling.