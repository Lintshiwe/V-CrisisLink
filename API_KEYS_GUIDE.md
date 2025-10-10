# CrisisLink API Keys Guide

This guide explains how to obtain and configure all required API keys for the CrisisLink application.

## API Keys Overview

CrisisLink requires the following API keys for full functionality:

| Service         | Purpose                               | Required |
| --------------- | ------------------------------------- | -------- |
| OpenWeather API | Weather alerts and conditions         | Yes      |
| Firebase API    | Authentication and push notifications | Yes      |
| Google Maps API | Location services and mapping         | Yes      |
| Twilio API      | SMS and call services                 | Optional |

## How to Obtain API Keys

### 1. OpenWeather API Key

1. Visit [OpenWeather Sign Up](https://home.openweathermap.org/users/sign_up)
2. Create a free account
3. Navigate to the "API Keys" tab
4. Copy your API key
5. Note: New keys may take a few hours to activate

### 2. Firebase API Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Navigate to Project Settings > General
4. Under "Your apps", find the Web app or add a new one
5. Copy the `apiKey` value from the Firebase configuration

### 3. Google Maps API Key

1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API
4. Create API credentials > API Key
5. Restrict the key to only the required APIs

### 4. Twilio API (Optional)

1. Sign up at [Twilio](https://www.twilio.com/try-twilio)
2. From your Dashboard, locate:
   - Account SID
   - Auth Token
   - Twilio Phone Number

## Configuring API Keys

### Current API Keys

The project is currently configured with these API keys:

- **Google/Firebase API Key**: `AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8`
- **Google Maps API Key**: `AIzaSyCQA8VqX84ND_7IuJVBjC8PvbiGr4m-Awc`
- **OpenWeather API Key**: Needs configuration
- **Twilio Keys**: Need configuration

### Option 1: Environment Variables

Set these environment variables on your system:

```bash
# Frontend Environment Variables
export REACT_APP_API_URL="http://localhost:5000/api"
export REACT_APP_SOCKET_URL="http://localhost:5000"
export REACT_APP_GOOGLE_API_KEY="AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8"
export REACT_APP_FIREBASE_API_KEY="AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8"
export REACT_APP_GOOGLE_MAPS_API_KEY="AIzaSyCQA8VqX84ND_7IuJVBjC8PvbiGr4m-Awc"

# Backend Environment Variables
export OPENWEATHER_API_KEY="your_openweather_api_key_needed_here"
export GOOGLE_API_KEY="AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8"
export GOOGLE_MAPS_API_KEY="AIzaSyCQA8VqX84ND_7IuJVBjC8PvbiGr4m-Awc"
export TWILIO_ACCOUNT_SID="your_twilio_account_sid_here"
export TWILIO_AUTH_TOKEN="your_twilio_auth_token_here"
export TWILIO_PHONE_NUMBER="your_twilio_phone_number_here"
```

### Option 2: .env File

Create a `.env` file in the root directory with the following configurations:

#### Frontend Environment (.env in frontend directory)

```env
# Frontend Environment Configuration
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_SOCKET_URL=http://localhost:5000

# Google/Firebase Configuration
REACT_APP_GOOGLE_API_KEY=AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8
REACT_APP_FIREBASE_API_KEY=AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8
REACT_APP_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your_firebase_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
REACT_APP_FIREBASE_APP_ID=your_app_id
REACT_APP_FIREBASE_VAPID_KEY=your_vapid_key

# Google Maps JavaScript API (for mapping and location services)
REACT_APP_GOOGLE_MAPS_API_KEY=AIzaSyCQA8VqX84ND_7IuJVBjC8PvbiGr4m-Awc
```

#### Backend Environment (.env in backend directory)

```env
# CrisisLink Environment Configuration
NODE_ENV=development
PORT=5000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=crisislink_db
DB_USER=postgres
DB_PASSWORD=your_database_password_here

# JWT Configuration
JWT_SECRET=crisislink_super_secret_jwt_key_change_in_production_2024
JWT_EXPIRE=24h

# Weather API
OPENWEATHER_API_KEY=your_openweather_api_key_needed_here

# Twilio Configuration (for SMS/Voice calls)
TWILIO_ACCOUNT_SID=your_twilio_account_sid_here
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
TWILIO_PHONE_NUMBER=your_twilio_phone_number_here

# Firebase/Google Configuration
GOOGLE_API_KEY=AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY_ID=your_firebase_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_firebase_private_key_here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
FIREBASE_CLIENT_ID=your_firebase_client_id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token

# Google Maps JavaScript API
GOOGLE_MAPS_API_KEY=AIzaSyCQA8VqX84ND_7IuJVBjC8PvbiGr4m-Awc

# CORS Configuration
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
```

## Verification

You can verify API keys are configured correctly in the application logs. When the application starts, it will show:

```text
📋 API Keys Status: {"openWeatherApiKey":"configured","firebaseApiKey":"configured","googleMapsApiKey":"configured"}
```

## Security Notes

1. **NEVER commit real API keys to version control in production**
2. The keys included in this documentation are for development only
3. Use environment variables or secure vaults in production
4. Implement API key rotation as a best practice
5. Set appropriate usage restrictions and quotas for your API keys

## Troubleshooting

If API keys are not recognized:

1. Verify the key is correctly formatted with no extra spaces
2. Check environment variable names match exactly
3. Restart the application after adding new keys
4. Check API service dashboards for usage/errors
5. Review application logs for specific API error messages

## Need Help?

If you need assistance with API keys, please contact the project maintainer or refer to the documentation for each service.
