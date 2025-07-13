local gun = {
    Name = "AK47",
    GunType = "Rifle",

    Ammo = {
        CurrentAmmo = 30,
        MaxAmmo = 300,
    },

    Timing = {
        FireRate = 0.1,
        ReloadTime = 1.5,
    },

    GunStats = {
        Damage = 15,
        Range = 50,

        Recoil = {
            Horizontal = 0.1,
            Vertical = 0.1,
        },
    
        Spread = {
            Horizontal = 0.1,
            Vertical = 0.1,
        },
    },
}

return gun