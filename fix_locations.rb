# FIX MISSING LAT/LNG FIELDS USING THE ENTERED ADDRESS
#
# It sometimes happens that the latitude and longitude are not properly
# resolved from the entered (or selected) address by the JavaScript. In
# these cases, they are both set to zero, which results in very long
# distances within the teams and less-than-ideal results.
#
# So, this script runs through the enrollments for a given course ID and
# resolves any missing LAT/LNG values via the Google Maps API.
#
# Run with `bundle exec rails r fix_locations.rb`

def fix_the_locations(course_id)
  course = Course.find course_id rescue return p 'Nothing to do, course does not exist.'

  members = course.enrollments

  members.each do |m|
    data = m.data.dup

    lat = data['location']['latitude']
    lng = data['location']['longitude']

    if lat == '0' || lng == '0'
      location = data['location']['text']

      p "Fetching LAT/LNG for enrollment ##{m.id} at address #{location}..."
      lat, lng = fetch_lat_lng location
      p "Found #{lat}/#{lng}"

      data['location']['latitude'] = lat.to_s
      data['location']['longitude'] = lng.to_s

      m.data = data
      m.save

      # Sleep for a bit so that we don't hit the Google Maps limit immediately
      sleep 2
    end
  end
end

def fetch_lat_lng(location)
  Geocoder.coordinates location
end

puts 'Please enter a course ID:'
id = STDIN.gets.chomp

fix_the_locations id
