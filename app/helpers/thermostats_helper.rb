module ThermostatsHelper
  def thermo_event_string(thermo)
    if thermo.blank?
      "none"
    else
      thermo.time_on.strftime('%a %b %d, %y %H:%M') <<
      " - " <<
      format_float( thermo.runtime_minutes ) <<
      " min"
    end
  end
  
  def zonelog_event_string(zonelog)
    if zonelog.blank?
      "none"
    else
      zonelog.time_open.strftime('%a %b %d, %y %H:%M') <<
      " - " <<
      seconds_minutes( zonelog.opened_seconds )
    end
  end
  
  def seconds_minutes(seconds)
    seconds.to_i.to_s << " sec (" << format_float( seconds / 60 ) << " min)"
  end
end
