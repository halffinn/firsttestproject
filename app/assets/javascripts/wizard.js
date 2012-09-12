//= require jquery.inlineedit

PhotoManager = {
  initialize: function(sortUrl){
    this.initializePhotoSortable(sortUrl);
  },
  initializePhotoSortable: function(sortUrl){
    self = this;
    $('#photos_list').sortable({
        grid: [8,2],
        start: function(event, ui) {
          $(event.currentTarget).addClass('noclick');
        },
        stop: function(event, ui) {
          self.afterSort();

          $.ajax({
            type: 'PUT',
            url: sortUrl,
            data: $('#photos_list').sortable('serialize'),
            success: function() {
              validatePanels();
            }
          });
        }
    });

    self.afterSort();
    self.showLatestPhoto();

    $('#photos_list li').live('click', function(){
      if(!$(this).parent().hasClass('noclick')){
       PhotoManager.setPhoto($(this).find('img'));
      }
      $(this).parent().removeClass('noclick');
    });
  },
  afterSort: function(event, ui){
    if($('#photos_list li').size() > 0) {
      $('.photos_wrapper').show();
    } else {
      $('.photos_wrapper').hide();
    }

    $('#photos_list li').removeClass("active");
    $('#photos_list li:first').addClass("active");

    $('#photos_list li').hover(function() {
      $(this).find(".photo_action").show();
    }, function() {
      $(this).find(".photo_action").hide();
    });
  },
  deletePhoto: function(photo){
    self = this;
    photo.fadeOut('slow', function(){
      photo.parent().remove();
      self.showLatestPhoto();
      validatePanels();
    });
  },
  showLatestPhoto: function() {
    var photo = $('#photos_list li img').last();
    if(photo.size() > 0) {
      PhotoManager.setPhoto(photo);
    } else {
      $('.photo_wrapper').empty();
    }
  },
  insert: function(newList) {
    $('#photos_list').html(newList);
    this.afterSort();
    this.showLatestPhoto();
    validatePanels();
  },
  adjustScroll: function() {
    $('html').animate({scrollTop: $('.photo_wrapper').offset()['top'] - 60}, "slow");
  },
  setPhoto: function(photo) {
    $('.photo_wrapper').empty();

    var img_wrapper = $("<div class='active-photo well'></div>");

    var large_photo = photo.clone();
    large_photo.attr('src', large_photo.attr('data-large'));
    img_wrapper.append(large_photo);

    var large_photo_label_text = "";

    if(large_photo.attr('data-name') != "") {
      large_photo_label_text = large_photo.attr('data-name');
    } else {
      large_photo_label_text = "Click here to add caption";
    }

    var large_photo_label = $("<div class='active-label' data-image-id='" + large_photo.attr("data-id") + "'>" + large_photo_label_text + "</div>");

    img_wrapper.append(large_photo_label);

    $('.active-label').inlineEdit({
      placeholder: "Click here to add caption",
      save: function(e, data) {
        trunc = data.value;
        if (data.value.length > 20) {
          trunc = data.value.substring(0, 20) + '...';
        }
        img_div = $("#image-" + $(this).attr('data-image-id'));
        img_div.find('img.photo').attr('data-name', data.value);
        img_div.find('img.photo').attr('data-trunc_name', trunc);
        img_div.find('~ .photo_title').html(trunc);
        updatePhotoLabel($(this).attr('data-image-id'), data.value)
      }
    });

    $('.photo_wrapper').append(img_wrapper);
    this.adjustScroll();
  }
}