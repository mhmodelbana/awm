# AWM Clothing Gallery

ملفات المشروع:
- index.html: معرض الملابس العام — عرض فقط، بدون سلة أو طلبات.
- admin.html: لوحة الإدارة — تسجيل دخول، إضافة/تعديل/حذف، رفع صور، السعر، الحالة، التوفر، المقاسات، الألوان، التمييز والترتيب.
- supabase.sql: الجداول + RLS + Storage policies.
- awm-logo.jpg: اللوجو المرفوع.

## التشغيل
1. افتح Supabase SQL Editor ونفّذ `supabase.sql`.
2. من Authentication > Users أنشئ مستخدم الإدارة (Email + Password).
3. افتح `admin.html` وسجّل الدخول.
4. أضف المنتجات والصور.
5. افتح `index.html` لمشاهدة المعرض.

## الأمان
- المفتاح الموجود في HTML هو Publishable/Client key فقط.
- لا تضع `SUPABASE_SECRET_KEY` في `index.html` أو `admin.html`.
- في المشروع الحالي، أي مستخدم Authenticated يستطيع إدارة المنتجات. إذا أردت قصر الإدارة على حسابات Admin محددة، يمكن إضافة جدول admin_users أو claims قبل النشر العام.

## الهوية
التصميم مبني على اللوجو المرفوع: أسود + أحمر + أبيض، AWM، وعبارة ALWAYS YOUR STORE.
