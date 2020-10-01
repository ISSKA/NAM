class Mission < ApplicationRecord
  # Validations
  validates :project_name, :description, :starting_date, :user, presence: true
  validate :starting_ending_date_validation

  belongs_to :user
  has_many :asset_missions, dependent: :destroy
  has_many :assets, through: :asset_missions

  def starting_ending_date_validation
    if starting_date && ending_date && starting_date > ending_date
      errors.add(:base, "can't be anterior the starting date")
    end
  end

  def get_current_assets
    current_asset = []
    asset_missions.each do |asset_mission|
      asset = asset_mission.asset
      if asset_mission.extracted_at.nil? || asset_mission.extracted_at > DateTime.now
        current_asset.push(asset)
      end
    end
    return current_asset
  end

end
