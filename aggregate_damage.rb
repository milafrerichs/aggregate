require 'terraformer'

data = File.read("buildings-points.geojson")
boundaries = File.read("poverty.geojson")

points = Terraformer.parse(data)
admin_level = Terraformer.parse(boundaries)

points.features.each do |feature|
  p "Admin: #{admin_level.features.count}"
  index = 0
  admin_level.features.map do |admin|
    index += 1
    if feature.geometry.within? admin.convex_hull
      case feature.properties['all']
      when "1"
        admin.properties["DESTROYED"] = (admin.properties["DESTROYED"] || 0) + 1
      when "2"
        admin.properties["MODERATE_DAMAGE"] = (admin.properties["MODERATE_DAMAGE"] || 0) + 1
      when "3"
        admin.properties["MINOR_DAMAGE"] = (admin.properties["MINOR_DAMAGE"] || 0) + 1
      end
      break
    end
  end
  p "#{index}"
end
File.open("building-damages.geojson", 'w') { |f| f.write(admin_level.to_json) }
