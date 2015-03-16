$(document).ready(function(){
    $('input#quantity').on('keyup paste',function(){
        if ($.isNumeric($('input#quantity').val())) {
            $('#cost').text('$'+$('#quantity').val()*10);
        }
        else {
            $('#cost').text('');
        }
    });

    $('form#buy_entries').submit(function() {
        var c = confirm("I've read the rules and will pay the " + $('#cost').text() + " entry fee.");
        return c;
    });
});
