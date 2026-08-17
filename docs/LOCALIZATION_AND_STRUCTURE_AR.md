# تنظيم Etzan والترجمة

## قاعدة الترجمة

أي نص يراه المستخدم يُضاف في الملفين المتطابقين:

- `assets/translations/ar.json`
- `assets/translations/en.json`

بعد أي تعديل شغّل:

```bash
./tool/generate_localization.sh
```

ثم استخدم المفتاح المولّد، وليس النص نفسه، داخل الواجهة:

```dart
LocaleKeys.goalsLoadError.tr(context: context)
```

القيم الديناميكية تستعمل `namedArgs`:

```json
{ "welcomeUser": "مرحبًا {name}" }
```

```dart
LocaleKeys.welcomeUser.tr(context: context, namedArgs: {'name': user.name})
```

## شكل أي feature جديدة

```text
features/<feature>/
  data/
    datasources/
    dto/
    mappers/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    cubit/
    pages/
    components/
```

- `pages/`: تنسيق الشاشة وربط الـCubit فقط.
- `components/`: widgets خاصة بالـfeature ولا تُحمّل بيانات بنفسها.
- `core/widgets/`: widgets عامة بين أكثر من feature، مثل `AppErrorState`.
- الـCubit وطبقة `data` لا تحتوي نصوص واجهة؛ تعيد code/failure، وتُحوّل الرسالة إلى ترجمة داخل الصفحة.

اكتمل نقل جميع الـfeatures إلى هذا التقسيم، ولم يتبقَّ أي ملفات مجمّعة باسم `*_screens.dart`. أي feature جديدة تتبع نفس الشكل من البداية.
