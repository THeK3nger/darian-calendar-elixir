defmodule DarianCalendar do
    @moduledoc """
    
    Module for converting an UTC terrestrian date into the fictional Darian Calendar
    proposed for the civilian use of a future Mars colony by Thomas Gangale.

    """

    defmodule Date do
        defstruct   year: 0,
                    month: 0,
                    sol: 0,
                    week_sol: 0,
                    hour: 0,
                    min: 0,
                    sec: 0
    end

    # Ratio Between Earth and Mars Days
    @mars_to_earth_days 1.027491251
    @seconds_per_day 86400.0

    ### Important Julian Dates
    @unix_epoch 2440587.5           # Midnight 1st January 1970 
    @telescopic_epoch 2308804.50000 # Midnight 11th March 1609
    @allison_epoch 2405522.0028779  # Midnight 29th December 1873
    @epoch_offset @telescopic_epoch # Chose the Starting Epoch for March Calendar

    ### Other Magic Numbers
    @sols_per_year 668.5910
    @sols_in_500_years Float.ceil(@sols_per_year * 500)
    @sols_in_century Float.floor(@sols_per_year * 100)
    @sols_in_decade Float.ceil(@sols_per_year * 10)
    @sols_in_2_years Float.floor(@sols_per_year * 2)

    ### Names
    @month_names %{ 
        defrost: ["Adir", "Bora", "Coan", "Deti", "Edal", "Flo", "Geor", "Heliba", "Idanon", "Jowani", "Kireal", "Larno", "Medior", "Neturima", "Ozulikan", "Pasurabi", "Rudiakel", "Safundo", "Tiunor", "Ulasja", "Vadeun", "Wakumi", "Xetual", "Zungo"],
        hensel:  ["Vernalis", "Duvernalis", "Trivernalis", "Quadrivernalis", "Pentavernalis", "Hexavernalis", "Aestas", "Duestas", "Triestas", "Quadrestas", "Pentestas", "Hexestas", "Autumnus", "Duautumn", "Triautumn", "Quadrautumn", "Pentautumn", "Hexautumn", "Unember", "Duember", "Triember", "Quadrember", "Pentember", "Hexember"],
        martiana:  ["Sagittarius", "Dhanus", "Capricornus", "Makara", "Aquarius", "Kumbha", "Pisces", "Mina", "Aries", "Mesha", "Taurus", "Rishabha", "Gemini", "Mithuna", "Cancer", "Karka", "Leo", "Simha", "Virgo", "Kanya", "Libra", "Tula", "Scorpius", "Vrishika"]
    }

    @sol_names %{
        areosynchronous:  ["Heliosol", "Phobosol", "Deimosol", "Terrasol", "Venusol", "Mercurisol", "Jovisol"],
        defrost: ["Axatisol", "Benasol", "Ciposol", "Domesol", "Erjasol", "Fulisol", "Gavisol"],
        martiana:  ["Sol Solis", "Sol Lunae", "Sol Martis", "Sol Mercurii", "Sol Jovis", "Sol Veneris", "Sol Saturni"]
    }

    @spec sols_from_earth(DateTime) :: number
    @doc """
    Convert the Terrestrian UTC date and time in the number of Sols since the define epoch.

    ## Parameters

        - `date`: The date returned by `DateTime`.
    """
    def sols_from_earth(date) do
        unix = DateTime.to_unix(date)
        offset = @unix_epoch - @epoch_offset
        # TODO: To makethis moreaccurate we should take into account the
        # Leap second correction since 30 June 1970. For now, we just avoid this.
        days = (unix / @seconds_per_day) + offset
        days / @mars_to_earth_days        
    end

    @doc """
    Return the current Darian Year and the current sols in the year.

    ## Parameters:

        - `date`: The date returned by `DateTime`.

    Returned a tuple `{year, sols}`.
    """
    @spec darian_year(DateTime) :: {integer, number}
    def darian_year(date) do
        sols = sols_from_earth(date)
        # sD = Num of 500 years cycles
        sD = Float.floor(sols / @sols_in_500_years)
        # doD = Sols into the current 500y cycle.
        doD = Float.floor(sols - (sD * @sols_in_500_years))

        # sC = Centuries
        sC = if doD != 0, do: Float.floor((doD - 1) / @sols_in_century), else: 0
        doC = if sC != 0, do: doD - ((sC * @sols_in_century) + 1), else: doD

        # sX = Decades
        sX = if sC != 0 do 
                Float.floor((doC+1)/@sols_in_decade)
            else
                Float.floor(doC / @sols_in_decade)
            end
        doX = if sC != 0 and sX != 0 do 
                doX = doC - ((sX * @sols_in_decade) - 1)
            else
                dox = doC - (sX * @sols_in_decade)
            end

        # sII = Biennials
        sII = cond do
            sC != 0 and sX == 0 -> Float.floor((doX / @sols_in_2_years))
            doX != 0            -> Float.floor((doX - 1) / @sols_in_2_years)
            true                -> 0
        end

        doII = cond do
            sII != 0 and sC != 0 and sX == 0 -> doX - (sII * @sols_in_2_years)
            sII != 0 and !(sC != 0 and sX == 0) -> doX - (sII * @sols_in_2_years) - 1
            true -> doX 
        end

        # sI = Years
        leap_year = sII == 0 and ((sX != 0) or ((sX == 0) and (sC ==0)))
        sI = cond do
            leap_year -> Float.floor(doII / 669)
            true -> Float.floor((doII + 1) / 669)
        end
        doI = cond do 
            leap_year and sI != 0 -> doII - 669
            !leap_year and sI != 0 -> doII - 668
            true -> doII
        end

        year = 500*sD + 100*sC + 10*sX + 2*sII +  sI
        {year, doI}
    end

    @doc """
    Convert the given date into a Darian Date.

    ## Parameters

        - `date`: The date returned by `DateTime`.
    
    Returns a `DarianCalendar.Date` struct with the converted date and time.
    """
    @spec darian_date(DateTime) :: DarianCalendar.Date 
    def darian_date(date) do 
        {year, sols} = darian_year(date)
        season = cond do 
            sols < 167 -> 0
            sols < 334 -> 1
            sols < 501 -> 2
            true -> 3
        end
        sols_of_season = sols - 167 * season
        month_of_season = Float.floor(sols_of_season / 28)
        month = month_of_season + 6 * season + 1
        sol = sols - ((month - 1) * 28 - season) + 1
        week_sol = rem(round(sol - 1), round(7)) + 1

        full_sols = sols_from_earth(date)
        full_hour = (full_sols - Float.floor(full_sols))*24
        full_min = (full_hour - Float.floor(full_hour))*60

        hour = Float.floor(full_hour)
        min = Float.floor(full_min)
        sec = Float.floor((full_min - Float.floor(full_min))*60)
        %DarianCalendar.Date{
            year: round(year), 
            month: round(month),
            sol: round(sol),
            week_sol: round(week_sol),
            hour: round(hour),
            min: round(min),
            sec: round(sec)}
    end

    @doc """
    Convert a `DarianCalendar.Date` struct into a human readable string.

    ## Parameters

        - `d_date`: The `DarianCalendar.Date` struct.
        - `name_type`: Specify which nomenclature we want to use.
    """
    @spec to_string(DarianCalendar.Date) :: String.t
    def to_string(d_date, name_type \\ :defrost) do
        {:ok, month_name} = Enum.fetch(@month_names[name_type], d_date.month - 1)
        {:ok, sol_name} = Enum.fetch(@sol_names[name_type], d_date.week_sol - 1)
        "#{sol_name} #{d_date.sol} #{month_name} #{d_date.year} @ #{d_date.hour}:#{d_date.min}:#{d_date.sec}"
    end

end
