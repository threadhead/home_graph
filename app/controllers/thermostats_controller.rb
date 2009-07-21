class ThermostatsController < ApplicationController
  def runtime
    params[:from_past] ||= '24 hours'
    params[:mode] ||= 'Cool'
  end

  def runtime_graph
    from_time =  selected_time_ago( params[:from_past] )
    logs = Thermo.from_time( from_time ).location( params[:thermo_loc] ).mode( params[:mode] ).active.find( :all )
    
    data = Array.new(params[:from_past].to_i.hours/60/5,0)
    labels = Array.new(params[:from_past].to_i.hours/60/5,"")
    
    logs.each{ |l| 
      minutes_from_start = ((l.time_on - from_time) / 60 / 5 ).round
      data[minutes_from_start] = l.runtime_minutes.to_f
      labels[minutes_from_start] = l.time_on.to_formatted_s( :short )
    }
    
    single_line_graph(data, labels)
  end
  
  def by_day_graph
    # count and runtimes by day of week
    counts = Thermo.day_and_count_by_location( params[:thermo_loc], params[:mode] )
    runtimes = Thermo.day_and_runtime_by_location( params[:thermo_loc], params[:mode] )
    
    data_count = Array.new( 7, 0 )
    data_runtime = Array.new( 7, 0 )

    counts.each{ |c| data_count[ c['day'].to_i - 1 ] = c['count'].to_i }
    runtimes.each{ |r| data_runtime[ r['day'].to_i - 1 ] = (r['runtime'].to_f) / 60 / 60 }
    
    line_bar_graph(data_count, 'Count (sum)', data_runtime, 'Runtime (hours)', days_of_week)    
  end
  
  def by_hour_graph
    # count of runtimes by hour of the day
    counts = Thermo.hour_and_count_by_location( params[:thermo_loc], params[:mode] )
    runtimes = Thermo.hour_and_runtime_by_location( params[:thermo_loc], params[:mode] )

    data_count = Array.new( 24, 0 )
    data_runtime = Array.new( 24, 0 )
    
    counts.each{ |c| data_count[ c['hour'].to_i ] = c['count'].to_i }
    runtimes.each{ |r| data_runtime[ r['hour'].to_i ] = (r['runtime'].to_f) / 60 / 60 }
    
    line_bar_graph(data_count, 'Count (sum)', data_runtime, 'Runtime (hours)', hours_of_day)
  end
  
  def by_month_runtime_graph
    # count of runtimes by month
    open_hash = Hash.new
    Zonelog.years.each_with_index{ |year, idx|
      runtimes = Thermo.month_and_runtime_by_location( params[:thermo_loc], params[:mode], year )
      data_runtime = Array.new( 12, 0 )
      runtimes.each{ |r| data_runtime[ r['month'].to_i - 1 ] = round_two_decimal((r['runtime'].to_f) / 60 / 60) }
      
     open_hash.merge!( { year.to_s => data_runtime } )
    }

    multi_line_graph(open_hash, months_of_year)
  end

  def by_month_count_graph
    # count of runtimes by month
    open_hash = Hash.new
    Zonelog.years.each_with_index{ |year, idx|
      counts = Thermo.month_and_count_by_location( params[:thermo_loc], params[:mode], year )
      data_count = Array.new( 12, 0 )
      counts.each{ |c| data_count[ c['month'].to_i - 1 ] = c['count'].to_i }
      
      open_hash.merge!( { year.to_s => data_count } )
    }

    multi_bar_graph(open_hash, months_of_year)
  end

end
