$(document).ready(function() {

  $.ajax({
    type: "GET",
    url: "api/matches?team_id=59408e751865720006b81b9d",
    success: function(data) {
      var table = $('<table></table>').addClass('recent-matches');
      $table.append( '<th><td>' + 'Winner' + '</td><td>' + 'Loser' + '</td><td>'+ 'Score' + '</td><td>' + "ELO Change" + '</td></th>' );
      for (var match in data.matches) {
        var games = match.scores;
        var loserScore = 0;
        var winnerScore = 0;
        var eloChange = match.winners[0].elo_history.pop();
        for(score in games){
          score[0] > score[1] ? loserScore++ : winnerScore++;
        }
        var overallScore = winnerScore + ' : ' + loserScore
        $table.append( '<tr><td>' + match.winners[0].user_name + '</td><td>' + match.score[0].user_name + '</td><td>'+ overallScore + '</td><td>' + eloChange + '</td></tr>' );
      }
      $('#recent-matches').append(table);
    },
  });
});
