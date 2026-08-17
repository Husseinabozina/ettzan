# ربط Etzan مع Supabase

المشروع متصل فعليًا بمشروع Supabase باسم `etzan`.

## ما تم ربطه في Flutter

- تهيئة `supabase_flutter` قبل تشغيل التطبيق.
- Sign up حقيقي بالبريد وكلمة المرور.
- Login حقيقي.
- Password reset.
- إنشاء `profile` تلقائيًا عند التسجيل عن طريق Database Trigger.
- Dashboard يقرأ بيانات المستخدم والحجوزات والأهداف من Supabase عند وجود Session.
- Notifications تقرأ من Supabase وتدعم Mark as Read.
- عند عدم وجود مستخدم مسجل، يظل Mock fallback متاحًا لعرض Portfolio/Demo.

## التشغيل

```bash
flutter pub get
flutter run
```

الإعدادات الحالية موجودة كـ defaults داخل `AppEnvironment`، ويمكن استبدالها باستخدام `--dart-define`.

## مهم أمنيًا

الموجود في التطبيق هو Publishable Key فقط، وهو مخصص لتطبيقات العميل. لا تستخدم Service Role Key داخل Flutter نهائيًا.
