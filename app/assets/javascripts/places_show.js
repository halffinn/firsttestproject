var PlaceShow = {
  initialize: function(opts){
    //*******************************************************************************************
    // INITIALIZERS
    //*******************************************************************************************
    var self = this;
    self.initializeSlider();
    self.initializeSharePlace(opts.share_title, opts.share_url, opts.share_id);

    // Lazy Initialize Map and calendar
    $('a[data-toggle="tab"]').on('shown', function (e) {
      // Lazy load calendar
      if ($(e.target).attr('href') == '#calendar-tab') {
        self.initializeCalendar(opts.cal_events, opts.cal_lastVisibleDay, opts.cal_month);
      };
      // Lazy load map
      if ($(e.target).attr('href') == '#map-tab') {
        self.initializeMap(opts.map_lat, opts.map_lon, opts.map_cityName, opts.map_countryName);
      }
    });
  },
  
  //*******************************************************************************************
  // Photo slider
  //*******************************************************************************************
  initializeSlider: function() {
    var slider = $('#photo-slider');
    if(slider.length > 0) {
      slider.tinycarousel({ interval: true, pager: true, animation: false, fading: true });

      $('.extra-paginator').click(function() {
        slider.tinycarousel_move($(this).attr('data-page'));
        return false;
      });
    }    
  },

  //*******************************************************************************************
  // Google Map initialization
  //*******************************************************************************************    
  initializeMap:  function(lat, lon, cityName, countryName) {
    var mapOptions = {
      zoom: 15,
      center: new google.maps.LatLng(lat, lon),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    var map = new google.maps.Map(document.getElementById('map'),mapOptions);

    var marker = new google.maps.Marker({
      position: new google.maps.LatLng(lat, lon),
      map: map,
      title: cityName + ', ' + countryName
    });
  },

  //*******************************************************************************************
  // Calendar initialization
  //*******************************************************************************************
  initializeCalendar: function(events, lastVisibleDay, month) {
    $('#first-calendar').fullCalendar({
      header   : {left: 'prev', center: 'title', right: ''},
      editable : false,
      events   : events,         // A URL of a JSON feed that the calendar will fetch Event Objects from
      visEnd   : lastVisibleDay  // A Date object of the day after the last visible day
    });

    $('#second-calendar').fullCalendar({
      header   : { left: '', center: 'title', right: 'next'},
      editable : false,
      events   : events,         // A URL of a JSON feed that the calendar will fetch Event Objects from
      month    : month,          // The initial month when the calendar loads.
      visStart : false
    });

    $('.fc-header-left .fc-button-inner').hide();

    $('#first-calendar .fc-header-left .fc-button-prev').click(function() {
      $('#second-calendar').fullCalendar('prev');
      var first_cal = $('#first-calendar').fullCalendar('getDate');
      var cur_date = new Date();
      if (first_cal.getMonth() == cur_date.getMonth()) {
        $('.fc-header-left .fc-button-inner').hide();
      } else{
        $('.fc-header-left .fc-button-inner').show();
      }
    });

    $('#second-calendar .fc-header-right .fc-button-next').click(function() {
      $('#first-calendar').fullCalendar('next');
      $('.fc-header-left .fc-button-inner').show();
    });
    
    $('#first-calendar').fullCalendar('render');
    $('#second-calendar').fullCalendar('render');
  },

  //*******************************************************************************************
  // Share Buttons initialization
  //*******************************************************************************************
  initializeSharePlace: function(title, url, id) {
    $('.sharePlace').bookmark({
      sites: ['facebook', 'twitter', 'google'],
      showAllText: 'Show all ({n})',
      title: title,
      hint: 'Share this place',
      url: url //+ ' ' + id
    });    
  }    
}