Replymaker = {};
Replymaker.suggested_keywords = ["Refund","Cancel","Unable","Hours","Hiring","Resume","Human Resources"];
Replymaker.show_suggestions = function () {
  $('.keyword_suggestions').remove();
  var input = $(".new_reply input[name='reply[keywords]']");
  input.after("<div class='keyword_suggestions'></div>");
  for (var i=0;i < Replymaker.suggested_keywords.length;i++) {
    var text = Replymaker.suggested_keywords[i];
    if (input.val().indexOf(text) >= 0) { continue; }
    var a = document.createElement('a');
    a.text = text;
    a.setAttribute('class','button button-light button-mini keyword');
    a.setAttribute('data-keyword',text);
      $(document).on('click', a, function (e) {
          Replymaker.add_keyword(e.target.textContent);
          Replymaker.show_suggestions();
      });
    a.addEventListener( 'click', function (e) {
        alert('clicked');
    });
    $('.keyword_suggestions').append(a)
  }
};
Replymaker.get_suggestions = function () {
  $.get("/replies/suggest");
};
Replymaker.add_keyword = function (word) {
    if ( $.isFunction($.fn.tagsinput) ) {
        $(".new_reply input[name='reply[keywords]']").tagsinput(word);
    }else{
        $(".new_reply input[name='reply[keywords]']").val($("input[name='reply[keywords]']").val() + ", " + word);
    }
};