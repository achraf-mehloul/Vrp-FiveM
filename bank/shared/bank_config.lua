Config = {}

Config.Bank = {
    BankLocations = {
        {
            name = "main_bank",
            coords = vector3(150.0, -1040.0, 29.0),
            blip = {sprite = 434, color = 2, scale = 0.8, name = "Bank"},
            hours = {open = 8, close = 18}
        },
        {
            name = "pacific_standard", 
            coords = vector3(246.0, 223.0, 106.0),
            blip = {sprite = 434, color = 2, scale = 0.8, name = "Bank"},
            hours = {open = 8, close = 18}
        }
    },

    ATMLocations = {
        vector3(89.0, 2.0, 68.0),
        vector3(1167.0, -456.0, 66.0),
        vector3(-386.0, 6046.0, 31.0)
    },

    TransactionSettings = {
        transferFee = 0.01,
        maxTransferAmount = 100000,
        minTransferAmount = 100,
        dailyWithdrawLimit = 50000,
        dailyTransferLimit = 100000
    },

    UI = {
        language = "ar",
        currency = "$",
        currencyPosition = "before"
    }
}

Config.NotificationMessages = {
    insufficient_funds = "💰 لا تملك رصيد كافي",
    transfer_success = "✅ تم التحويل بنجاح",
    transfer_failed = "❌ فشل في التحويل",
    invalid_amount = "❌ المبلغ غير صالح",
    player_offline = "❌ اللاعب غير متصل",
    daily_limit = "❌ تجاوزت الحد اليومي"
}
