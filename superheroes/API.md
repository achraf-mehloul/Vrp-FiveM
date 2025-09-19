# Superheroes System API Documentation

## Events

### Client to Server:
- `superheroes:buyHero` - شراء بطل جديد
- `superheroes:equipHero` - تجهيز بطل
- `superheroes:activateAbility` - تفعيل قدرة

### Server to Client:
- `superheroes:updateEnergy` - تحديث شريط الطاقة
- `superheroes:clientActivateAbility` - تفعيل القدرة على العميل

## Exports

### Client:
- `GetCurrentEnergy()` - الحصول على الطاقة الحالية

### Server:
- `GetPlayerHeroes(source)` - الحصول على أبطال اللاعب
