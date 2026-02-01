# Notion Setup Guide

This guide walks through setting up the Notion workspace for the Recipe Management System.

---

## 1. Create a Notion Integration

1. Go to [notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Click **"New integration"**
3. Name it: `Recipe Manager`
4. Select your workspace
5. Under **Capabilities**, enable:
   - Read content
   - Update content
   - Insert content
6. Click **Submit**
7. Copy the **Internal Integration Secret** (starts with `ntn_`)
8. Save this as `notion.api_key` in your config

---

## 2. Create the Recipes Database

1. In Notion, create a new **full-page database** (type `/database` and select "Database - Full page")
2. Name it: **Recipes**
3. Set up the following properties (columns):

| Property Name   | Type       | Notes                                    |
|-----------------|------------|------------------------------------------|
| Title           | Title      | Default first column - recipe name       |
| Description     | Rich text  | Brief description of the recipe          |
| Ingredients     | Rich text  | Multi-line ingredient list               |
| Instructions    | Rich text  | Multi-line numbered steps                |
| In Weekly Meals | Checkbox   | Check to include in shopping list        |
| Date Added      | Date       | Auto-filled when synced from Sheets      |
| Cooking Notes   | Rich text  | Add timestamped cooking notes here       |
| Version History | Rich text  | Auto-populated by Workflow 4             |

### How to add properties:
1. Click the **+** button at the right of the column headers
2. Name the property
3. Select the property type from the dropdown
4. Repeat for each property

### Get the Database ID:
1. Open the Recipes database in your browser
2. The URL will look like: `https://www.notion.so/{workspace}/{DATABASE_ID}?v=...`
3. Copy the `DATABASE_ID` portion (32-character hex string)
4. Save this as `notion.recipes_database_id` in your config

---

## 3. Connect the Integration to the Database

**This step is required or the API will return "object not found" errors.**

1. Open the **Recipes** database page
2. Click the **...** menu (top-right corner)
3. Scroll down and click **"Connections"** (or "Add connections")
4. Search for **"Recipe Manager"** (your integration name)
5. Click to connect it

---

## 4. Create the Weekly Shopping List Page

1. Create a new page in your workspace
2. Name it: **Weekly Shopping List**
3. Add some placeholder text like "Shopping list will be generated automatically"
4. Connect the integration (same steps as above - **...** > Connections > Recipe Manager)

### Get the Page ID:
1. Open the page in your browser
2. URL: `https://www.notion.so/{PAGE_TITLE}-{PAGE_ID}`
3. The PAGE_ID is the 32-character hex string at the end
4. Save this as `notion.shopping_list_page_id` in your config

---

## 5. Create a "Weekly Meals" View

This is a filtered view of the Recipes database showing only selected meals.

1. Open the **Recipes** database
2. Click **"+ Add a view"** (top-left, next to existing views)
3. Select **Table** view
4. Name it: **Weekly Meals**
5. Click the **Filter** button
6. Add filter: **In Weekly Meals** → **is** → **Checked**
7. Optionally, hide columns you don't need in this view (like Version History)

This gives you a clean view of just the recipes you've selected for the week.

---

## 6. Recommended Workspace Layout

Create a page called **Meal Planning** as your hub:

```
Meal Planning
├── Recipes (database - linked)
├── Weekly Meals (filtered view of Recipes)
├── Weekly Shopping List (page)
└── Archive (optional - for old meal plans)
```

To link the database:
1. In the Meal Planning page, type `/linked`
2. Select **"Linked view of database"**
3. Search for **Recipes**
4. Apply the Weekly Meals filter

---

## 7. Using Cooking Notes

The Cooking Notes field works as a log. When adding notes after cooking:

1. Open a recipe in Notion
2. Go to the **Cooking Notes** property
3. Add your note with a timestamp, for example:
   ```
   [2025-01-15] Used 2 tbsp less salt, was still plenty seasoned.
   [2025-01-22] Doubled the garlic, much better. Add red pepper flakes next time.
   ```
4. Workflow 4 (v2) will parse these notes and suggest ingredient updates

**Format tips:**
- Start each note with `[YYYY-MM-DD]`
- Be specific about quantities when suggesting changes
- Use phrases like "use more", "reduce", "substitute X for Y", "add next time"

---

## Troubleshooting

**"Object not found" errors:**
- Make sure the integration is connected to the database/page (Step 3)
- Verify the database/page IDs are correct (no extra characters)

**Properties not updating:**
- Check that property names match exactly (case-sensitive)
- Ensure the integration has "Update content" capability

**Trigger not firing:**
- Notion triggers in n8n poll at intervals (not real-time)
- Wait for the poll interval to pass (2-5 minutes)
- Check that the workflow is active in n8n
