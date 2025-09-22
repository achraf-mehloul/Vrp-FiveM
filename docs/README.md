
# 🚀 VRP FiveM Framework - Custom Scripts

مشروع مطوَّر فوق **vRP Framework** لتطوير سيرفر **FiveM** متقدم، منظم، وقابل للتوسع.  
يوفر النظام Modules و Core و Shared utilities بشكل نظيف مع دعم قواعد بيانات، HUD مخصص، نظام إدارة عصابات، بنوك، محلات، وحتى إضافات إبداعية (Superheroes, Mini Games, Events...).

![FiveM Server](https://img.shields.io/badge/FiveM-Server-blue?style=for-the-badge)
![vRP Framework](https://img.shields.io/badge/vRP-Framework-green?style=for-the-badge)
![Lua 5.1+](https://img.shields.io/badge/Lua-5.1+-yellow?style=for-the-badge)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-2.0.0-success?style=for-the-badge)

---

## 📋 محتويات النظام

### 🎯 الأنظمة الأساسية
- 🛠 نظام الإدارة المتقدم - أدوات تحكم كاملة للمشرفين
- 🏦 النظام البنكي - نظام مالي متكامل مع المعاملات
- 📊 نظام الواجهة (HUD) - واجهة مستخدم غنية بالمعلومات
- 🛒 نظام المتاجر - متاجم متعددة مع نظام شراء متكامل
- 🚩 نظام العصابات - إدارة عصابات ونظام صراعات
- 🦸 نظام الأبطال الخارقين - قدرات خاصة ومهارات فريدة

### ⚙️ أنظمة داعمة
- 🔐 نظام الأمان - حماية متقدمة ضد الغش والاستغلال
- 📊 نظام التسجيل - تسجيل الأحداث والتحليلات
- 🗃️ قاعدة البيانات - إدارة بيانات متكاملة
- 🎭 أنظمة إضافية - أنشطة وجوائز يومية وأحداث موسمية

---

## 📁 هيكل المشروع
```
📦 FiveM_System/
├── 📂 core/                 # الملفات الأساسية للنظام
├── 📂 modules/              # الوحدات النمطية الرئيسية
├── 📂 shared/               # الملفات المشتركة بين الأنظمة
├── 📂 scripts/              # سكربتات إضافية
├── 📂 tests/                # اختبارات الجودة والأداء
├── 📂 tools/                # أدوات التطوير والنشر
└── 📂 docs/                 # الوثائق والموارد
```

---

## 🗂️ شجرة الملفات الكاملة
```
📦 FiveM_System/
├── 📂 core/
│   ├── 📂 config/
│   │   ├── client_config.lua
│   │   ├── server_config.lua
│   │   ├── hud_config.lua
│   │   └── modules_config.lua
│   ├── 📂 db/
│   │   ├── connection.lua
│   │   ├── migrations.lua
│   │   ├── queries.lua
│   │   ├── replication.lua
│   │   └── transaction_logger.lua
│   ├── 📂 events/
│   │   ├── event_manager.lua
│   │   ├── event_logger.lua
│   │   └── analytics_logger.lua
│   ├── 📂 logger/
│   │   ├── main_logger.lua
│   │   └── advanced_logger.lua
│   └── 📂 security/
│       ├── anti_cheat.lua
│       ├── anti_exploit.lua
│       ├── firewall.lua
│       ├── rate_limiter.lua
│       └── modules_loader.lua
│
├── 📂 modules/
│   ├── 🛠 admin/
│   │   ├── 📂 client/
│   │   │   ├── main.lua
│   │   │   ├── commands.lua
│   │   │   └── 📂 ui/
│   │   │       ├── index.html
│   │   │       ├── style.css
│   │   │       ├── app.js
│   │   │       └── api.js
│   │   ├── 📂 server/
│   │   │   ├── admin_controller.lua
│   │   │   ├── admin_service.lua
│   │   │   ├── admin_repository.lua
│   │   │   └── commands.lua
│   │   ├── 📂 shared/
│   │   │   ├── admin_config.lua
│   │   │   └── permissions.lua
│   │   ├── 📂 sql/
│   │   │   ├── 001_init.sql
│   │   │   └── 002_indices.sql
│   │   └── fxmanifest.lua
│
│   ├── 🏦 bank/
│   │   ├── 📂 client/
│   │   │   ├── main.lua
│   │   │   └── 📂 ui/
│   │   │       ├── index.html
│   │   │       ├── style.css
│   │   │       ├── app.js
│   │   │       └── api.js
│   │   ├── 📂 server/
│   │   │   ├── bank_controller.lua
│   │   │   ├── bank_service.lua
│   │   │   └── bank_repository.lua
│   │   ├── 📂 shared/
│   │   │   ├── bank_config.lua
│   │   │   └── transactions.lua
│   │   ├── 📂 sql/
│   │   │   ├── 001_init.sql
│   │   │   └── 002_indices.sql
│   │   └── fxmanifest.lua
│
│   ├── 📊 hud/
│   │   ├── 📂 client/
│   │   │   ├── main.lua
│   │   │   ├── events.lua
│   │   │   ├── 📂 ui/
│   │   │   │   ├── index.html
│   │   │   │   ├── style.css
│   │   │   │   ├── app.js
│   │   │   │   └── api.js
│   │   │   └── 📂 sounds/
│   │   │       ├── click.mp3
│   │   │       ├── notification.mp3
│   │   │       └── open.mp3
│   │   ├── 📂 server/
│   │   │   ├── main.lua
│   │   │   └── events.lua
│   │   ├── 📂 shared/
│   │   │   ├── hud_config.lua
│   │   │   └── utils.lua
│   │   └── fxmanifest.lua
│
│   ├── 🛒 shops/
│   │   ├── 📂 client/
│   │   │   ├── main.lua
│   │   │   ├── shop_interaction.lua
│   │   │   ├── blip_manager.lua
│   │   │   ├── player_manager.lua
│   │   │   ├── nui_handler.lua
│   │   │   ├── 📂 ui/
│   │   │   │   ├── index.html
│   │   │   │   ├── style.css
│   │   │   │   ├── app.js
│   │   │   │   └── api.js
│   │   │   └── 📂 assets/images/
│   │   │       ├── 📂 foods/
│   │   │       ├── 📂 weapons/
│   │   │       └── 📂 vehicles/
│   │   ├── 📂 server/
│   │   │   ├── main.lua
│   │   │   ├── shop_controller.lua
│   │   │   ├── shop_service.lua
│   │   │   ├── shop_repository.lua
│   │   │   ├── transaction_manager.lua
│   │   │   ├── admin_commands.lua
│   │   │   └── database.lua
│   │   ├── 📂 shared/
│   │   │   ├── shops_config.lua
│   │   │   ├── items.lua
│   │   │   └── functions.lua
│   │   ├── 📂 sql/
│   │   │   ├── 001_init.sql
│   │   │   └── 002_indices.sql
│   │   └── fxmanifest.lua
│
│   ├── 🚩 gangs/
│   │   ├── 📂 client/
│   │   │   ├── main.lua
│   │   │   ├── gang_ui.lua
│   │   │   ├── blip_manager.lua
│   │   │   └── nui_handler.lua
│   │   ├── 📂 server/
│   │   │   ├── main.lua
│   │   │   ├── gang_controller.lua
│   │   │   ├── gang_service.lua
│   │   │   └── gang_repository.lua
│   │   ├── 📂 shared/
│   │   │   ├── config.lua
│   │   │   ├── locales.lua
│   │   │   └── utils.lua
│   │   ├── 📂 sql/
│   │   │   ├── 001_init.sql
│   │   │   └── 002_indices.sql
│   │   └── fxmanifest.lua
│
│   ├── 🦸 superheroes/
│   │   ├── 📂 client/
│   │   │   ├── main.lua
│   │   │   ├── abilities.lua
│   │   │   ├── nui_handler.lua
│   │   │   ├── power_ui.lua
│   │   │   ├── audio_manager.lua
│   │   │   ├── special_effects.lua
│   │   │   ├── visual_effects.lua
│   │   │   └── 📂 ui/
│   │   │       ├── index.html
│   │   │       ├── style.css
│   │   │       └── app.js
│   │   ├── 📂 server/
│   │   │   ├── main.lua
│   │   │   ├── hero_controller.lua
│   │   │   ├── hero_service.lua
│   │   │   ├── hero_repository.lua
│   │   │   ├── cooldown_manager.lua
│   │   │   ├── security_system.lua
│   │   │   ├── stats_system.lua
│   │   │   └── upgrade_system.lua
│   │   ├── 📂 shared/
│   │   │   ├── config.lua
│   │   │   ├── locales.lua
│   │   │   ├── powers_catalog.lua
│   │   │   ├── powers.lua
│   │   │   └── utils.lua
│   │   ├── 📂 sql/
│   │   │   ├── 001_init.sql
│   │   │   └── 002_indices.sql
│   │   └── fxmanifest.lua
│
│   └── 💀 kill_feed/
│       ├── fxmanifest.lua
│       ├── 📂 shared/
│       │   └── config.lua
│       ├── 📂 server/
│       │   └── main.lua
│       └── 📂 client/
│           ├── main.lua
│           └── 📂 ui/
│               ├── index.html
│               ├── style.css
│               ├── app.js
│               ├── api.js
│               └── 📂 sounds/
│                   ├── pistol_shot.ogg
│                   ├── knife_stab.ogg
│                   ├── sniper_shot.ogg
│                   ├── rifle_shot.ogg
│                   ├── shotgun_shot.ogg
│                   ├── smg_shot.ogg
│                   ├── headshot.ogg
│                   ├── knife_kill.ogg
│                   ├── double_kill.ogg
│                   ├── suicide.ogg
│                   └── default.ogg
│
├── 📂 shared/
│   ├── constants.lua
│   ├── enums.lua
│   ├── events_registry.lua
│   ├── global_state_manager.lua
│   └── utils.lua
│
├── 📂 scripts/
│   ├── daily_rewards.lua
│   ├── dynamic_missions.lua
│   ├── mini_games.lua
│   ├── player_competitions.lua
│   ├── seasonal_events.lua
│   └── training_modules.lua
│
├── 📂 tests/
│   ├── 📂 integration/
│   │   ├── db_connection_tests.lua
│   │   ├── events_flow_tests.lua
│   │   └── stress_tests.lua
│   └── 📂 unit/
│       ├── hud_tests.lua
│       ├── bank_tests.lua
│       ├── shops_tests.lua
│       └── gangs_tests.lua
│
└── 📂 tools/
    ├── auto_deploy.lua
    ├── debug_console.lua
    ├── migration_tool.lua
    └── profiler.lua

```

---

## ⚡ مميزات النظام

### ✅ ميزات فنية
- بناء modular - كل نظام مستقل وقابل للتطوير
- أداء عالي - محسن لأفضل أداء في FiveM
- أمان متقدم - طبقات حماية متعددة
- قاعدة بيانات - نظام مهجرات وتحديثات تلقائية
- نمط MVC - نموذج Model-View-Controller متكامل

### ✅ ميزات للمطورين
- توثيق كامل - كود مفسر وواضح
- اختبارات متكاملة - اختبارات وحدة وتكامل
- أدوات تطوير - أدوات مساعدة للتطوير
- قابلية التوسع - إضافة أنظمة جديدة بسهولة

---

## ⚙️ المتطلبات
- FiveM Server (محدث لآخر نسخة مستقرة)
- vRP Framework مثبت في السيرفر
- قاعدة بيانات MySQL / MariaDB
- Node.js (لاستعمال واجهات NUI مع JavaScript)
- معرفة أساسية بـ Lua و JavaScript

---

## 🚀 التنصيب والإعداد

### المتطلبات الأساسية
```bash
# تأكد من تثبيت المتطلبات
- FiveM Server
- MySQL Database
- vRP Framework
```

### خطوات التثبيت

1. **نسخ الملفات**
```bash
cd resources
git clone https://github.com/achraf-mehloul/fivem-system.git [local]
```

2. **إعداد قاعدة البيانات**
```sql
CREATE DATABASE fivem_server;
```

3. **تعديل الإعدادات**
```lua
-- core/config/server_config.lua
Config.Database = {
    host = "localhost",
    database = "fivem_server",
    username = "root",
    password = "password"
}
```

4. **تشغيل النظام في server.cfg**
```cfg
ensure vrp
ensure core
ensure modules
ensure shared
ensure scripts
```

5. **تثبيت جداول قاعدة البيانات**
```bash
mysql -u root -p your_db < modules/admin/sql/001_init.sql
mysql -u root -p your_db < modules/bank/sql/001_init.sql
# ... كرر لكل وحدة
```

---

## 🕹️ الاستخدام والتهيئة

### تهيئة وحدة الإدارة
```lua
-- modules/admin/shared/admin_config.lua
Config.Admin = {
    permissions = {
        "kick",
        "ban", 
        "teleport",
        "spawn_vehicle"
    },
    log_actions = true,
    enable_commands = true
}
```

### تهيئة النظام البنكي
```lua
-- modules/bank/shared/bank_config.lua
Config.Bank = {
    interest_rate = 0.05,
    transfer_fee = 0.02,
    max_withdrawal = 10000,
    enable_atm = true
}
```

---

## 🧪 الاختبارات

### اختبارات الوحدة
```bash
cd tests/unit
lua hud_tests.lua
lua bank_tests.lua
lua shops_tests.lua
```

### اختبارات التكامل
```bash
cd tests/integration
lua db_connection_tests.lua
lua events_flow_tests.lua
```

### اختبارات الضغط
```bash
cd tests/integration
lua stress_tests.lua
```

---

## 🛠 التطوير والإضافة

### إضافة نظام جديد
1. إنشاء مجلد جديد في modules/
2. اتباع الهيكل القياسي (client/server/shared/sql)
3. إضافة التهيئة في core/config/modules_config.lua
4. كتابة الاختبارات في tests/unit/

### مثال لإضافة نظام
```lua
-- modules/new_system/fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'shared/*.lua'
}
```

---

## 🤝 المساهمة في المشروع
نرحب بمساهماتكم! لمساهمة:
1. عمل Fork للمشروع
2. إنشاء فرع جديد (git checkout -b feature/AmazingFeature)
3. عمل Commit للتغييرات (git commit -m 'Add AmazingFeature')
4. push إلى الفرع (git push origin feature/AmazingFeature)
5. فتح طلب Pull Request

---

## 📜 الرخصة
هذا المشروع مرخص تحت رخصة **MIT** - انظر ملف LICENSE للتفاصيل.

---

## 👥 المساهمون
- **Achraf Mehloul** — المطور الرئيسي

---

## 📞 الدعم والاتصال
- 📧 Email: achrafmehloul50@gmail.com
- 📱 Phone: +213782675199
- 🐙 GitHub: [achraf-mehloul](https://github.com/achraf-mehloul)


---

## ⚠️ ملاحظات هامة
- المشروع مازال قيد التطوير، بعض الموديلات والوظائف لم تكتمل بعد
- يوصى بعدم استخدامه في بيئة production حتى الإصدار النهائي
- تأكد من اختبار جميع الوظائف قبل النشر على السيرفر الرئيسي

