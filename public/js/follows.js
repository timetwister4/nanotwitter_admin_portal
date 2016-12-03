$('#follow').click(function(){
	$.ajax({
          url: "/user/follow",
          type: "POST",
          data: {user_name: $(this).attr('data-user-name')}
	})
})

$('#unfollow').click(function(){
	$.ajax({
          url: "/user/unfollow",
          type: "POST",
          data: {user_name: $(this).attr('data-user-name')}
	})
})