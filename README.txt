AWM V2 PRO PACKAGE
==================
Files:
- index.html       storefront
- admin.html       admin dashboard
- AWM_Supabase_V2_Migration.sql   database setup
- awm-manifest.webmanifest         PWA manifest
- awm-sw.js                        service worker

IMPORTANT:
1) Keep your existing awm-logo.jpg in the same folder as index.html and admin.html.
2) Run AWM_Supabase_V2_Migration.sql in Supabase SQL Editor.
3) Make sure your existing products table contains the columns used by the original project.
4) Supabase Realtime must be enabled for products/homepage_sections/offers (the migration attempts to add them).
5) The frontend uses the publishable/anon key only; keep database RLS enabled.
