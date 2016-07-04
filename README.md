# DarianCalendar

This Elixir package convert a terrestrial UTC date and time into the [Darian Calendar][1] date and time, a fictional civilian calendar proposed by Thomas Gangale.

Actually the computation start from 11th March 1609, the so called **telescopic era**.

This is just a fun project to become familiar with Elixir syntax. :) It is also the only Darian Calendar implementation that actually explain the meaning of all the involved magic numbers! :D

![Mars Gif](mars.gif)<sup>1</sup>

## Example

```elixir
# 2016-07-04 ...
iex> d = DarianCalendar.darian_date(DateTime.utc_now)
iex> DarianCalendar.to_string(d)
"Erjasol 12 Neturima 216 @ 7:32:51"
```

## Current Issues

 * The converter does not take into account the *leap seconds*. As a consequence, all calculations for dates greater than 1973 may be wrong by several seconds (actually 36).
 * There are some nomenclatures missing. 


<sup>1</sup> Image from [delta4.gamma2][2].

[1]: https://en.wikipedia.org/wiki/Darian_calendar
[2]: http://pixeljoint.com/pixelart/45988.htm