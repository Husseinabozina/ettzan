# إصلاح التبويظ وإكمال Refactor تطبيق Etzan

## تشخيص الخراب (3 مشاكل أساسية)
1. **ملفات journal وcoaching في مكان غلط**: `lib/features/journal/pages/` و `lib/features/coaching/pages/` لازم يكونوا تحت `presentation/` — ده بيكسر 25 import (الراوتر + الملفات الداخلية كلها بتستورد من `presentation/...`).
2. **شاشة الرئيسية للمستخدم المسجل ضايعة**: `home_dashboard_page.dart` (`HomeDashboardScreen`) مش موجودة خالص — بس الـ Cubit والـ domain كاملين وموجودين.
3. **ملفات الترجمة محذوفة**: `assets/translations/` فاضية، والكود بيستخدم 347 مفتاح. النسخة الوحيدة الموجودة في كاش البيلد فيها 117 مفتاح بس.

## المرحلة 0: حماية قبل أي تعديل
- `git init` + commit أولي للمشروع كله كـ snapshot — عشان أي حاجة تحصل نقدر نرجع، والمشروع رايح للجيت هاب أصلًا.

## المرحلة 1: إصلاح البنية المكسورة
1. نقل `lib/features/journal/{pages,components}/` → `lib/features/journal/presentation/{pages,components}/` (نقل المجلدات هيصلح كل الـ imports المكسورة مرة واحدة بدون تعديل كود، لأن كل الاستيرادات أصلاً بتحتسب مسار `presentation/`).
2. نفس النقل لـ `lib/features/coaching/`.
3. إعادة كتابة `lib/features/dashboard/presentation/pages/home_dashboard_page.dart` بيها `HomeDashboardScreen`:
   - `BlocBuilder` على `DashboardCubit` بحالات loading / failure / success.
   - Success: تحية بالاسم + الرسالة التحفيزية اليومية (dailyNudge)، مؤشر التقدم الشهري، إحصائيات (جلسات مكتملة / ساعات دعم / مهام مكتملة)، كارت الجلسة القادمة لو موجودة.
   - نفس الـ design system بتاع `GuestHomePage` (EtzanShell, EtzanCard, AdaptiveGrid, EtzanIconTile) وكل النصوص `LocaleKeys.xxx.tr(context: context)`.

## المرحلة 2: استرجاع الترجمات (أصعب شغلة)
4. نسخ `ar.json` و `en.json` من كاش البيلد (`build/app/intermediates/flutter/debug/flutter_assets/assets/translations/`) لـ `assets/translations/` كأساس موثوق (117 مفتاح).
5. استخراج قائمة الـ 230 مفتاح الناقص بمقارنة `locale_keys.g.dart` بالـ JSON.
6. لكل مفتاح ناقص: تحديد سياق استخدامه في الكود (`grep` على `LocaleKeys.xxx`) وكتابة قيمة عربية + إنجليزية مناسبة، مع الالتزام بصيغة الـ placeholders (`{name}`) في المفاتيح اللي بتستقبل args.
7. التأكد إن `ar.json` و `en.json` عندهم نفس المفاتيح بالظبط.
   - ملاحظة: القيم العربية الثابتة في `journal_labels.dart` ('امتنان'، 'قلق'...) هي قيم بيانات بتتخزن في Supabase مش نصوص واجهة — تفضل زي ما هي زي ما اتفقنا قبل كده.

## المرحلة 3: فصل auth_screens.dart (آخر ملف مجمّع، 617 سطر)
8. تفكيكه لـ:
   - `presentation/pages/`: splash, onboarding_goals, onboarding_coach, login, sign_up.
   - `presentation/components/`: الـ layout المشترك والـ widgets الخاصة (_AuthLayout, _SoftOrb, _OnboardingLayout).
   - الحفاظ على زر "الدخول كضيف" المضاف في Login/SignUp/Onboarding.
   - حذف `auth_screens.dart` وتحديث `app_router.dart`.

## المرحلة 4: التحقق الكامل
9. `./tool/generate_localization.sh` — إعادة توليد `LocaleKeys` من الـ JSON الجديد (لو الأسماء صح، هيتطابق مع الموجود).
10. `dart format` + `flutter analyze` → صفر أخطاء.
11. `flutter test` → كل الاختبارات تعدّي.
12. `python3 tool/quality_check.py` → لازم يعدّي بـ 26 شاشة (هيرجع 26 مع رجوع HomeDashboardScreen).
13. Commit لكل مرحلة على حدة في الجيت الجديد.

## النتيجة النهائية المتوقعة
- كل الـ features السبعة على نفس البنية: `presentation/{pages,components}` بدون أي ملف `*_screens.dart` مجمّع.
- صفر نصوص UI عربية ثابتة، الترجمة كاملة عربي/إنجليزي مع RTL/LTR.
- Guest mode شغال مع حماية الراوتر.
- كل الـ checks خضرا وجاهز للجيت هاب.