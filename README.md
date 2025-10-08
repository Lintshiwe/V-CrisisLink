# CrisisLink2.0 Vagrant Setup

This repository contains Vagrant configuration to automatically set up and run the CrisisLink2.0 application in a virtual machine.

## 🚨 What is CrisisLink?

CrisisLink is a mobile-first disaster rescue platform built for South Africans facing extreme weather emergencies. With one tap on a glowing SOS button, users instantly send their live location and alert status to 24/7 emergency agents. The system also monitors local weather conditions and triggers visual warnings when danger is imminent—helping users prepare and respond faster.

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed on your host machine:

1. [Vagrant](https://www.vagrantup.com/downloads) (2.2.19 or newer)
2. [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (6.1 or newer)
3. Git (to clone this repository)

## 🚀 Getting Started

Follow these steps to set up and run CrisisLink using Vagrant:

### 1. Clone this Repository

```bash
git clone https://github.com/Lintshiwe/V-CrisisLink.git
cd V-CrisisLink
```

### 2. Start the Vagrant VM

```bash
vagrant up
```

This command will:

- Download the Debian Bullseye base box (if not already present)
- Set up a virtual machine with 2GB RAM and 2 CPU cores
- Install all required dependencies (Node.js, PostgreSQL with PostGIS, Redis)
- Clone the CrisisLink2.0 repository from GitHub
- Set up the database and required environment files
- Install all project dependencies
- Fix any potential native module issues (like bcrypt)
- Start the application automatically

The entire setup is fully automated - no manual steps required!

### 3. Access the Application

Once the VM is provisioned (this may take several minutes), you can access the application at:

- Frontend: [http://localhost:3000](http://localhost:3000)
- Backend API: [http://localhost:5000](http://localhost:5000)

## 🔧 Managing the VM

- **SSH into the VM**: `vagrant ssh`
- **Stop the VM**: `vagrant halt`
- **Restart the VM**: `vagrant reload`
- **Destroy the VM**: `vagrant destroy`

## ⚙️ Configuration

The Vagrant setup includes:

- **Port Forwarding**:

  - Frontend (port 3000)
  - Backend API (port 5000)

- **System Requirements**:
  - 2GB RAM
  - 2 CPU cores

You can modify these settings in the `Vagrantfile` if needed.

## 🔑 API Keys Setup

CrisisLink comes with pre-configured API keys for core functionality, but you can also use your own keys.

### Quick Setup (Recommended)

1. **Run the setup script**:

   ```bash
   ./setup-api-keys.sh
   ```

2. **Start Vagrant**:

   ```bash
   vagrant up
   ```

### Manual Setup

1. **Copy the template**:

   ```bash
   cp api-keys.env.template api-keys.env
   ```

2. **Edit your API keys**:

   ```bash
   nano api-keys.env
   ```

3. **Start Vagrant**:

   ```bash
   vagrant up
   ```

### Pre-configured Services

The following services are **already configured** and working:

✅ **OpenWeatherMap API** - Real-time weather data and alerts  
✅ **Ambee Environmental API** - Natural disaster monitoring  
✅ **Google Maps API** - Interactive maps and geolocation  
✅ **Google Firebase API** - Real-time database and notifications

### Optional Services (Require Your Own Credentials)

❌ **Twilio SMS** - Emergency SMS alerts (optional)  
❌ **Custom JWT Secret** - Enhanced security (recommended for production)

### Security Features

- 🔒 **API keys are never committed to Git** (protected by .gitignore)
- 🔒 **Automatic environment variable injection** during VM setup
- 🔒 **Template system** for easy key management
- 🔒 **Fallback to working defaults** if no custom keys provided

## 🧩 Project Structure

Inside the VM, the CrisisLink project is located at `/home/vagrant/CrisisLink` with the following structure:

- `backend/` - Node.js backend API
- `frontend/` - React frontend application
- `database/` - Database schema and migrations

## 📝 Troubleshooting

If you encounter any issues:

### Check the service status

```bash
vagrant ssh -c "sudo systemctl status crisislink"
```

### View service logs

```bash
vagrant ssh -c "sudo journalctl -u crisislink"
```

### Restart the application

```bash
vagrant ssh -c "sudo systemctl restart crisislink"
```

### Fix bcrypt native module issues

If you see errors about the bcrypt module:

```bash
vagrant ssh
cd ~/CrisisLink/backend
npm rebuild bcrypt --build-from-source
sudo systemctl restart crisislink
```

### Check if ports are in use

```bash
vagrant ssh -c "netstat -tulpn | grep -E '3000|5000'"
```

### Database troubleshooting

```bash
vagrant ssh
sudo -u postgres psql -c '\l' # List databases
sudo -u postgres psql -d crisislink -c '\dt' # List tables
```

## 📄 License

CrisisLink is available under the MIT License.
