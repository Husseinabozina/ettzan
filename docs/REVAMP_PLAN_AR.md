# خطة تطوير واجهات وهندسة تطبيق اتزان

## 1) المشكلات التي عالجتها النسخة 1.1

1. استبدال رسومات الـ onboarding المؤقتة برسومات SVG أصلية قابلة للتكبير دون فقد الجودة.
2. استخدام شعار اتزان الفعلي كـ SVG في Splash وAuth وNavigation Rail.
3. تطبيق خط Tajawal بوضوح من خلال `google_fonts` مع منع الأوزان الخفيفة في النصوص الأساسية.
4. رفع أحجام النصوص الثانوية وتحسين الـline-height والتباين.
5. إنشاء Icon System خاص بالتطبيق باستخدام SVG ثنائي الطبقات بدل الاعتماد الكامل على Material Icons.
6. استبدال Toggle/SegmentedButton البدائي بمكوّن `EtzanSegmentedControl` مخصص.
7. تحسين البطاقات: حدود أهدأ، ظلال ناعمة، مساحات داخلية أكبر، وحالات قراءة/تحديد واضحة.
8. إعادة تصميم الصفحة الرئيسية والتنبيهات وربطهما بمنطق فعلي.
9. إضافة حالات Loading / Error / Empty / Retry وPull-to-refresh.
10. حل مشكلة اقتراب المحتوى من شريط التنقل وإضافة padding سفلي مناسب.

## 2) المعمارية المنفذة

تم تنفيذ Vertical Slices حقيقية لميزتي Dashboard وNotifications:

```text
feature/
├── data/
│   ├── datasources/
│   ├── dto/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    └── cubit/
```

مسار البيانات:

```text
Mock API JSON
    ↓
DTO (أسماء الـAPI)
    ↓
Mapper
    ↓
Domain Entity (مصطلحات الـBusiness)
    ↓
Repository Interface
    ↓
Use Case
    ↓
Cubit / State
    ↓
UI
```

مثال: حقل API باسم `support_hours` يتحول داخل الـDTO إلى `supportHours`، ثم يدخل إلى كيان الـDomain كجزء من `DashboardSummary`. الواجهة لا تعرف شكل JSON ولا اسم endpoint.

## 3) مراحل التطوير الصحيحة لباقي المنتج

### المرحلة A — منفذة في هذه النسخة
- Design System بصري جديد.
- Logo وOnboarding assets.
- Typography وIconography.
- Dashboard وNotifications كـClean Architecture vertical slices.
- Mock API وDependency Injection وCubit.

### المرحلة B
- نقل Sessions وCoaches وBooking إلى Data/Domain/Presentation layers.
- إضافة حالات الحجز والإلغاء وإعادة الجدولة.
- توحيد coach/session entities وعدم تمرير tuples داخل UI.

### المرحلة C
- نقل Goals/Habits/Journal/Subscription إلى نفس البنية.
- إضافة local cache وoffline-first strategy.
- استبدال Mock API بـDio client دون تغيير الـDomain أو الواجهات.
- Golden tests وintegration tests وaccessibility audit.

## 4) مبدأ الاستبدال لاحقًا

عند إضافة Backend حقيقي، يتم استبدال:

```text
MockApiClient
```

بـ:

```text
DioApiClient / GraphQLClient / FirebaseDataSource
```

ولا تتغير:
- Domain entities
- Use cases
- Cubits
- UI widgets

وهذا هو الهدف من Dependency Inversion وClean Architecture.
