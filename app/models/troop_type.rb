class TroopType < ApplicationRecord
	has_many :troops, dependent: :destroy

  MILITIA = 1
  HEAVY_MILITIA = 2
  CAVALRY = 3
  CANNON = 4


  def power
    
  end

  def self.upgrade_paths
    {
      MILITIA => HEAVY_MILITIA,
      HEAVY_MILITIA => CAVALRY,
      CAVALRY => CANNON,
    }
  end
end
