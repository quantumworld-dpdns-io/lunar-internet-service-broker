module OrbitalMechanics

export lunar_visibility, signal_propagation_delay, link_budget, doppler_shift

"""
Calculate lunar relay visibility windows for a given rover location.
"""
function lunar_visibility(
    rover_lat::Float64,
    rover_lon::Float64,
    relay_altitude_km::Float64,
    relay_longitude::Float64,
    time_hours::Float64,
)::Bool
    R_MOON = 1737.4  # Moon radius in km
    horizon_angle = rad2deg(acos(R_MOON / (R_MOON + relay_altitude_km)))
    lon_diff = abs(relay_longitude - rover_lon)
    lon_diff = lon_diff > 180 ? 360 - lon_diff : lon_diff
    return lon_diff <= horizon_angle
end

"""
Calculate signal propagation delay between rover and relay.
"""
function signal_propagation_delay(
    distance_km::Float64,
)::Float64
    c = 299792.458  # Speed of light in km/s
    return distance_km / c  # returns seconds
end

"""
Calculate link budget for communication channel.
"""
function link_budget(
    tx_power_dbm::Float64,
    tx_gain_dbi::Float64,
    rx_gain_dbi::Float64,
    frequency_ghz::Float64,
    distance_km::Float64,
)::Float64
    c = 299792.458  # km/s
    wavelength_km = c / (frequency_ghz * 1e9)
    free_space_loss = 20 * log10(4 * pi * distance_km / wavelength_km)
    rx_power = tx_power_dbm + tx_gain_dbi + rx_gain_dbi - free_space_loss
    return rx_power
end

"""
Calculate doppler shift for moving relay.
"""
function doppler_shift(
    frequency_ghz::Float64,
    relative_velocity_kms::Float64,
)::Float64
    c = 299792.458  # km/s
    return frequency_ghz * (1 + relative_velocity_kms / c)
end

end
