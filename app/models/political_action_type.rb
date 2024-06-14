class PoliticalActionType < ApplicationRecord
  SEDITION_PO = 5
	has_many :political_actions, dependent: :destroy

  def execute(options)
    if self.respond_to?(self.action)
      self.send(self.action, options)
    end
  end

  def sedition(options)
    region = Region.find_by_id(options[:region_id])
    if region
      region.params["public_order"] -= SEDITION_PO
      region.save
    end
  end
end
