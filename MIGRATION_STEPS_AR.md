# تركيب تحديث Etzan 1.1 على مشروعك الحالي

بما أن مشروعك المحلي يحتوي بالفعل على `android/` و`ios/`، لا تحذفهما.

1. خذ نسخة احتياطية من المشروع.
2. انسخ من التحديث المجلدات والملفات التالية إلى جذر مشروعك ووافق على الاستبدال:

```text
assets/
lib/
test/
docs/
pubspec.yaml
analysis_options.yaml
```

3. من Terminal داخل المشروع:

```bash
flutter clean
rm -rf .dart_tool pubspec.lock
flutter pub get
flutter run
```

4. لو كان التطبيق مفتوحًا أثناء النسخ، اعمل **Full Restart** وليس Hot Reload فقط؛ لأن التحديث يضيف Assets وDependencies جديدة.

## ملاحظة

الإصدارات في `pubspec.yaml` مختارة لتناسب Flutter 3.32.x / Dart 3.8.x:

```yaml
flutter_svg: 2.2.3
google_fonts: 6.3.1
```
