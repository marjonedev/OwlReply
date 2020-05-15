Replymaker = {};
Replymaker.suggested_keywords = ["Refund","Cancel","Unable","Hours","Hiring","Resume","Human Resources"];
Replymaker.show_suggestions = function (elem = false) {

    var input = $(".new_reply input[name='reply[keywords]']");

    if(elem){
        $(elem).find('.keyword_suggestions').remove();
        input = $(elem).find("input[name='reply[keywords]']");
    }else{
        $('.keyword_suggestions').remove();
    }
  input.after("<div class='keyword_suggestions'></div>");
  for (var i=0;i < Replymaker.suggested_keywords.length;i++) {
    var text = Replymaker.suggested_keywords[i];
    if (input.val().indexOf(text) >= 0){ continue; }
    var a = document.createElement('a');
    a.text = text;
    a.setAttribute('class','button button-light button-mini keyword');
    a.setAttribute('data-keyword',text);
    a.addEventListener( 'click', function (e) {
        Replymaker.add_keyword(e.target.textContent, $(this));
        var el = $(this).closest('.new_reply');
        Replymaker.show_suggestions(el);
    });
      if(elem){
          $(elem).find('.keyword_suggestions').append(a);
      }else{
          $('.keyword_suggestions').append(a);
      }
  }
};
Replymaker.get_suggestions = function () {
  $.get("/replies/suggest");
};
Replymaker.add_keyword = function (word, elem) {
    if ( $.isFunction($.fn.tagsinput) ) {
        $(elem).closest(".new_reply").find("input[name='reply[keywords]']").tagsinput('add', word);
    }else{
        let inputKeywords = $(elem).closest(".new_reply").find("input[name='reply[keywords]']");
        if(inputKeywords.val() == ""){
            inputKeywords.val(word);
        }else{
            inputKeywords.val(inputKeywords.val() + ", " + word);
        }
    }
};

$(function(){
    $(document).on('turbolinks:load', function () {
       $("input[name='reply[keywords]'], input[data-role='tagsinput']").tagsinput();
    });
});