# CrisisLink Network Access Guide

This document explains how to configure the CrisisLink application for server deployment and network accessibility across all devices.

## Access from Other Devices on Your Network

The CrisisLink application is configured to be accessible from other devices on your local network.

### Access URLs

#### From the Host Machine (Where Vagrant is running)

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000

#### From Other Devices on Your Network

- **Frontend**: http://YOUR_VM_IP:3000
- **Backend API**: http://YOUR_VM_IP:5000

> **Note:** Replace `YOUR_VM_IP` with the actual IP address displayed when you run `vagrant up`. This IP is shown in the post-up message as "Frontend: http://192.168.x.x:3000".

### Accessing from Mobile Devices, Tablets, or Other Computers

1. **Make sure all devices are on the same WiFi network**

2. **Open a web browser on any device and navigate to the VM's IP address with port 3000**

3. **The CrisisLink emergency response website will load**

## Server Setup and API Assembly

### Automated Provisioning Process

The Vagrant setup automatically provisions all required APIs and services during VM startup:

```bash
# The provision.sh script assembles and configures:
# 1. Backend API server (Node.js/Express)
# 2. Frontend application (React)
# 3. Database connection
# 4. External API integrations
vagrant up
```

### API Integration Points

The following APIs are automatically configured during provisioning:

| API             | Purpose                        | Integration Point  |
| --------------- | ------------------------------ | ------------------ |
| OpenWeather API | Weather data and alerts        | Backend service    |
| Google Maps API | Location services              | Frontend & Backend |
| Firebase API    | Authentication & notifications | Frontend & Backend |
| Twilio API      | SMS notifications (optional)   | Backend service    |

## Network Configuration

### VM Network Configuration

The VM is configured with bridged networking to make it accessible on your local network:

```ruby
# From Vagrantfile
config.vm.network "public_network", bridge: "auto"
```

This enables:

- Direct network access from other devices
- IP address on the same subnet as your host machine
- Automatic discovery of network interfaces

### Port Configuration

Critical ports are forwarded and exposed:

| Port | Service          | Access         |
| ---- | ---------------- | -------------- |
| 3000 | Frontend (React) | Host & Network |
| 5000 | Backend API      | Host & Network |

### Firewall Configuration

The VM firewall is automatically configured to allow inbound connections:

```bash
# Configured during provisioning
sudo ufw allow 3000/tcp
sudo ufw allow 5000/tcp
```

## Troubleshooting Network Access

### If you can't access from other devices

1. **Check if the VM is running:**

   ```bash
   vagrant status
   ```

2. **Verify the services are running:**

   ```bash
   vagrant ssh -c "netstat -tulpn | grep -E '3000|5000'"
   ```

3. **Test connectivity from another device:**

   - Try pinging: `ping <vm-ip-address>`
   - Check if ports are reachable: `telnet <vm-ip-address> 3000`

4. **Restart the VM if needed:**

   ```bash
   vagrant halt
   vagrant up
   ```

5. **Find the actual VM IP address:**
   ```bash
   vagrant ssh -c "ip addr show | grep 'inet 192'"
   ```

## External Access Options

### Ngrok Tunneling (Quick External Access)

To make CrisisLink accessible from the internet:

```bash
# Install Ngrok
winget install ngrok  # On Windows
brew install ngrok    # On macOS

# Authenticate with your auth token
ngrok config add-authtoken 2kuGRv9qW31sXJDXZ3CN4x3pm8a_xijbHSBejJGWoy4khWHx

# Create tunnel to VM's IP and port
# Replace 192.168.x.x with your actual VM IP address
ngrok http 192.168.x.x:3000

# Example with specific IP:
# ngrok http 192.168.8.62:3000

# This provides a public URL like: https://a1b2-c3d4-e5f6.ngrok.io
```

### Step-by-Step Ngrok Setup for CrisisLink

1. **Install Ngrok** if you haven't already:

   ```bash
   winget install ngrok
   ```

2. **Configure your authentication token** (already provided):

   ```bash
   ngrok config add-authtoken 2kuGRv9qW31sXJDXZ3CN4x3pm8a_xijbHSBejJGWoy4khWHx
   ```

3. **Start your CrisisLink VM** if it's not running:

   ```bash
   vagrant up
   ```

4. **Note your VM's IP address** from the startup message

5. **Start Ngrok** to create a tunnel to your VM:

   ```bash
   ngrok http 192.168.x.x:3000  # Replace with your VM's IP
   ```

6. **Copy the Ngrok URL** from the console output (https://xxxx-xxxx-xxxx.ngrok.io)

7. **Share this URL** with anyone who needs to access CrisisLink

> **Note:** The free tier of Ngrok will generate a different URL each time you restart Ngrok, and sessions expire after 2 hours. For persistent URLs, consider upgrading to a paid plan.

### Remote Server Deployment

For production deployment:

1. **Provision a cloud server** (Azure, AWS, DigitalOcean)
2. **Install Docker** and dependencies
3. **Clone repository** and configure environment variables
4. **Build and deploy containers**:
   ```bash
   docker-compose up -d
   ```
5. **Configure domain name** with DNS provider
6. **Set up SSL certificates** with Let's Encrypt

## Mobile Browser Compatibility

You can test the CrisisLink emergency response system on:

- ✅ iPhones/iPads (Safari, Chrome)
- ✅ Android phones/tablets (Chrome, Firefox)
- ✅ Other laptops/computers on the same network
- ✅ Any device with a web browser on your local network

## Monitoring and Maintenance

### Checking Service Status

```bash
# SSH into the VM
vagrant ssh

# Check status of CrisisLink service
sudo systemctl status crisislink

# View application logs
sudo journalctl -u crisislink
```

### Updating the Application

```bash
# SSH into the VM
vagrant ssh

# Navigate to project directory
cd /vagrant

# Pull latest changes
git pull

# Restart service
sudo systemctl restart crisislink
```

## Security Note

The application is configured for development use and accepts connections from any device on the private network. This is safe for local development but should not be used in production without proper security measures.

For questions or assistance, please contact the CrisisLink support team.
