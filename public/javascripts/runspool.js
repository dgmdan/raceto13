function updateTeamUser(league_id, team_id, selected)
{
    $.ajax({
        type: "POST",
        url: "/leagues/" + league_id + "/update_teams.js",
        data: {"team_id": team_id, "selected": selected},
        dataType: "script"
    });
}
