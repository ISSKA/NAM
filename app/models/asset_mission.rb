class AssetMission < ApplicationRecord
  # Validations
  mount_uploader :attachment, AttachmentUploader # Tells rails to use this uploader for this model.   
  validates :user, :mission, :asset, :placed_at, :img, presence: true
  validate :one_asset_per_mission_at_a_time
  validate :created_extracted_date_validation
  validate :all_position_required

  belongs_to :asset
  belongs_to :mission
  belongs_to :user

  def created_extracted_date_validation
    if placed_at && extracted_at && placed_at > extracted_at
      errors.add(:base, "can't be anterior the placed date")
    end
    if extracted_at != nil
        if extracted_at > DateTime.now
             errors.add(:base, "can't be in the future" )
        end
        
    end

  end

  def one_asset_per_mission_at_a_time
    asset.get_missions.each do |mission|
        if mission.extracted_at != nil && mission != self
            if self.placed_at < mission.extracted_at && self.placed_at > mission.placed_at
                errors.add(:base, 'Conflict with mission ')
                break
            end
        end
        if self.extracted_at != nil && mission != self
            if self.extracted_at > mission.placed_at && mission.extracted_at == nil
	            errors.add(:base, 'Conflict with mission ')
                break
            end
            if self.extracted_at > mission.placed_at && mission.extracted_at > self.extracted_at
                errors.add(:base, 'Conflict with mission ')
                break
            end
        end

    end
  end

  def all_position_required
    if position_x || position_y || position_z
      unless position_x && position_y && position_z
        errors.add(:base, 'All position fields should be defined')
      end
    end
  end
end
