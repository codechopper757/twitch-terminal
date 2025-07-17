# Twitch Launcher

A simple Bash script to browse your currently **live followed Twitch streams**, select one with `fzf`, open chat with `twt`, and launch the stream via `streamlink + mpv`.

## 🔧 Features

- Authenticates with **your Twitch account**
- Lists only **live channels you follow**
- Optional fallback for **custom channels**
- Opens **Twitch chat** in `twt`
- Streams video with `streamlink` + `mpv`
- Clean CLI experience

---

## 🚀 Setup

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/twitch-launcher.git
cd twitch-launcher
```

### 2. Install dependencies

You'll need these installed:

- `yad`
- `fzf`
- `curl`
- `jq`
- `mpv`
- `streamlink`
- `kitty`
- [`twt`](https://github.com/xnaas/twt) (TUI Twitch chat client)

On Arch-based distros:

```bash
yay -S fzf jq streamlink mpv kitty twt yad
```

### 3. Register a Twitch Developer App

1. Go to: https://dev.twitch.tv/console/apps
2. Click **"Register Your Application"**
3. Fill in:
   - **Name:** twitch-launcher (or anything)
   - **OAuth Redirect URL:** `http://localhost`
   - **Category:** Chat Bot
4. Click **Create**

Copy your **Client ID**

---

### 4. Get a User OAuth Token

1. Paste the following URL in your browser (replace `YOUR_CLIENT_ID`):

```
https://id.twitch.tv/oauth2/authorize?response_type=token&client_id=YOUR_CLIENT_ID&redirect_uri=http://localhost&scope=user:read:follows
```

2. Approve the app
3. You'll be redirected to:
   ```
   http://localhost/#access_token=YOUR_TOKEN&scope=user:read:follows
   ```
4. Copy the value of `access_token=...` from the URL

---

### 5. Create your `.env` file

```bash
cp .env.example .env
nano .env
```

Example contents:

```env
TWITCH_CLIENT_ID=your_client_id_here
TWITCH_OAUTH_TOKEN=your_oauth_token_here
```

> ⚠️ `.env` is ignored by Git and should not be committed.

---

## ✅ Usage

```bash
./twitch-launcher.sh
```

- Select a **currently live stream** from your follow list
- Twitch chat opens in a new `kitty` window (via `twt`)
- The stream plays via `streamlink` and `mpv`
- Or choose “Custom...” to enter any channel manually

---

## 📁 Project Files

```
twitch-launcher/
├── twitch-launcher.sh     # Main script
├── .env.example           # Credentials template
├── .gitignore             # Ignores your .env
└── README.md              # You're reading it
```

---

## 🔐 Privacy & Security

- `.env` is **not committed** to Git
- Your OAuth token only allows `read:follows` — it cannot post or access sensitive info
- You can revoke the token anytime from your Twitch account settings

---

## ✅ Future Ideas

- Support `channels.txt` as fallback or favorites
- Sort by viewer count or game
- Python TUI rewrite with live-refresh

PRs welcome!
