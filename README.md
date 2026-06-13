# Precosquin - Evento Folklórico Artístico

Plataforma web para la gestión del evento folclórico "Precosquin" para artistas del folclore argentino.

## Estructura del Proyecto

```
Precosquinpiramides/
├── frontend/          # Angular 21 Frontend
├── backend/           # Python FastAPI Backend
├── supabase/          # Supabase Migraciones y Config
├── docker-compose.yml # Desarrollo local
└── .github/           # CI/CD Pipeline
```

## Desarrollo Local

### Prerrequisitos
- Node.js 20+
- Python 3.12+
- Docker y Docker Compose
- Supabase CLI (opcional)

### Iniciar el entorno de desarrollo

```bash
# Clonar el repositorio
git clone <repo-url>
cd Precosquinpiramides

# Iniciar servicios con Docker
docker-compose up -d

# Frontend (en otra terminal)
cd frontend
npm install
npm start

# Backend (en otra terminal)
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### URLs de desarrollo
- Frontend: http://localhost:4200
- Backend API: http://localhost:8000/docs
- API Documentation: http://localhost:8000/redoc

## Despliegue

### Frontend (Vercel)
```bash
cd frontend
vercel --prod
```

### Backend (Railway)
```bash
cd backend
railway up
```

## Variables de Entorno

Ver `.env.example` en cada directorio para las variables requeridas.

### Frontend (.env.example)
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
API_URL=http://localhost:8000
```

### Backend (.env.example)
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_JWT_SECRET=your-jwt-secret
REDIS_URL=redis://localhost:6379/0
```

## Stack Tecnológico

### Frontend
- Angular 21 (Standalone Components, Signals)
- TanStack Query (Angular Query)
- Tailwind CSS
- Supabase JS Client
- RxJS

### Backend
- Python 3.12
- FastAPI
- Supabase (PostgreSQL + Auth + Storage)
- Redis + Celery (Tareas en segundo plano)
- JWT Authentication

### Infraestructura
- Supabase (Base de datos, Auth, Storage)
- Vercel (Frontend Hosting)
- Railway (Backend Hosting)
- Docker (Desarrollo local)

## Roles de Usuario

1. **Admin** - Control total del sistema
2. **Organizador** - Gestiona evento, artistas, horarios
3. **Jurado** - Evalúa artistas
4. **Staff** - Ejecuta tareas operativas

## Funcionalidades Principales

- Formulario de inscripción público (sin login)
- Gestión de artistas y evaluaciones
- Sistema de rúbricas para jurado
- Generación de contratos y firma digital
- Gestión de documentación (riders, CVs, etc.)
- Notificaciones por Email/WhatsApp
- Dashboard y reportes

## Licencia

Propietario - Precosquin