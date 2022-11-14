$(document).ready(function(){
    // select all on focus on invite URL inputs
    $("input.invite-url").focus(function() { $(this).select(); } );

    // expand invite URL on button press
    $('input.invite-btn').click(function () {
        var divId = $(this).data('invite-area');
        var div = $('#'+divId);
        div.show();
    })
});
