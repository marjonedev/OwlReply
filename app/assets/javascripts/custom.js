$(function() {
    $('.style-msg').on('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
        $(this).remove();
    });
});