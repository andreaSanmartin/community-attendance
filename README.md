# Community Attendance

![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-02569B?logo=dart)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)
![License](https://img.shields.io/badge/License-MIT-green)

**Community Attendance** is an open-source attendance management system designed for nonprofit organizations, community groups, youth programs, clubs, and other organizations that need a simple and efficient way to track participation.

The project provides a Flutter mobile application connected to a FastAPI backend and PostgreSQL database.

Participants can check in quickly using a personal QR code without logging into the application, while authorized staff members can manage participants, groups, projects, users, permissions, manual attendance, and reports.

---

## ✨ Features

### QR Attendance

Participants receive a unique QR identifier that can be scanned directly from the application's public home screen.

No authentication is required to scan a QR code.

The workflow is intentionally simple:

```text
Open App
   ↓
Scan QR Code
   ↓
Validate Participant
   ↓
Register Attendance
   ↓
Attendance Confirmed
```

The system prevents duplicate attendance records for the same participant on the same day.

QR codes contain an opaque random identifier instead of personal information.

---

### Manual Attendance

Authorized users can manually register attendance when a participant does not have their QR code available.

Staff members can:

- Search participants
- Filter participants
- Select multiple participants
- Register attendance for a selected date
- Identify participants who have already checked in

Manual attendance requires authentication.

---

### Participant Management

Authorized users can:

- Create participants
- Edit participant information
- Deactivate participants
- Assign participants to groups
- Assign optional projects or teams
- Generate unique QR identifiers
- Regenerate QR identifiers
- Search by name or phone number

The system intentionally keeps participant information minimal.

Typical information includes:

- Full name
- Phone number
- Group
- Optional project/team

Sensitive or unnecessary identification information is not required.

---

### Groups

Organizations can create their own groups dynamically.

Examples:

```text
Group A
Group B
Group C
```

Participants can then be assigned to one of these groups.

Groups are stored in the database and are not hardcoded into the application.

---

### Projects and Teams

Participants can optionally belong to a project or team.

Examples include:

- Football
- Music
- Dance
- Volunteering
- Community projects
- Sports teams

Projects can optionally be associated with a specific group.

---

### Attendance Reports

The application provides attendance statistics and reports that help organizations understand participation.

Available information includes:

- Today's attendance
- Weekly attendance
- Active participants
- Unique participants attending during the week
- Attendance by group
- Attendance by participant
- Participants who did not attend during the week

Reports can be filtered by groups, projects, and dates.

---

### Role-Based Access Control

The application supports different types of users.

#### Super Administrator

Super administrators have full access to the platform.

They can manage:

- Participants
- Groups
- Projects
- Attendance
- Reports
- Users
- Permissions

Multiple super administrators can exist.

#### Coordinator

Coordinators only see the modules assigned to them.

For example:

```text
Coordinator A

✓ Manual Attendance
✓ Participants
✓ Reports
✗ Groups
✗ Projects
✗ User Management
```

Menus are dynamically generated after authentication according to the user's permissions.

---

### Dynamic Menu Permissions

Super administrators can configure which modules each coordinator can access.

The backend stores these permissions and returns the authorized menu after login.

This allows organizations to adapt the application to different responsibilities without modifying the source code.

---

### Light and Dark Mode

The Flutter application supports:

- ☀️ Light mode
- 🌙 Dark mode

The selected theme is persisted locally on the device.

Users can switch themes directly from the application.

---

## 🏗️ Architecture

The project follows a client-server architecture.

```text
┌──────────────────────────┐
│                          │
│      Flutter Mobile      │
│                          │
│   Android / Mobile App   │
│                          │
└────────────┬─────────────┘
             │
             │ HTTPS / REST API
             │
             ▼
┌──────────────────────────┐
│                          │
│       FastAPI API        │
│                          │
│   Authentication / RBAC  │
│   Business Logic         │
│   Reports                │
│                          │
└────────────┬─────────────┘
             │
             │ SQLAlchemy
             │
             ▼
┌──────────────────────────┐
│                          │
│       PostgreSQL         │
│                          │
│ Participants             │
│ Attendance               │
│ Groups                   │
│ Projects                 │
│ Users & Permissions      │
│ Audit Logs               │
│                          │
└──────────────────────────┘
```

---

## 🛠️ Technology Stack

### Mobile Application

- Flutter
- Dart
- Provider
- Dio
- Flutter Secure Storage
- Shared Preferences
- Mobile Scanner
- QR Flutter
- Intl

### Backend

- Python 3.12+
- FastAPI
- SQLAlchemy 2
- Pydantic
- JWT Authentication
- Passlib
- Psycopg

### Database

- PostgreSQL

### Infrastructure

- Docker
- Docker Compose

The application can be deployed to most cloud providers or VPS environments.

---

## 📁 Project Structure

A recommended repository structure is:

```text
community-attendance/
│
├── backend/
│   │
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── db/
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── services/
│   │   └── main.py
│   │
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── requirements.txt
│   └── .env.example
│
├── mobile/
│   │
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── pubspec.yaml
│   └── README.md
│
├── .gitignore
├── LICENSE
└── README.md
```

---

# 🚀 Getting Started

## Prerequisites

Before running the project, install:

- Git
- Docker and Docker Compose
- Flutter SDK
- Android Studio or another Android development environment

For development without Docker, you will also need:

- Python 3.12+
- PostgreSQL

---

## 📥 Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/community-attendance.git
cd community-attendance
```

Replace `YOUR_USERNAME` with your GitHub username.

---

# ⚙️ Backend Setup

Navigate to the backend directory:

```bash
cd backend
```

Copy the example environment file:

### Linux / macOS

```bash
cp .env.example .env
```

### Windows PowerShell

```powershell
Copy-Item .env.example .env
```

Configure the environment variables:

```env
APP_NAME=Community Attendance API
ENVIRONMENT=development

DATABASE_URL=postgresql+psycopg://community:community_password@db:5432/community_attendance

JWT_SECRET=CHANGE_THIS_TO_A_LONG_RANDOM_SECRET
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=480

CORS_ORIGINS=*

PUBLIC_QR_RATE_LIMIT_PER_MINUTE=60

FIRST_ADMIN_USERNAME=admin
FIRST_ADMIN_PASSWORD=ChangeThisPassword123!
FIRST_ADMIN_FULL_NAME=System Administrator
```

> Never commit your real `.env` file or production secrets to GitHub.

---

## 🐳 Run with Docker

The easiest way to start the backend and PostgreSQL is Docker Compose.

```bash
docker compose up --build
```

Once the containers are running, the API will be available at:

```text
http://localhost:8000
```

Interactive API documentation:

```text
http://localhost:8000/docs
```

Health check:

```text
http://localhost:8000/health
```

---

## 🐍 Run Backend Without Docker

Create a Python virtual environment.

### Windows

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### Linux / macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Make sure PostgreSQL is running and update `DATABASE_URL` in `.env`.

Start the API:

```bash
uvicorn app.main:app --reload
```

---

# 📱 Flutter Setup

Navigate to the mobile application:

```bash
cd mobile
```

Check your Flutter installation:

```bash
flutter doctor
```

Install the dependencies:

```bash
flutter pub get
```

Connect an Android device or start an Android emulator.

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

---

## 🔗 Backend Connection

When using an Android emulator, the application can access a backend running on your computer through:

```text
http://10.0.2.2:8000
```

For a physical Android device connected to the same local network, use your computer's local IP address.

Example:

```text
http://192.168.1.100:8000
```

For production, always use an HTTPS endpoint:

```text
https://api.example.org
```

---

# 🔐 Authentication

Administrative functionality uses JWT authentication.

The general authentication flow is:

```text
Username + Password
        ↓
     FastAPI
        ↓
 Validate User
        ↓
 Generate JWT
        ↓
 Flutter Secure Storage
        ↓
Authenticated Requests
```

Access tokens are stored using secure device storage.

---

# 📷 QR Check-In

QR attendance intentionally does not require a user login.

The public application flow is:

```text
Home
 │
 ├── Scan QR Code
 │       │
 │       ├── Open Camera
 │       ├── Read QR Token
 │       ├── Validate Participant
 │       └── Register Attendance
 │
 └── Sign In
         │
         └── Administrative Features
```

A QR code should contain only the participant's random token.

Example:

```text
67342451-671c-48dd-a6bf-7ef9d49f2286
```

It should **not** contain:

```text
Full name
Phone number
Group
Project
Other personal information
```

---

# 🔌 Main API Endpoints

### Authentication

```http
POST /api/auth/login
GET  /api/auth/me
POST /api/auth/change-password
GET  /api/auth/menu
```

### Participants

```http
GET    /api/youth
POST   /api/youth
GET    /api/youth/{id}
PUT    /api/youth/{id}
DELETE /api/youth/{id}
POST   /api/youth/{id}/regenerate-qr
```

### Attendance

Public QR check-in:

```http
POST /api/attendance/qr
```

Authenticated manual attendance:

```http
POST /api/attendance/manual
GET  /api/attendance/today
```

### Groups

```http
GET    /api/tribes
POST   /api/tribes
PUT    /api/tribes/{id}
DELETE /api/tribes/{id}
```

### Projects

```http
GET    /api/projects
POST   /api/projects
PUT    /api/projects/{id}
DELETE /api/projects/{id}
```

### Reports

```http
GET /api/reports/summary
GET /api/reports/weekly
GET /api/reports/absent
GET /api/reports/by-tribe
```

### Users and Permissions

```http
GET    /api/users
POST   /api/users
PUT    /api/users/{id}
DELETE /api/users/{id}

POST /api/users/{id}/reset-password

GET /api/users/{id}/permissions
PUT /api/users/{id}/permissions
```

---

# 🔒 Security Considerations

The project includes several security measures:

- JWT authentication
- Password hashing
- Role-based authorization
- Dynamic menu permissions
- Random UUID QR tokens
- Duplicate attendance prevention
- QR endpoint rate limiting
- Logical deletion of historical entities
- Basic audit logging
- Secure token storage on mobile devices

For production deployments, it is strongly recommended to also configure:

- HTTPS
- Reverse proxy
- Restricted CORS
- Strong secrets
- Firewall rules
- Automated PostgreSQL backups
- Centralized application logs
- Database migrations
- Monitoring

PostgreSQL should never be directly exposed to the public Internet.

---

# 🗄️ Data Privacy

Community Attendance is designed around data minimization.

Organizations should collect only the information necessary for attendance management.

The application does not require government identification numbers or other unnecessary sensitive information.

Deployers are responsible for configuring and operating the system according to the privacy and data protection laws applicable in their jurisdiction.

---

# 🎯 Use Cases

Community Attendance can be adapted for:

- Nonprofit organizations
- Community organizations
- Youth programs
- Volunteer groups
- Sports clubs
- Educational communities
- Social projects
- Community events
- Small organizations requiring attendance tracking

---

# 🗺️ Roadmap

Future improvements may include:

- [ ] Database migrations with Alembic
- [ ] Automated backend tests
- [ ] Flutter widget and integration tests
- [ ] CSV/Excel report export
- [ ] PDF reports
- [ ] Advanced analytics dashboard
- [ ] Multiple attendance events per day
- [ ] Organization-level multi-tenancy
- [ ] Device authorization for public QR scanners
- [ ] Offline attendance synchronization
- [ ] Push notifications
- [ ] Web administration panel
- [ ] Localization support
- [ ] CI/CD with GitHub Actions

---

# 🤝 Contributing

Contributions are welcome.

If you would like to improve Community Attendance:

1. Fork the repository.
2. Create a feature branch.

```bash
git checkout -b feature/my-feature
```

3. Commit your changes.

```bash
git commit -m "feat: add my feature"
```

4. Push your branch.

```bash
git push origin feature/my-feature
```

5. Open a Pull Request.

Please keep code, class names, variables, methods, comments, and technical documentation in English.

---

# 🐛 Issues

If you find a bug or have a feature request, open an issue in the GitHub repository with:

- A clear description
- Steps to reproduce the problem
- Expected behavior
- Actual behavior
- Screenshots or logs when relevant

---

# 📄 License

This project is available under the MIT License.

See the `LICENSE` file for more information.

---

# 💙 Community Attendance

Built to help nonprofit and community organizations spend less time managing attendance and more time focusing on their communities.

If you find this project useful, consider giving the repository a ⭐.
