$(document).ready(function(){$("input.invite-url").focus(function(){$(this).select()}),$("input.invite-btn").click(function(){var i=$(this).data("invite-area");$("#"+i).show()})});