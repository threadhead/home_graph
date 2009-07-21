class Zonelog < ActiveRecord::Base
  TABLE_NAME = "zone_log"
  
  establish_connection "elkm1_#{RAILS_ENV}"
  set_table_name TABLE_NAME
  
  named_scope :closed, :conditions => "time_close IS NOT NULL"
  named_scope :from_time, lambda { |from_time| { :conditions => "time_open >= '#{from_time.to_formatted_s(:db)}'",
                                                 :order => 'time_open ASC'} }
  named_scope :zone, lambda { |zone| { :conditions => "zone = '#{zone}'" } }
  
  def self.zones
    Zonelog.find(:all, :group => 'zone', :order => 'zone ASC').collect{ |l| l.zone }  
  end
  
  def self.years
    Zonelog.find_by_sql("SELECT DISTINCT YEAR(`time_open`) as 'year' FROM  `#{TABLE_NAME}` GROUP BY YEAR(`time_open`) ASC").collect{ |y| y['year'].to_i }
  end
  
  def self.day_and_count_by_zone(zone)
    Zonelog.find_by_sql("SELECT DAYOFWEEK(time_open) as 'day', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE zone = '#{zone}' GROUP BY DAYOFWEEK(time_open) ASC")
  end
  
  def self.day_and_opened_by_zone(zone)
    Zonelog.find_by_sql("SELECT DAYOFWEEK(time_open) as 'day', SUM(TIME_TO_SEC(TIMEDIFF( time_close, time_open ))) as 'opened' FROM #{TABLE_NAME} WHERE zone = '#{zone}' GROUP BY DAYOFWEEK(time_open) ASC")
  end
  
  def self.hour_and_count_by_zone(zone)
    Zonelog.find_by_sql("SELECT HOUR(time_open) as 'hour', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE zone = '#{zone}' GROUP BY HOUR(time_open) ASC")
  end

  def self.hour_and_opened_by_zone(zone)
    Zonelog.find_by_sql("SELECT HOUR(time_open) as 'hour', SUM(TIME_TO_SEC(TIMEDIFF( time_close, time_open ))) as 'opened' FROM #{TABLE_NAME} WHERE zone = '#{zone}' GROUP BY HOUR(time_open) ASC")
  end
  
  def self.month_and_count_by_location(zone, year = Time.now.year)
    Zonelog.find_by_sql("SELECT MONTH(time_open) as 'month', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE zone = '#{zone}' AND YEAR(`time_open`) = #{year.to_i} GROUP BY MONTH(`time_open`) ASC")
  end
  
  def self.month_and_opened_by_location(zone, year = Time.now.year)
     Zonelog.find_by_sql("SELECT MONTH(time_open) as 'month', SUM(TIME_TO_SEC(TIMEDIFF( time_close, time_open ))) as 'opened' FROM #{TABLE_NAME} WHERE zone = '#{zone}' AND YEAR(`time_open`) = #{year.to_i} GROUP BY MONTH(`time_open`) ASC")
  end
  
  
  
  def opened_seconds
     if self.time_open.nil? || self.time_close.nil?
       return 0.0
     else
       (self.time_close - self.time_open)
     end
  end
   
  def self.open?(zone)
      Zonelog.find(:last, :conditions => "zone = '#{zone}'", :order => 'time_close').time_close.nil?
  end
  
  def self.last_time_open(zone)
    Zonelog.zone(zone).closed.find(:last, :order => 'time_open')
  end
  
  def self.sum_opened(logs)
    logs.inject(0){ |sum,n| sum + n.opened_seconds }
  end
  
  def self.average_opened(logs)
    logs.size == 0 ? 0.0 : self.sum_opened(logs) / logs.size
  end
  
  def self.longest_opened(logs)
    logs.size == 0 ? nil : logs.max{ |a,b| a.opened_seconds <=> b.opened_seconds }
  end
end
