# SCE Annotation System

A web application for annotating medical imaging cases with Structured Causal Explanations (SCE).

## Requirements

- Ruby 3.2+
- SQLite3
- Google OAuth2 credentials
- Anthropic API key (for initial annotation extraction)

## Setup (Development)

```bash
# Install dependencies
bundle install

# Configure environment variables
cp .env.example .env
# Edit .env with your Google OAuth and Anthropic API credentials

# Set up database
rails db:migrate

# Import cases from data folder
rails cases:import

# Seed initial annotations (uses Claude API)
rails cases:seed_annotations

# Start with Tailwind CSS watcher
bin/dev
```

Visit `http://localhost:3000`.

## Production Deployment

### 1. Environment Variables

Create `.env` in the project root:

```
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
ANTHROPIC_API_KEY=sk-ant-...
```

### 2. Rails Credentials

Generate a secret key and set up credentials:

```bash
EDITOR="nano" RAILS_ENV=production rails credentials:edit
```

Copy `config/master.key` to the server (this file is gitignored).

### 3. Database and Assets

```bash
export RAILS_ENV=production

bundle install
rails db:migrate
rails cases:import
rails cases:load_annotations
rails assets:precompile
rails tailwindcss:build
```

### 4. Start the Server

```bash
bundle exec puma -C config/puma.rb -e production
```

Or use systemd for process management. Create `/etc/systemd/system/hrad.service`:

```ini
[Unit]
Description=HRAD SCE Annotation System
After=network.target

[Service]
User=deploy
WorkingDirectory=/path/to/HRAD-structured
Environment=RAILS_ENV=production
ExecStart=/path/to/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl enable hrad
sudo systemctl start hrad
```

### 5. Nginx Reverse Proxy

Example `/etc/nginx/sites-available/hrad`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/hrad /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### 6. Google OAuth for Production

Add the production callback URI in [Google Cloud Console](https://console.cloud.google.com/apis/credentials):

```
https://your-domain.com/auth/google_oauth2/callback
```

## Data Format

Place case folders in the `data/` directory. Each folder should be named `case_<id>` (e.g., `case_1`, `case_42`) and contain:

| File | Description |
|------|-------------|
| `report.txt` | Radiology report |
| `causal exploration.txt` | Causal exploration text |
| `ABCDE checklist.xlsx` (or `.csv`) | ABCDE checklist data |
| Image files (optional) | PNG, JPG, etc. |

## Rake Tasks

| Task | Description |
|------|-------------|
| `rails cases:import` | Import cases from `data/` directory |
| `rails cases:load_annotations` | Load initial annotations from `db/initial_annotations.json` |
| `rails cases:seed_annotations` | Re-generate initial annotations via Claude API (requires `ANTHROPIC_API_KEY`) |
