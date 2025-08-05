DGCORE = DGCORE or {}

DGCORE.Config = {}

DGCORE.Config.Server = {}
DGCORE.Config.Server.Closed = false
DGCORE.Config.Server.Whitelist = false
DGCORE.Config.Server.Redis = false
DGCORE.Config.Server.ChunkSize = 500
DGCORE.Config.Server.UseAsyncQuery = false
DGCORE.Config.Server.MaxQueries = 5
DGCORE.Config.Server.Debug = false

DGCORE.Config.User = {}
DGCORE.Config.User.DefaultSpawnPosition = { x = -1035.71, y = -2732.87, z = 12.86 }
DGCORE.Config.User.DefaultHealth = 100
DGCORE.Config.User.DefaultArmour = 100

DGCORE.Config.Client = {
    draw_distance = "dgbr_draw_distance",                                               -- 描写距離 number
    ui_scale = "dgbr_ui_scale",                                                         -- UIスケール number
    ui_frame_rate_limit = "dgbr_frame_rate_limit",                                      -- UIの更新頻度 number
    ui_remaining_number_of_people = "dgbr_ui_remaining_number_of_people",               -- UIの残り人数 boolean
    ui_damage = "dgbr_ui_damage",                                                       -- UIのダメージ表示 boolean
    notify_system_log = "dgbr_notify_system_log",                                       -- システム通知 boolean
    notify_kill_log = "dgbr_notify_kill_log",                                           -- キルログ通知 boolean
    notify_area_reduction_alert = "dgbr_area_reduction_alert",                          -- エリア縮小通知 boolean
    inventory_auto_sort = "dgbr_inventory_auto_sort",                                   -- インベントリー自動並び替え string(None / Kind / Get)
}

