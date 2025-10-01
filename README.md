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

## 🔑 API Keys

For full functionality, you need to set up the following API keys:

1. **Google Maps API Key**
2. **Firebase Service Account**
3. **OpenWeatherMap API Key**
4. **Twilio Account SID and Auth Token**

To add these keys, SSH into the VM and edit the environment files:

```bash
vagrant ssh
nano ~/CrisisLink/backend/.env
nano ~/CrisisLink/frontend/.env
```

After updating the keys, restart the application:

```bash
sudo systemctl restart crisislink
```

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
