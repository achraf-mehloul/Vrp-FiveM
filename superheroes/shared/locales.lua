local Locales = {
    ar = {
        ['heroes.buy.success'] = 'تم شراء البطل بنجاح',
        ['heroes.buy.failed'] = 'فشل في شراء البطل',
        ['heroes.equip.success'] = 'تم تجهيز البطل بنجاح',
        ['heroes.ability.cooldown'] = 'القدرة في حالة تبريد',
        ['heroes.energy.low'] = 'طاقتك منخفضة'
    },
    en = {
        ['heroes.buy.success'] = 'Hero purchased successfully',
        ['heroes.buy.failed'] = 'Failed to purchase hero',
        ['heroes.equip.success'] = 'Hero equipped successfully',
        ['heroes.ability.cooldown'] = 'Ability is on cooldown',
        ['heroes.energy.low'] = 'Your energy is low'
    }
}

function GetLocale(lang, key)
    return Locales[lang][key] or key
end

return GetLocale
