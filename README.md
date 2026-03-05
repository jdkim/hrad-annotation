# SCE Annotation System

A web application for annotating medical imaging cases with Structured Causal Explanations (SCE).

## Requirements

- Ruby 3.2+
- SQLite3
- Google OAuth2 credentials

## Setup

```bash
# Install dependencies
bundle install

# Configure environment variables
cp .env.example .env
# Edit .env with your Google OAuth credentials

# Set up database
rails db:migrate

# Import cases from data folder
rails cases:import
```

## Running

```bash
# Start with Tailwind CSS watcher (recommended for development)
bin/dev

# Or start Puma only
rails server
```

Visit `http://localhost:3000`.

## Production Deployment

```bash
# Set environment variables
export RAILS_ENV=production
export SECRET_KEY_BASE=$(rails secret)

# Or use Rails credentials
EDITOR="nano" rails credentials:edit

# Prepare database and assets
rails db:migrate
rails cases:import
rails assets:precompile
rails tailwindcss:build

# Start server
bundle exec puma -C config/puma.rb
```

## Data Format

Place case folders in the `data/` directory. Each case folder should contain:

| File | Description |
|------|-------------|
| `report.txt` | Radiology report |
| `causal exploration.txt` | Causal exploration text |
| `ABCDE checklist.xlsx` (or `.csv`) | ABCDE checklist data |
| Image files (optional) | PNG, JPG, etc. |

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create an OAuth 2.0 Client ID
3. Add redirect URI: `http://localhost:3000/auth/google_oauth2/callback`
4. Copy Client ID and Secret to `.env`
