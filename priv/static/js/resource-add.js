$(document).ready(function(){
  $("#tags").columnize({ columns: 3 })
  $('tagit-placeholder').html('');
  Window.ms = $('#ms-suggest').tagit({
    fieldName: 'f[tags]',
    autocomplete: {delay: 0, minLength: 1},
    showAutocompleteOnFocus: true,
    caseSensitive: false,
    allowSpaces: true,
    singleField: true,
    singleFieldDelimiter: "|",
    placeholderText: "Enter your tags",
    afterTagRemoved: function(event, ui) {
      // do something special
      txt = ui.tagLabel
      id = txt.replace(/ /g,"_").replace(/,/g,"_");
      $('#' + id).html('<a href="#">' + txt + '</a>' )
    }  
  });

  $('.tagsuggestion').on('click', function(e) {
    txt = $(this).text()
    $(this).html(txt)
    Window.ms.tagit("createTag", txt)
    return(false);
  })
})

