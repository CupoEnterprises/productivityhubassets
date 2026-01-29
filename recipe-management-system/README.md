# Recipe Management System

A mobile-friendly web app that captures recipes from photos or text, parses them with AI, stores them in Google Sheets, syncs to Notion for meal planning, and generates categorized shopping lists.

---

## Architecture

```
┌──────────────┐     POST      ┌─────────────────────────────────────────────┐
│  Mobile Web  │──────────────>│  n8n Workflow 1: Recipe Intake              │
│  Interface   │               │                                             │
│  (index.html)│               │  Webhook ──> IF image? ──> Google Vision   │
│              │               │                    │           (OCR)        │
│  - Camera    │               │                    │             │          │
│  - Text      │               │                    └─> Claude API ────────>│
│  - Submit    │               │                         (parse recipe)     │
└──────────────┘               │                              │             │
                               │                    Google Sheets (append)  │
                               └──────────────────────┬──────────────────────┘
                                                      │
                                                      v
                               ┌─────────────────────────────────────────────┐
                               │  Google Sheets                              │
                               │  "Recipes" tab                              │
                               │                                             │
                               │  Title | Description | Ingredients |        │
                               │  Instructions | Timestamp | Status          │
                               └──────────────────────┬──────────────────────┘
                                                      │
                                                      v  (polls every 5 min)
                               ┌─────────────────────────────────────────────┐
                               │  n8n Workflow 2: Notion Recipe Sync         │
                               │                                             │
                               │  Sheets Trigger ──> Filter "New" ──>       │
                               │  Create Notion Page ──> Update "Synced"    │
                               └──────────────────────┬──────────────────────┘
                                                      │
                                                      v
┌──────────────────────────────────────────────────────────────────────────────┐
│  Notion Workspace                                                            │
│                                                                              │
│  ┌─────────────────────┐    ┌──────────────────┐    ┌─────────────────────┐ │
│  │  Recipes Database    │    │  Weekly Meals    │    │  Weekly Shopping    │ │
│  │                      │    │  (filtered view) │    │  List (page)       │ │
│  │  - Title             │    │                  │    │                     │ │
│  │  - Description       │    │  Shows recipes   │    │  Auto-generated    │ │
│  │  - Ingredients       │    │  where "In       │    │  categorized list  │ │
│  │  - Instructions      │    │  Weekly Meals"   │    │                     │ │
│  │  - In Weekly Meals ☐ │───>│  is checked      │    │  - Produce         │ │
│  │  - Date Added        │    │                  │    │  - Meat & Seafood  │ │
│  │  - Cooking Notes     │    └──────────────────┘    │  - Dairy & Eggs    │ │
│  │  - Version History   │              │             │  - Pantry          │ │
│  └─────────────────────┘              │             │  - Frozen          │ │
│           │                            v             │  - Bakery          │ │
│           │              ┌─────────────────────┐    │  - Other           │ │
│           │              │ n8n Workflow 3:      │    │                     │ │
│           │              │ Shopping List Gen    │───>│                     │ │
│           │              │                     │    └─────────────────────┘ │
│           │              │ Fetches checked     │                            │
│           │              │ recipes, combines   │                            │
│           │              │ & categorizes       │                            │
│           │              │ ingredients         │                            │
│           │              └─────────────────────┘                            │
│           │                                                                  │
│           v  (v2)                                                            │
│  ┌─────────────────────────────┐                                            │
│  │ n8n Workflow 4:              │                                            │
│  │ Recipe Notes Parser          │                                            │
│  │                              │                                            │
│  │ Watches Cooking Notes ──>   │                                            │
│  │ Claude AI parse ──>         │                                            │
│  │ Update ingredients +        │                                            │
│  │ Version History             │                                            │
│  └─────────────────────────────┘                                            │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Setup Instructions

### Prerequisites

- [n8n](https://n8n.io/) instance (self-hosted or cloud)
- Google account (for Sheets and Cloud Vision)
- Notion account (free tier works)
- Anthropic API account (for Claude)

### Step 1: Google Cloud Setup

#### Google Cloud Vision API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select existing)
3. Navigate to **APIs & Services** > **Library**
4. Search for and enable **Cloud Vision API**
5. Go to **APIs & Services** > **Credentials**
6. Click **Create Credentials** > **API Key**
7. Copy the API key
8. (Recommended) Restrict the key to Cloud Vision API only

#### Google Sheets API
1. In the same project, enable **Google Sheets API**
2. Create **OAuth 2.0 Client ID** credentials:
   - Application type: Web application
   - Authorized redirect URI: `https://{your-n8n-url}/rest/oauth2-credential/callback`
