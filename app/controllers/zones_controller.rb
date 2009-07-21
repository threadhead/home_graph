class ZonesController < ApplicationController
  def opened
    params[:from_hours] ||= '24 hours'
    params[:zone] ||= Zonelog.zones[0]
  end

  def opened_graph
    from_time =  params[:from_hours].to_i.hours.ago
    logs = Zonelog.from_time( from_time ).zone( params[:zone] ).closed.find( :all )
    
    data = Array.new(params[:from_hours].to_i.hours/60/5,0)
    labels = Array.new(params[:from_hours].to_i.hours/60/5,"")
    
    logs.each{ |l| 
      minutes_from_start = ((l.time_open - from_time) / 60 / 5 ).round
      data[minutes_from_start] = l.opened_seconds
      labels[minutes_from_start] = l.time_open.to_formatted_s( :short )
       }
    
    single_line_graph(data, labels)
  end
    
  def by_day_graph
    # count and open_time by day of week
    counts = Zonelog.day_and_count_by_zone( params[:zone] )
    opened = Zonelog.day_and_opened_by_zone( params[:zone] )
    
    data_count = Array.new( 7, 0 )
    data_opened = Array.new( 7, 0 )

    counts.each{ |c| data_count[ c['day'].to_i - 1 ] = c['count'].to_i }
    opened.each{ |r| data_opened[ r['day'].to_i - 1 ] = (r['opened'].to_f) / 60 }

    line_bar_graph(data_count, 'Count (sum)', data_opened, 'Opened (min)', days_of_week)    
  end
  
  def by_hour_graph
    # count of runtimes by hour of the day
    counts = Zonelog.hour_and_count_by_zone( params[:zone] )
    opened = Zonelog.hour_and_opened_by_zone( params[:zone] )

    data_count = Array.new( 24, 0 )
    data_opened = Array.new( 24, 0 )

    counts.each{ |c| data_count[ c['hour'].to_i ] = c['count'].to_i }
    opened.each{ |r| data_opened[ r['hour'].to_i ] = (r['opened'].to_f) / 60 }

    line_bar_graph(data_count, 'Count (sum)', data_opened, 'Opened (min)', hours_of_day)
   end
  
   def by_month_opened_graph
     # count of runtimes by month     
     open_hash = Hash.new
     Zonelog.years.each{ |year|
       opened = Zonelog.month_and_opened_by_location( params[:zone], year )
       data_opened = Array.new( 12, 0 )
       opened.each{ |r| data_opened[ r['month'].to_i - 1 ] = round_two_decimal((r['opened'].to_f) / 60 ) }
       open_hash.merge!( { year.to_s => data_opened } )
     }

    multi_line_graph(open_hash, months_of_year)     
   end
   
   def by_month_count_graph
     # count of runtimes by month
     
     open_hash = Hash.new
      Zonelog.years.each{ |year|
        counts = Zonelog.month_and_count_by_location( params[:zone], year )
        data_count = Array.new( 12, 0 )
        counts.each{ |c| data_count[ c['month'].to_i - 1 ] = c['count'].to_i }
        open_hash.merge!( { year.to_s => data_count } )
      }
      
      multi_bar_graph(open_hash, months_of_year)     
   end
   
end
