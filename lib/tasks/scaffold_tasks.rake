
# rails generate scaffold PoliticalActionType title:string action:json params:json
# rails generate scaffold PoliticalAction year:integer success:integer params:json political_action_type:references player:references
# rails generate scaffold IdeologistTechnology title:string requirements:json params:json ideologist_type:references
# rails generate scaffold IdeologistType name:string
# rails generate scaffold PlayerType title:string ideologist_type:references
# rails generate scaffold Human name:string
# rails generate scaffold Job name:string params:json
# rails generate scaffold PlantLevel level:integer deposit:integer charge:integer formula:json price:json max_product:integer 
# rails generate scaffold Player name:string player_type:references guild:references political_action:references human:references job:references family:references plant:references
# rails generate scaffold BuildingPlace category:integer params:json
# rails generate scaffold BuildingType title:string params:json
# rails generate scaffold BuildingLevel level:integer price:json params:json building_type:references
# rails generate scaffold Building comment:string params:json building_level:references settlement:references
# rails generate scaffold Country title:string params:json 
# rails generate scaffold Region title:string params:json 
# rails generate scaffold FossilType title:string
# rails generate scaffold PlantPlace title:string plant_place_type:string
# rails generate scaffold TroopType title:string params:json
# rails generate scaffold ArmySize level:integer params:json
# rails generate scaffold Army region:references player:references army_size:references
# rails generate scaffold Troop troop_type:references is_hired:boolean army:references
# rails generate scaffold Credit sum:integer deposit:integer procent:float start_year:integer duration:integer
# rails generate scaffold InfluenceItem value:integer player_id:integer entity_id:integer entity_type:string comment:string year:integer
# rails generate scaffold RelationItem value:integer country_id:integer entity_id:integer entity_type:string comment:string year:integer






