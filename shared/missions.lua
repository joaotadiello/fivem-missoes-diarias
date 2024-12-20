Missions = {
    ['daily'] = {
        ['name'] = 'daily',
        ['description'] = 'Complete a missão diária',
        ['objective'] = 10,
        ['reward'] = function(userId)
            print('missão completada', userId)
        end
    },
    ['police'] = {
        ['name'] = 'police',
        ['description'] = 'Complete a missão policial',
        ['objective'] = 5,
        ['reward'] = function(userId)
            print('missão completada', userId)
        end
    },
    ['online'] = {
        ['name'] = 'online',
        ['description'] = 'Complete a missão online',
        ['objective'] = 7200,
        ['reward'] = function(userId)
            print('missão completada', userId)
        end
    }
}

