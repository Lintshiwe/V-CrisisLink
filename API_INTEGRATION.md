# CrisisLink API Integration Guide

This document explains how the CrisisLink Vagrant setup automatically configures API keys and integrates with external services.

## How It Works

### 1. Secure API Key Management

- **Template System**: `api-keys.env.template` contains all required API key placeholders
- **Local Configuration**: Users copy the template to `api-keys.env` and customize their keys
- **Git Security**: `.gitignore` prevents `api-keys.env` from being committed to the repository
- **Automatic Injection**: Vagrant reads `api-keys.env` and injects keys into the application

### 2. Vagrant Provisioning Process

When you run `vagrant up`, the system:

1. **Loads API Keys**: Reads `api-keys.env` from the host machine
2. **Creates Environment Files**: Generates backend and frontend `.env` files with actual keys
3. **Updates Source Code**: Replaces hardcoded keys in JavaScript files
4. **Starts Services**: Launches the application with all APIs configured

### 3. API Services Integration

#### Weather & Environmental Services

- **OpenWeatherMap**: Weather monitoring for South African provinces
- **Ambee Environmental**: Natural disaster detection and air quality monitoring
- **USGS Earthquake**: Real-time seismic activity monitoring (no key required)
- **Open-Meteo**: Fallback weather service (no key required)

#### Mapping & Geolocation

- **Google Maps JavaScript API**: Interactive emergency response maps
- **Google Firebase API**: Real-time database and push notifications

#### Communication Services

- **Twilio SMS/Voice**: Emergency alerts and communication (optional)

### 4. Configuration Files

The provisioning script automatically creates:

#### Backend Environment (`/home/vagrant/CrisisLink/backend/.env`)

```env
OPENWEATHER_API_KEY=your_actual_key
GOOGLE_MAPS_API_KEY=your_actual_key
GOOGLE_API_KEY=your_actual_key
FIREBASE_API_KEY=your_actual_key
AMBEE_API_KEY=your_actual_key
TWILIO_ACCOUNT_SID=your_actual_sid
TWILIO_AUTH_TOKEN=your_actual_token
JWT_SECRET=your_actual_secret
```

#### Frontend Environment (`/home/vagrant/CrisisLink/frontend/.env`)

```env
REACT_APP_GOOGLE_MAPS_API_KEY=your_actual_key
REACT_APP_GOOGLE_API_KEY=your_actual_key
REACT_APP_FIREBASE_API_KEY=your_actual_key
REACT_APP_OPENWEATHER_API_KEY=your_actual_key
```

### 5. Source Code Updates

The system also updates hardcoded keys in:

- `backend/src/services/ambeeService.js` - Ambee API key
- `frontend/public/sw.js` - Firebase configuration
- `backend/src/services/liveWeatherService.js` - OpenWeather backup keys

## Security Features

### 1. Git Protection

- `api-keys.env` is in `.gitignore`
- Only templates and examples are committed
- No sensitive data in version control

### 2. Environment Isolation

- API keys exist only inside the VM
- Host machine files remain secure
- Easy to rotate and update keys

### 3. Fallback System

- Working default keys for immediate functionality
- Graceful degradation if services are unavailable
- Multiple backup keys for critical services

## Usage Examples

### Setting Up Custom Keys

1. **Copy Template**:

   ```bash
   cp api-keys.env.template api-keys.env
   ```

2. **Edit Keys**:

   ```bash
   nano api-keys.env
   ```

3. **Start System**:
   ```bash
   vagrant up
   ```

### Adding New API Services

To add a new API service:

1. **Add to Template**: Update `api-keys.env.template`
2. **Update Provisioning**: Modify `provision.sh` to include the new key
3. **Update Application**: Modify backend/frontend `.env` creation
4. **Document Usage**: Add to this guide

### Rotating API Keys

1. **Update Local File**:

   ```bash
   nano api-keys.env
   ```

2. **Reprovision VM**:
   ```bash
   vagrant destroy -f
   vagrant up
   ```

## Troubleshooting

### Common Issues

1. **Missing api-keys.env**: System falls back to template values
2. **Invalid API Keys**: Check logs with `vagrant ssh -c "sudo journalctl -u crisislink"`
3. **Permission Issues**: Ensure `api-keys.env` is readable

### Verification Commands

Check if API keys are loaded:

```bash
vagrant ssh -c "cat ~/CrisisLink/backend/.env | grep API_KEY"
```

Test API connectivity:

```bash
vagrant ssh -c "curl 'http://api.openweathermap.org/data/2.5/weather?q=Cape%20Town&appid=YOUR_KEY'"
```

## Production Considerations

### Security Checklist

- [ ] Replace development JWT secret with strong production key
- [ ] Use separate API keys for production environment
- [ ] Enable API key restrictions and quotas
- [ ] Set up monitoring and alerts for API usage
- [ ] Regularly rotate sensitive credentials

### Performance Optimization

- [ ] Configure API rate limiting
- [ ] Implement caching for frequently requested data
- [ ] Set up API health monitoring
- [ ] Use CDN for static map tiles where applicable

This integration ensures that CrisisLink can be deployed quickly and securely while maintaining flexibility for different environments and use cases.
