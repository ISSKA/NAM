class Asset < ApplicationRecord
  # Validations
  validates :description, :product_serial, :date_purchase, :user, :asset_type, presence: true

  belongs_to :user
  belongs_to :asset_type
  has_many :battery_replacements, dependent: :destroy
  has_many :asset_missions, dependent: :destroy
  has_many :missions, through: :asset_missions

  ## Return remaining battery hours at NOW
  def get_battery_status
    last_bat_repl = battery_replacements.last
    if last_bat_repl
      battery_tlived = (DateTime.now.to_i - last_bat_repl.created_at.to_i) / 3600
    else
      battery_tlived = (DateTime.now.to_i - date_purchase.to_i) / 3600
    end
    battery_state = battery_life - battery_tlived
    if battery_state < 0
      battery_state = 0
    end
		if battery_out
			battery_state = 0
		end
    return battery_state.to_i
  end

  ## Return remaining battery % at NOW
  def get_battery_status_pct
    battery_state = get_battery_status * 100 / battery_life
    if battery_state < 0
      battery_state = 0
    end
    return battery_state
  end

  def has_current_mission
    if get_current_missions.length > 0
      return true
    end
    return false
  end

  def get_current_missions
    current_mission = []
    missions.each do |mission|
      running_asset_missions = asset_missions.where(mission: mission).where(extracted_at: nil)
      running_asset_missions += asset_missions.where(mission: mission).where('extracted_at >= ?', DateTime.now)
      # if mission.ending_date > DateTime.now && running_asset_missions.count > 0
      if running_asset_missions.count > 0
        current_mission.push(mission)
      end
    end
    current_mission.uniq
    return current_mission
  end

  def get_missions
    return asset_missions
  end

end
