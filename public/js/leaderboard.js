$(document).ready(function() {

  $.ajax({
    type: "GET",
    url: "api/users?team_id=59408e751865720006b81b9d",
    success: function(data) {
      var users_count = 0;
      var matches_count = 0;
      for (var user in data.users) {
        game = data.games[game];
        active_teams_count += game.active_teams_count;
        users_count += game.users_count;
        matches_count += game.matches_count;
      }
      $('#matches').hide().text(
        active_teams_count + " active teams with " + matches_count + ' games played by ' + users_count + " players!"
      ).fadeIn('slow');
    },
  });

});