

array = Guild.all.collect{ |g| [g.name, g.id, g.class.to_s] }
num = 1
array.map!{|pp| array[num][0] + array[num][1].to_s + "_" + array[num][2] num = +1}


for array each do pp
