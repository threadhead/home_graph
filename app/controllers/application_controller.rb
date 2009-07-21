# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  

  COUNT_COLOR = '#c5ad95'
  RUNTIME_COLOR = '#84400e'
  X_LABEL_COLOR = '#222222'
  LINE_COLORS = ['#9933CC', '#CC3399', '#80a033', '#736AFF', '#8010A0', '#D54C78', '#3334AD']

  
  def remove_every_nth_element(arr, nth_element)
    counter = 0
    arr.collect { |item|
     counter += 1
     counter % nth_element == 0 ? item : ""
     } 
  end
  
  def selected_time_ago(from_string)
    # looks at the passed string (i.e. '2 hours', '3 weeks') and converts it to a time ago
    case from_string.split(" ").last
    when "minute", "minutes"
      from_string.split(" ").first.to_i.minutes.ago
    when "hour", "hours"
      from_string.split(" ").first.to_i.hours.ago
    when "day", "days"
      from_string.split(" ").first.to_i.days.ago
    when "week", "weeks"
      from_string.split(" ").first.to_i.weeks.ago
    when "month", "months"
      from_string.split(" ").first.to_i.months.ago
      
    end
    
  end
  
  def round_two_decimal(num)
    (num * 100).round / 100.0
  end
  
  def single_line_graph(data, labels)
    g = Graph.new
    # g.set_bg_color = '#303030'
    g.title(" ")
    g.set_data( data )
    g.set_x_labels( labels )
    g.set_x_label_style(9, color='#000000', orientation = 1 )
    g.set_x_axis_steps( 20 )
    g.set_y_max( raise_to_power(data.max) )
    g.set_y_label_steps(6)
    render :text => g.render
  end
  
  def line_bar_graph(data_bar, legend_bar, data_line, legend_line, labels)
    g = Graph.new
    # g.set_bg_color = '#303030'
    g.title(" ")

    g.set_data( data_bar )
    g.bar( 50, COUNT_COLOR, '', 10)
    g.set_y_axis_color( COUNT_COLOR )

    g.set_data( data_line )
    g.line( 3, RUNTIME_COLOR, 'Opened')
    g.attach_to_y_right_axis(2)
    g.y_right_axis_color( RUNTIME_COLOR )

    g.set_x_labels( labels )
    g.set_x_label_style(9, color = X_LABEL_COLOR, orientation = 1 )
    g.set_x_axis_steps( 1 )

    g.set_y_max( raise_to_power(data_bar.max) )
    g.set_y_legend( legend_bar, 9, COUNT_COLOR )
    
    g.set_y_right_max( raise_to_power(data_line.max) )
    g.set_y_label_steps( 4 )
    g.set_y_legend_right( legend_line ,9 , RUNTIME_COLOR )
    render :text => g.render    
  end
  
  def multi_line_graph(data_hash, labels)
    multi_graph('line', data_hash, labels)
  end
  
  def multi_bar_graph(data_hash, labels)
    multi_graph('bar', data_hash, labels)
  end
  
  def multi_graph(style, data_hash, labels)
    g = Graph.new
    # g.set_bg_color = '#303030'
    g.title(" ")

    data_runtime_max = 0

    idx = 0
    data_hash.each_pair{ |key,value|
      idx += 1
      case style
      when 'line'
        g.set_data( value )
        g.line( 3, LINE_COLORS[idx], key, 10 )
      when 'bar'
        bar = Bar.new(50, LINE_COLORS[idx] )
        bar.key( key, 10)
        bar.data << value
        g.data_sets << bar
      end
      
      data_runtime_max = value.max if value.max > data_runtime_max
    }

    g.set_y_max( raise_to_power(data_runtime_max) )    
    g.set_y_label_steps( 4 )

    g.set_x_labels( labels )
    g.set_x_label_style(9, color = X_LABEL_COLOR, orientation = 1 )
    g.set_x_axis_steps( 1 )

    render :text => g.render
  end

  def raise_to_power(num)
    case num.abs
    when 0...99
      multiplier = 1
    when 100...999
      multiplier = 10
    when 1000...9999
      multiplier = 100
    else
      multiplier = 1000
    end
    
    ((num.to_i / multiplier) + 1 ) * multiplier
  end
  
  def days_of_week
    ["Sun", "Mon", "Tue", "Wed", "Thr", "Fri", "Sat"]
  end
  
  def months_of_year
    ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  end
  
  def hours_of_day
    labels = Array.new( 24, "" )
    
    labels.each_with_index{ |l,idx|
      case idx
      when 0
        labels[idx] = "Mid"
      when 1..11
        labels[idx] = idx.to_s + " am"
      when 12
        labels[idx] = "Noon"
      when 13..23
        labels[idx] = (idx - 12).to_s + " pm"
      else
      end
    }
    
    labels
  end
end
