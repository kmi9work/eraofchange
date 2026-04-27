# Migration to add Vyatka trade level thresholds
# Run this with: rails runner db/migrate/add_vyatka_trade_levels.rb

puts "Adding Vyatka trade level thresholds..."

vyatka = Country.find_by_name('Вятка')

if vyatka.present?
  vyatka_levels = [
    { level: 0, threshold: 0, name: ""},
    { level: 1, threshold: 1000, name: "Низкий"},
    { level: 2, threshold: 30000, name: "Средний"},
    { level: 3, threshold: 70000, name: "Высокий"}
  ]
  
  current_params = vyatka.params || {}
  current_params['level_thresholds'] = vyatka_levels
  vyatka.params = current_params
  
  if vyatka.save!
    puts "✓ Vyatka trade levels configured successfully!"
    puts "  Current params: #{vyatka.params.inspect}"
  else
    puts "✗ Failed to save Vyatka: #{vyatka.errors.full_messages.join(', ')}"
  end
else
  puts "✗ Vyatka country not found!"
end
