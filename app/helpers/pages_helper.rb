module PagesHelper
  def plan_amount(amount = 0)
    if amount > 0
      return amount / 100
    end

    'Free'
  end

  def plan_frequency(freq = 'daily')
    str = {"daily" => "day", "monthly" => "mo", "yearly" => "yr"}

    str[freq.to_s.downcase]
  end
end
