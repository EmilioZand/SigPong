$(document).ready(function() {
  $('#avatar').hide();
  let url = new URL(window.location.href)
  let searchParams = new URLSearchParams(url.search);
  let user_name = searchParams.get('user');
  let ajaxUrl = "api/users/user?user_name=" + user_name;
  console.log(user_name);
  let elo_history = [];
  $.ajax({
    type: "GET",
    url: ajaxUrl,
    success: function(user) {
      elo_history = user.elo_history;
      matches = user.matches;
      let streak_text = "";
      if(user.current_streak_is_win === true){
        streak_text = "W" + user.current_streak;
      } else if(user.current_streak_is_win === false) {
        streak_text = "L" + user.current_streak;
      }
      let win_rate = ((user.wins / (user.wins + user.losses))*100).toFixed(2);
      $('#user-name').append(user.user_name);
      if(user.avatar.length > 0){
        $('#avatar').attr("src",user.avatar);
        $('#avatar').show();
      }
      $('#current-elo').append((user.elo + 1200) + " ELO");
      $('#win-rate').append(win_rate + "%");
      $('#wins').append(user.wins + "W");
      $('#losses').append(user.losses + "L");
      $('#max-elo').append((Math.max(...user.elo_history) + 1200));
      $('#min-elo').append((Math.min(...user.elo_history) + 1200));
      $('#win-streak').append(user.winning_streak + "W");
      $('#lose-streak').append(user.losing_streak + "L");
      $('#current-streak').append(streak_text);
    },
  });
});
