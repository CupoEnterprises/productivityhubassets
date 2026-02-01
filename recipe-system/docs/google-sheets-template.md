# Google Sheets Template

## Sheet Setup

Create a new Google Sheet and set up the first sheet tab as follows:

### Sheet Name
Rename the first sheet tab to: **Recipes**

### Column Headers (Row 1)

| Column | Header       | Format     | Description                              |
|--------|-------------|------------|------------------------------------------|
| A      | Title       | Plain text | Recipe name                              |
| B      | Description | Plain text | Brief recipe description                 |
| C      | Ingredients | Plain text | Newline-separated ingredient list        |
| D      | Instructions| Plain text | Newline-separated numbered steps         |
| E      | Timestamp   | Date/time  | ISO 8601 format (auto-filled)            |
| F      | Status      | Plain text | "New", "Synced", or "Error"              |

### Example Data (Row 2)

```
Title:        Classic Chicken Parmesan
Description:  Crispy breaded chicken breast topped with marinara and melted mozzarella cheese
Ingredients:  4 boneless skinless chicken breasts
              1 cup all-purpose flour
              3 large eggs
              2 cups Italian breadcrumbs
              1 cup grated Parmesan cheese
              2 cups marinara sauce
              2 cups shredded mozzarella cheese
              1/2 cup olive oil
              1 tsp salt
              1/2 tsp black pepper
              1 tsp garlic powder
              Fresh basil for garnish
Instructions: 1. Preheat oven to 425°F.
              2. Place chicken breasts between plastic wrap and pound to even thickness.
              3. Set up breading station: flour in one dish, beaten eggs in another, breadcrumbs mixed with Parmesan in a third.
              4. Season chicken with salt, pepper, and garlic powder.
              5. Dredge each piece in flour, dip in egg, then coat in breadcrumb mixture.
              6. Heat olive oil in a large oven-safe skillet over medium-high heat.
              7. Cook chicken 3-4 minutes per side until golden brown.
              8. Top each piece with marinara sauce and mozzarella.
              9. Transfer to oven and bake 15-20 minutes until cheese is bubbly.
              10. Garnish with fresh basil and serve.
Timestamp:    2025-01-15T12:00:00.000Z
Status:       New
```

## Getting the Sheet ID

1. Open your Google Sheet in the browser
2. Look at the URL: `https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit`
3. Copy the `SHEET_ID` portion
4. Save this in your config as `google_sheets.sheet_id`

## Formatting Tips

- Set column C and D to **Wrap text** (Format > Text wrapping > Wrap) for readability
- Freeze Row 1 (View > Freeze > 1 row) to keep headers visible
- Optionally add conditional formatting to column F:
  - "New" → Yellow background
  - "Synced" → Green background
  - "Error" → Red background

### Conditional Formatting Setup
1. Select column F (starting from F2)
2. Format > Conditional formatting
3. Add rules:
   - Text is exactly "New" → Custom: Yellow (#FFF3CD)
   - Text is exactly "Synced" → Custom: Green (#D4EDDA)
   - Text is exactly "Error" → Custom: Red (#F8D7DA)

## Google Sheets OAuth2 Setup for n8n

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google Sheets API**:
   - Go to APIs & Services > Library
   - Search for "Google Sheets API"
   - Click Enable
4. Create OAuth2 credentials:
   - Go to APIs & Services > Credentials
   - Click "Create Credentials" > "OAuth client ID"
   - Application type: "Web application"
   - Add authorized redirect URI: `https://your-n8n-instance.example.com/rest/oauth2-credential/callback`
   - Copy the Client ID and Client Secret
5. In n8n:
   - Go to Credentials
   - Add "Google Sheets OAuth2 API" credential
   - Paste Client ID and Client Secret
   - Click "Connect" and authorize with your Google account