3. Note the Client ID and Client Secret

### Step 2: Anthropic API Key
1. Go to [console.anthropic.com](https://console.anthropic.com/)
2. Navigate to **Settings** > **API Keys**
3. Create a new API key
4. Copy and save the key securely

### Step 3: Notion Setup
Follow the detailed guide in [docs/notion-setup-guide.md](docs/notion-setup-guide.md):
1. Create a Notion integration
2. Create the Recipes database with all properties
3. Create the Weekly Shopping List page
4. Connect the integration to both
5. Note the database ID and page ID

### Step 4: Google Sheets Setup
Follow [docs/google-sheets-template.md](docs/google-sheets-template.md):
1. Create a new Google Sheet
2. Set up the Recipes tab with column headers
3. Note the Sheet ID from the URL

### Step 5: n8n Configuration

#### Environment Variables
Set these in your n8n environment (Settings > Variables, or via env vars):

| Variable                    | Value                           |
|----------------------------|---------------------------------|
| `GOOGLE_VISION_API_KEY`    | Your Cloud Vision API key       |
| `ANTHROPIC_API_KEY`        | Your Anthropic API key          |
| `GOOGLE_SHEET_ID`          | Your Google Sheet ID            |
| `NOTION_RECIPES_DB_ID`     | Notion Recipes database ID      |
| `NOTION_SHOPPING_LIST_PAGE_ID` | Notion Shopping List page ID |

#### Credentials in n8n
Create these credentials in n8n (Settings > Credentials):

1. **Google Sheets OAuth2**: Use your OAuth Client ID and Secret
2. **Notion API**: Use your Internal Integration Token

#### Import Workflows
1. In n8n, go to **Workflows** > **Import from File**
2. Import each workflow JSON from the `workflows/` directory:
   - `workflow1-recipe-intake.json`
   - `workflow2-notion-recipe-sync.json`
   - `workflow3-shopping-list-generator.json`
   - `workflow4-recipe-notes-parser.json` (v2 - optional)
3. Open each workflow and update credential references:
   - Click each Google Sheets node > Select your Google Sheets credential
   - Click each Notion node > Select your Notion credential
4. **Activate** each workflow (toggle in top-right)

### Step 6: Web Interface Setup

1. Open `index.html` in a text editor
2. Update the `CONFIG` object near the bottom:
   ```javascript
   const CONFIG = {
     WEBHOOK_URL: 'https://your-n8n.example.com/webhook/recipe-intake',
     PASSWORD_HASH: 'your-sha256-hash-here'
   };
   ```
3. To generate a password hash:
   - Open `index.html` in a browser
   - Open browser Developer Tools (F12) > Console
   - Run: `generatePasswordHash('your-chosen-password')`
   - Copy the SHA-256 hash and paste into `PASSWORD_HASH`
4. Host the file:
   - **Option A**: Serve from n8n using a static file workflow
   - **Option B**: Upload to any static hosting (Netlify, Vercel, GitHub Pages)
   - **Option C**: Open directly from your phone's file system

---

## Usage

### Adding a Recipe

1. Open the web app on your phone
2. Enter your password
3. Choose **Photo** or **Paste Text** tab
4. **Photo**: Tap the camera area to photograph a cookbook page
5. **Text**: Paste or type the recipe text
6. Tap **Submit Recipe**
7. The recipe will be parsed and appear in your Google Sheet within seconds
8. Within 5 minutes, it will sync to your Notion Recipes database

### Planning Weekly Meals

1. Open Notion and go to your **Recipes** database
2. Check the **"In Weekly Meals"** checkbox for recipes you want this week
3. Within a few minutes, your **Weekly Shopping List** page will update automatically
4. The list is organized by store section for efficient shopping

### Adding Cooking Notes (v2)

1. Open a recipe in Notion
2. Add notes to the **Cooking Notes** property
3. Format: `[YYYY-MM-DD] Your note here`
4. If your note suggests ingredient changes, Workflow 4 will:
   - Parse the note with AI
   - Update ingredients if changes are detected
   - Log the change in Version History

### Resetting Weekly Meals

After shopping, uncheck all **"In Weekly Meals"** checkboxes to clear your list. The shopping list page will update to show no items.

---

## Cost Estimates

| Service              | Free Tier                          | Estimated Monthly Cost   |
|---------------------|------------------------------------|--------------------------|
| Google Cloud Vision | 1,000 requests/month free          | $0 for typical home use  |
| Anthropic (Claude)  | Pay per token                      | ~$0.50-2.00/month*       |
| Google Sheets API   | Generous free tier                 | $0                       |
| Notion API          | Free for integrations              | $0                       |
| n8n                 | Self-hosted: free; Cloud: from $20 | $0-20                    |

*Claude cost estimate assumes ~50 recipes/month at ~500 tokens each using claude-sonnet-4-5-20250929.

---

## Troubleshooting

### Web Interface

**"Webhook URL not configured" error**
- Edit `index.html` and set `CONFIG.WEBHOOK_URL` to your n8n webhook URL

**"Failed to submit recipe" error**
- Check that your n8n instance is running and Workflow 1 is active
- Verify the webhook URL is correct (test in browser: visit the URL and check for a response)
- Check browser console (F12) for detailed error messages
- Ensure CORS is not blocking the request (the workflow includes CORS headers)

**Password not working**
- Make sure you generated the hash correctly using `generatePasswordHash()`
- The hash comparison is case-sensitive

### n8n Workflows

**Workflow 1 - Recipe not parsed correctly**
- Check the Claude API response in the n8n execution log
- Ensure your Anthropic API key is valid and has credits
- For images: verify Google Cloud Vision returned text (check execution log)

**Workflow 2 - Recipes not syncing to Notion**
- Verify the workflow is active (green toggle)
- Check that Google Sheets trigger is detecting new rows
- Confirm Notion integration is connected to the database
- Check property names match exactly (case-sensitive)

**Workflow 3 - Shopping list not updating**
- Verify the workflow is active
- Check that "In Weekly Meals" checkbox changes are detected
- Confirm the shopping list page ID is correct
- Check that the integration has access to the page

**Google Sheets "403 Forbidden" error**
- Re-authorize the Google Sheets OAuth2 credential in n8n
- Ensure the Google Sheets API is enabled in Cloud Console

**Notion "object not found" error**
- Confirm the integration is connected to the database/page
- Verify IDs are correct (32-character hex strings, no dashes)

---

## File Structure

```
recipe-management-system/
├── index.html                              # Mobile web interface
├── config.example.json                     # Configuration template
├── README.md                               # This file
├── workflows/
│   ├── workflow1-recipe-intake.json        # Photo/text → parse → Sheets
│   ├── workflow2-notion-recipe-sync.json   # Sheets → Notion sync
│   ├── workflow3-shopping-list-generator.json  # Meal plan → shopping list
│   └── workflow4-recipe-notes-parser.json  # Cooking notes → updates (v2)
├── docs/
│   ├── notion-setup-guide.md              # Notion workspace setup
│   └── google-sheets-template.md          # Sheets template and OAuth setup
└── scripts/
    └── generate-password-hash.sh          # CLI password hash generator
```

---

## V2 Features (Planned)

These features are documented for future implementation:

### Instagram Video Recipe Extraction
**Approach**: Use n8n's HTTP Request node to call Instagram's oEmbed API or a scraping service to extract video URLs. Then use a transcription service (Whisper API or Google Speech-to-Text) to convert audio to text. Feed the transcription through the existing Claude parsing pipeline.

### Google Keep / Google Tasks Shopping List Sync
**Approach**: Use Google Tasks API (more reliable than Keep, which lacks an official API) to create a task list mirroring the Notion shopping list. Add a node at the end of Workflow 3 that creates/updates a Google Tasks list with each item as a task. This allows checking items off on a phone via Google Tasks app.

### Recipe Note Auto-Updating with Version History
**Approach**: Workflow 4 provides the framework. Full implementation would:
1. Detect specific modification phrases in cooking notes
2. Apply changes to ingredients with confidence scoring
3. Maintain full version history with diffs
4. Allow rollback by selecting a version from history
5. Notify via email/Slack when auto-modifications are made
