jQuery(function ($) {

    var $timezone = $('#time_zone');
    var $location = $('#location');
    var $locationLat = $('#location_lat');
    var $locationLng = $('#location_lng');
    var $map = $('#location_map');

    // Set the timezone automatically, based on the browser's time
    // Only do this if the time zone field can be found and it has not been pre-filled by the server.
    if ($timezone.length && !$timezone.val()) {
        var currentTzOffsetInSeconds = new Date().getTimezoneOffset() * 60;
        $timezone.val(-currentTzOffsetInSeconds);
    }

    if ($map.length) {
        $map.locationpicker({
            radius: 0,
            zoom: 4,
            location: {
                latitude: $locationLat.val(),
                longitude: $locationLng.val()
            },
            locationName: $location.val(),
            enableAutocomplete: true,
            inputBinding: {
                locationNameInput: $location,
                latitudeInput: $locationLat,
                longitudeInput: $locationLng
            }
        });
    }

});
