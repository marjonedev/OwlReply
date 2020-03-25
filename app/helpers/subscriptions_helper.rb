module SubscriptionsHelper

  def frequency_str(val = 'daily')
    str = {"daily" => "Daily", "monthly" => "Monthly", "yearly" => "Yearly"}

    str[val.to_s.downcase]
  end

  def recommended_str(id, val = false)

    if val
      return raw('<div class="center">
          <input class="radio-style" name="radio-group-'+id.to_s+'" type="radio" checked="checked" disabled>
          <label class="radio-style-3-label"></label>
      </div>')
    end

    raw('<div class="center">
          <input class="radio-style" name="radio-group-'+id.to_s+'" type="radio" disabled>
          <label class="radio-style-3-label"></label>
      </div>')

  end
end
