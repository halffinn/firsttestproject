class LoadServiceAmenities < ActiveRecord::Migration
  def up
    g = AmenityGroup.create!(name: 'Domestic Care')
    g.amenities.create!(name: 'Plan and Prepare Meals')
    g.amenities.create!(name: 'House Keeping')
    g.amenities.create!(name: 'Organize and Supervise home maintenance and modification')
    g.amenities.create!(name: 'Care of plants and gardening assistance')
    g.amenities.create!(name: 'Assist with pet care')
    g.amenities.create!(name: 'Assist with entertaining')
    g.amenities.create!(name: 'Assist with airport and travel needs')
    g.amenities.create!(name: 'Provide companionship and conversation')
    g.amenities.create!(name: 'General shopping')
    g.amenities.create!(name: 'Participate in crafts')
    g.amenities.create!(name: 'Play mind stimulating games')

    g = AmenityGroup.create!(name: 'Personal Care')
    g.amenities.create!(name: 'Washing, showering and dressing', searchable: true)
    g.amenities.create!(name: 'Managing incontinence care')
    g.amenities.create!(name: 'Assist with eating')
    g.amenities.create!(name: 'Assist with mobility and walking', searchable: true)
    g.amenities.create!(name: 'Escorting to appointments / shopping')
    g.amenities.create!(name: 'Assistance with communication')
    g.amenities.create!(name: 'Dementia or alzheimers care', searchable: true)
    g.amenities.create!(name: 'Respite or convalescence care', searchable: true)

    g = AmenityGroup.create!(name: 'Qualifications')
    g.amenities.create!(name: 'Two references available')
    g.amenities.create!(name: 'First aid qualifications')
    g.amenities.create!(name: 'Relevant degree')
    g.amenities.create!(name: 'Relevant professional training', searchable: true)
    g.amenities.create!(name: "Driver's license")
    g.amenities.create!(name: 'Have a car')
    g.amenities.create!(name: 'Police check available')
    g.amenities.create!(name: 'Do you smoke')
  end

  def down
  end
end
