AWM Digital Showroom V4 FINAL

- index.html: public Digital Showroom (no cart, checkout, payment or shipping workflow)
- admin.html: showroom control center
- AWM_Showroom_V4_Migration.sql: safe database migration
- awm-manifest.webmanifest / awm-sw.js: PWA shell

Database:
Run AWM_Showroom_V4_Migration.sql once after the existing AWM V2 SAFE migration.
It adds showroom-only product flags plus showroom_settings, lookbooks and qr_codes.

Keep awm-logo.jpg beside index.html and admin.html.

New showroom features:
Store Info, Lookbook, QR codes, Media Library, Display/Kiosk Mode, search analytics, dynamic showroom badges, Coming Soon, Last Piece, fast cache, visual pagination, optimized public storage image URLs, realtime catalog refresh, favorites, recent views, recommendations, homepage sections and WhatsApp contact.
