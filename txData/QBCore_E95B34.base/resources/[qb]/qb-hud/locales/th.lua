local Translations = {
    notify = {
        ["hud_settings_loaded"] = "โหลดการตั้งค่า HUD เรียบร้อย!",
        ["hud_restart"] = "HUD กำลังรีสตาร์ท!",
        ["hud_start"] = "HUD ทำงานเเล้ว!",
        ["hud_command_info"] = "คำสั่งนี้จะรีเซ็ตการตั้งค่า HUD ของคุณ!",
        ["load_square_map"] = "Square Map กำลังโหลด...",
        ["loaded_square_map"] = "Square Map โหลดเเล้ว!",
        ["load_circle_map"] = "Circle Map กำลังโหลด",
        ["loaded_circle_map"] = "Circle Map โหลดเเล้ว!",
        ["cinematic_on"] = "Cinematic Mode เปิด!",
        ["cinematic_off"] = "Cinematic Mode ปิด!",
        ["engine_on"] = "สตาร์ทเครื่องยนต์!",
        ["engine_off"] = "ดับเครื่องยนต์!",
        ["low_fuel"] = "น้ำมันใกล้หมดเเล้ว!",
        ["access_denied"] = "คุณไม่มีสิทธิ์ใช้งาน!",
        ["stress_gain"] = "ความดันคุณกำลังขึ้น!",
        ["stress_removed"] = "รู้สึกผ่อนคลายขึ้น!"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
