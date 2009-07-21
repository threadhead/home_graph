# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def format_float(f)
    f.nil? ? "0.0" : sprintf( "%.2f", f )
  end
  
  def options_for_hours(selected="")
    options_for_select(['1 hour','4 hours', '12 hours', '24 hours', '48 hours','72 hours','168 hours'], selected )
  end
  
end

