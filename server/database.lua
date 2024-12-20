Citizen.CreateThread(function()
    Wait(100)
    exports["oxmysql"]:query([[
        CREATE TABLE IF NOT EXISTS `daily` (
            `user_id` int(11) NOT NULL,
            `updatedAt` int(11) NOT NULL DEFAULT 0,
            `expireAt` int(11) DEFAULT NULL,
            `connection_start` int(11) DEFAULT NULL,
            `data` longtext NOT NULL DEFAULT '{}'
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
    print("^2[Daily] ^7Table created or checked.")
end)
