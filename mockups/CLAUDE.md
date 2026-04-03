# Mockup Conventions

## Structure
One directory per Linear issue: `mockups/<linear-issue-id>/`
- `index.html` — the HTML mockup
- `mockup.png` — Playwright screenshot (committed to repo, linked in Linear comment)

## HTML Mockup Requirements
- Viewport: 375px wide (iPhone standard), full height
- Mimic a real mobile screen: status bar, navigation bar, content area
- Use the design system colors and fonts from docs/memory/designer-memory.md
- All interactive elements should look tappable

## Screenshot Process (Designer agent)
```javascript
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.setViewportSize({ width: 375, height: 812 });
  await page.goto('file:///Volumes/ex-ssd/workspace/mtbox-app/mockups/<issue-id>/index.html');
  await page.waitForTimeout(500);
  await page.screenshot({ path: '/Volumes/ex-ssd/workspace/mtbox-app/mockups/<issue-id>/mockup.png' });
  await browser.close();
})();
```

## Linking in Linear
After committing, use this URL pattern in Linear comments:
`https://raw.githubusercontent.com/levulinh/mtbox-app/main/mockups/<issue-id>/mockup.png`

Embed as markdown image:
`![Mockup](https://raw.githubusercontent.com/levulinh/mtbox-app/main/mockups/<issue-id>/mockup.png)`

## Design System
Tracked in docs/memory/designer-memory.md. Always read it before creating a mockup.
