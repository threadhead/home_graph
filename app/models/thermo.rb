class Thermo < ActiveRecord::Base
  TABLE_NAME = "thermo"
  # establish_connection "homeseer_#{RAILS_ENV}"
  set_table_name TABLE_NAME
  
  named_scope :active, :conditions => "time_off IS NOT NULL"
  named_scope :from_time, lambda { |from_time| { :conditions => "time_on >= '#{from_time.to_formatted_s(:db)}'",
                                                 :order => 'time_on ASC' } }
  named_scope :location, lambda { |thermo_loc| { :conditions => "thermo_loc = '#{thermo_loc}'" } }
  named_scope :mode, lambda { |mode| { :conditions => "mode = '#{mode}'" } }
  
  def self.locations
    Thermo.find(:all, :group => 'thermo_loc', :order => 'thermo_loc ASC').collect{ |l| l.thermo_loc }  
  end

  def self.years
    Thermo.find_by_sql("SELECT DISTINCT YEAR(`time_on`) as 'year' FROM  `#{TABLE_NAME}` GROUP BY YEAR(`time_on`) ASC").collect{ |y| y['year'].to_i }
  end
  
  def runtime_minutes
    if self.time_on.nil? || self.time_off.nil?
      return 0.0
    else
      (self.time_off - self.time_on) / 60
    end
  end
  
  
  
  def self.day_and_count_by_location(location, mode)
    Thermo.find_by_sql("SELECT DAYOFWEEK(time_on) as 'day', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode) } GROUP BY DAYOFWEEK(`time_on`) ASC")
  end
  
  def self.day_and_runtime_by_location(location, mode)
    Thermo.find_by_sql("SELECT DAYOFWEEK(time_on) as 'day', SUM(TIME_TO_SEC(TIMEDIFF( time_off, time_on ))) as 'runtime' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode) } GROUP BY DAYOFWEEK(`time_on`) ASC")
  end
  
  def self.hour_and_count_by_location(location, mode)
    Thermo.find_by_sql("SELECT HOUR(time_on) as 'hour', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode) } GROUP BY HOUR(`time_on`) ASC")
  end
  
  def self.hour_and_runtime_by_location(location, mode)
     Thermo.find_by_sql("SELECT HOUR(time_on) as 'hour', SUM(TIME_TO_SEC(TIMEDIFF( time_off, time_on ))) as 'runtime' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode) } GROUP BY HOUR(`time_on`) ASC")
  end
  
  def self.month_and_count_by_location(location, mode, year = nil)
    Thermo.find_by_sql("SELECT MONTH(time_on) as 'month', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode,year) } GROUP BY MONTH(`time_on`) ASC")
  end
  
  def self.month_and_runtime_by_location(location, mode, year = nil)
     Thermo.find_by_sql("SELECT MONTH(time_on) as 'month', SUM(TIME_TO_SEC(TIMEDIFF( time_off, time_on ))) as 'runtime' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode,year) } GROUP BY MONTH(`time_on`) ASC")
  end

  def self.year_and_count_by_location(location, mode)
    Thermo.find_by_sql("SELECT YEAR(time_on) as 'month', COUNT(*) as 'count' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode) } GROUP BY YEAR(`time_on`) ASC")
  end
  
  def self.year_and_runtime_by_location(location, mode)
     Thermo.find_by_sql("SELECT YEAR(time_on) as 'month', SUM(TIME_TO_SEC(TIMEDIFF( time_off, time_on ))) as 'runtime' FROM #{TABLE_NAME} WHERE #{ build_where(location,mode) } GROUP BY YEAR(`time_on`) ASC")
  end
  
  def self.build_where(location, mode, year = Time.now.year)
    if year.nil?
      "`thermo_loc` = '#{location}' AND `mode` = '#{mode}'"
    else
      "`thermo_loc` = '#{location}' AND `mode` = '#{mode}' AND YEAR(`time_on`) = #{year.to_i}"    
    end
  end
  
  
  
  def self.location_on?(location)
    Thermo.location(location).find(:last, :order => 'time_on').time_off.nil?
  end
  
  def self.last_time_on(location, mode)
    Thermo.location(location).mode(mode).active.find(:last, :order => 'time_on')
  end
  
  def self.sum_runtime(thermos)
    thermos.inject(0){ |sum,n| sum + n.runtime_minutes }
  end
  
  def self.average_runtime(thermos)
    thermos.size == 0 ? nil : self.sum_runtime(thermos) / thermos.size
  end
  
  def self.longest_runtime(thermos)
    thermos.size == 0 ? nil : thermos.max{ |a,b| a.runtime_minutes <=> b.runtime_minutes }
  end

  def self.shortest_runtime(thermos)
    thermos.size == 0 ? nil : thermos.min{ |a,b| a.runtime_minutes <=> b.runtime_minutes }
  end
  
end
