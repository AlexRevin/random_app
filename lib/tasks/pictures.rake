namespace :pictures do
  desc "Sync all Pictures to PicutreItems"
  task sync: :environment do
    Picture.find_in_batches do |group|
      group.each(&:sync_picture_items!)
    end
  end

end
