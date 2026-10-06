from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from app.core.config import settings
from app.core.security import hash_password
from app.db.base import Base
from app.db.session import engine,SessionLocal
from app.models import AppUser, MenuItem
from app.api.routes import auth,tribes,projects,youth,users,attendance,reports
MENU_SEED = [
    ('manual_attendance','Asistencia manual','Registrar asistencia de forma manual','checklist',10),
    ('youth','Jóvenes','Crear, editar y consultar jóvenes','groups',20),
    ('tribes','Tribus','Administrar las tribus','diversity_3',30),
    ('projects','Proyectos','Administrar proyectos y equipos','sports_soccer',40),
    ('reports','Reportes','Consultar asistencias y estadísticas','bar_chart',50),
    ('users','Usuarios','Gestionar usuarios y permisos','manage_accounts',60),
]

def seed_menus(db):
    for key,label,description,icon,order in MENU_SEED:
        item=db.scalar(select(MenuItem).where(MenuItem.key==key))
        if not item:
            db.add(MenuItem(key=key,label=label,description=description,icon=icon,sort_order=order))
    db.commit()

def create_first_admin():
    db=SessionLocal()
    try:
        seed_menus(db)
        exists=db.scalar(select(AppUser).where(AppUser.username==settings.first_admin_username))
        if not exists:
            db.add(AppUser(full_name=settings.first_admin_full_name,username=settings.first_admin_username,password_hash=hash_password(settings.first_admin_password),role="SUPER_ADMIN",must_change_password=True)); db.commit()
    finally: db.close()
@asynccontextmanager
async def lifespan(app:FastAPI):
    Base.metadata.create_all(bind=engine); create_first_admin(); yield
app=FastAPI(title=settings.app_name,version="1.0.0",lifespan=lifespan)
app.add_middleware(CORSMiddleware,allow_origins=settings.cors_origins_list,allow_credentials=False if settings.cors_origins_list==["*"] else True,allow_methods=["*"],allow_headers=["*"])
@app.get("/")
def root(): return {"name":settings.app_name,"status":"ok","docs":"/docs"}
@app.get("/health")
def health(): return {"status":"healthy"}
for r in [auth.router,tribes.router,projects.router,youth.router,users.router,attendance.router,reports.router]: app.include_router(r)
