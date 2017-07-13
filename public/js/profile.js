$(document).ready(function() {
  let urlObject = new URL(url)
  let searchParams = new URLSearchParams(url.search);
  let user_id = searchParams.get('user')
  var elo_history = [];
  $.ajax({
    type: "GET",
    url: `https://sigpong.herokuapp.com/api/users/#{user_id}`,
    success: function(user) {
      elo_history = user.elo_history;
      matches = user.matches;
      $('#user-name').append(user.user_name);
      $('#wins').append(user.wins + "W");
      $('#losses').append(user.losses + "L");
      $('#elo').append(user.elo + " ELO");
      $('#win-streak').append(user.winning_streak + "W");
      $('#lose-streak').append(user.losing_streak + "L");
    },
  });
});
