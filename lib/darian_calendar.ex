defmodule DarianCalendar do

    # Ratio Between Earth and Mars Days
    @mars_to_earth_days 1.027491251
    @seconds_per_day 86400.0

    ### Important Julian Dates
    @unix_epoch 2440587.5           # Midnight 1st January 1970 
    @telescopic_epoch 2308804.50000 # Midnight 11th March 1609
    @allison_epoch 2405522.0028779  # Midnight 29th December 1873
    @epoch_offset @telescopic_epoch # Chose the Starting Epoch for March Calendar

    def sols_from_earth(date) do
        unix = DateTime.to_unix(date)
        offset = @unix_epoch - @epoch_offset
        days = (unix / @seconds_per_day) + offset
        days / @mars_to_earth_days        
    end

    def print_date do
        now = DateTime.utc_now
        IO.puts(DateTime.to_unix(now))
    end
end
