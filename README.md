# LifeOS Automation

Personal automation systems for daily life, built with n8n, Notion, Google Sheets, and AI.

---

## Systems

### Recipe Management (`recipe-system/`)
Capture recipes from photos or text, parse with AI, store in Google Sheets, sync to Notion for meal planning, and auto-generate categorized shopping lists.

- **Web interface** — mobile-friendly camera/text input
- **4 n8n workflows** — intake, Notion sync, shopping list, notes parser
- **Integrations** — Google Cloud Vision, Claude AI, Google Sheets, Notion

[Full setup guide →](recipe-system/README.md)

---

## Shared Config (`shared-config/`)
Common configuration and `.gitignore` rules to keep secrets out of the repo. Future automation systems will share credential patterns defined here.

---

## Repo Structure

```
lifeos-automation/
├── recipe-system/
│   ├── web-interface/       # Mobile web app (index.html)
│   ├── n8n-workflows/       # Importable n8n workflow JSONs
│   ├── docs/                # Notion & Sheets setup guides
│   ├── scripts/             # Helper scripts
│   ├── config.example.json  # Credential template
│   └── README.md            # Recipe system documentation
├── shared-config/
│   └── .gitignore           # Secret protection rules
└── README.md                # This file
```

---

## Future Systems (Planned)

| System | Description | Status |
|--------|-------------|--------|
| Recipe Management | Photo/text → parsed → Notion meal planner | Active |
| Instagram Recipe Extractor | Video recipes → transcription → parsing | Planned |
| Google Tasks Shopping Sync | Notion shopping list → Google Tasks | Planned |

---

## Security

- API keys and tokens are configured in n8n's UI, **not** stored in this repo
- `shared-config/.gitignore` prevents accidental credential commits
- The web interface uses client-side password hashing
- `config.example.json` files show what's needed without containing real values
