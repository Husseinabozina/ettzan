# اتزان — Flutter Life Coaching App

نسخة 1.1 تتضمن إعادة تصميم فعلية للواجهات الرئيسية، رسومات SVG أصلية، شعار اتزان، خط Tajawal، Icon System خاص، ودعم RTL/LTR وResponsive.

## تشغيل المشروع

```bash
flutter pub get
flutter run
```

## أهم الحزم

- `flutter_bloc`: إدارة حالة الـDashboard والتنبيهات.
- `get_it`: Dependency Injection.
- `equatable`: حالات وكيانات قابلة للمقارنة.
- `flutter_svg`: الشعار والرسومات والأيقونات الخاصة.
- `google_fonts`: تطبيق Tajawal بصورة صريحة.

## المعمارية

```text
lib/
├── app/
├── core/
│   ├── design_system/
│   ├── di/
│   ├── error/
│   ├── network/
│   └── widgets/
└── features/
    ├── dashboard/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── notifications/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── ...
```

للقائمة الكاملة وخطة نقل بقية الميزات إلى Clean Architecture راجع:

```text
docs/REVAMP_PLAN_AR.md
```
