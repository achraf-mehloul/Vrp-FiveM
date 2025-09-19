# 🚀 VRP FiveM Framework - Custom Scripts

مشروع مطوَّر فوق [vRP Framework](https://github.com/ImagicTheCat/vRP) لتطوير سيرفر **FiveM** متقدم، منظم، وقابل للتوسع.  
يوفر النظام **Modules** و **Core** و **Shared utilities** بشكل نظيف مع دعم قواعد بيانات، HUD مخصص، نظام إدارة عصابات، بنوك، محلات، وحتى إضافات إبداعية (Superheroes, Mini Games, Events...).

---

## 📂 هيكلة المشروع

- **core/** → ملفات أساسية: Config, Database, Events, Logger, Security, Loader.  
- **modules/** → وحدات رئيسية (admin, bank, gangs, hud, pausemenu, shops, superheroes).  
- **shared/** → ثوابت ودوال مشتركة بين الكلاينت والسيرفر.  
- **scripts/** → سكريبتات إضافية (مكافآت يومية، مهمات ديناميكية، ألعاب صغيرة...).  
- **tests/** → اختبارات وحدة (Unit) واندماج (Integration).  
- **tools/** → أدوات مساعدة (Profiler, Auto Deploy, Migration Tool...).  
- **docs/** → وثائق وملفات Markdown (API, Changelog, UML).  

---

## ⚙️ المتطلبات

- [FiveM Server](https://fivem.net/) (محدث لآخر نسخة مستقرة).  
- [vRP Base](https://github.com/ImagicTheCat/vRP) مثبت في السيرفر.  
- قاعدة بيانات MySQL / MariaDB.  
- Node.js (لاستعمال واجهات NUI مع JavaScript).  

---

## 🚀 التنصيب

1. انسخ المشروع داخل مجلد الموارد (`resources/`) في سيرفرك.  
2. فعل الموديلات داخل `server.cfg`:
   ```cfg
   ensure vrp
   ensure core
   ensure modules
   ensure shared
   ensure scripts
   ```
3. ثبت قاعدة البيانات:
   ```bash
   mysql -u root -p your_db < modules/**/sql/001_init.sql
   mysql -u root -p your_db < modules/**/sql/002_indices.sql
   ```
4. شغل السيرفر وتأكد من عمل الموارد بدون أخطاء.

---

## 🕹️ المميزات

- نظام **بنك** متكامل (حسابات، معاملات، تحويلات).  
- HUD ديناميكي مع أصوات وتأثيرات.  
- **عصابات** مع إدارة Blips وواجهات NUI.  
- نظام **محلات** متكامل (ملابس، أكل، أسلحة، سيارات).  
- **Superheroes** Module (قوى خاصة، قدرات، تطوير الشخصيات).  
- أنظمة أمان مدمجة (Anti-Cheat, Firewall, Rate Limiter).  
- أدوات مطور (Profiler, Debug Console, Migration Tool).  

---

## 🧪 الاختبارات

تشغيل اختبارات الوحدة والاندماج:
```bash
lua tests/unit/*.lua
lua tests/integration/*.lua
```

---

## 🤝 المساهمة

1. Fork & Clone.  
2. أنشئ فرع جديد باسم الميزة أو الإصلاح.  
3. التزم باتباع **قواعد الكود** وحدث الاختبارات.  
4. أرسل Pull Request مع وصف التغييرات.  

---

## 📜 الرخصة

سيتم تحديدها لاحقًا (MIT, GPL, أو مخصصة).

---

✍️ **ملاحظة**: المشروع مازال قيد التطوير، بعض الموديلات والوظائف لم تكتمل بعد.
