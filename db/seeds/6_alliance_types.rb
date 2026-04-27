AllianceType.find_or_create_by(name: 'Пакт о ненападении') do |at|
  at.min_relations_level = 0
end

AllianceType.find_or_create_by(name: 'Оборонный союз') do |at|
  at.min_relations_level = 1
end

AllianceType.find_or_create_by(name: 'Наступательный союз') do |at|
  at.min_relations_level = 2
end

