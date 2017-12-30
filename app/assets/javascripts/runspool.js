$(document).ready(function(){
    $('input#quantity').on('keyup paste',function(){
        if ($.isNumeric($('input#quantity').val())) {
            $('#cost').text('$'+$('#quantity').val()*5);
        }
        else {
            $('#cost').text('');
        }
    });

    $('form#buy_entries').submit(function() {
        var c = confirm("I've read the rules and will pay the " + $('#cost').text() + " entry fee.");
        return c;
    });

    $('span.runs-marker').tooltip({'placement': 'top'});
});
