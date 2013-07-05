// Database operations file. Borrowed from
// UbuntuPhoneRedditApp

function getDatabase() {
    return LocalStorage.openDatabaseSync("SudokuTouch", "1.0", "StorageDatabase", 1000000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // Create the settings table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
                    print("setting table created.")
                    tx.executeSql('CREATE TABLE IF NOT EXISTS scores(id INTEGER PRIMARY KEY AUTOINCREMENT, first_name TEXT, last_name TEXT, score INTEGER NOT NULL, game_date DATE)');
                });
}
function setSetting(setting, value) {
    // setting: string representing the setting name (eg: “username”)
    // value: string representing the value of the setting (eg: “myUsername”)
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
        //console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve a setting from the database
function getSetting(setting) {
    var db = getDatabase();
    var res="";

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = "Unknown";
        }
    })

    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return res
}

function insertNewScore(first_name, last_name, score)
{
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO scores VALUES (null,?,?,?,datetime());', [first_name,last_name, score]);
        //console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function getAllScores()
{
    var db = getDatabase();
    var res=new Array();

    print("GETTING ALL SCORES")
    db.transaction( function(tx) {
        var rs = tx.executeSql("SELECT * FROM scores order by score limit 10;");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
        }
    });
    print(res);
    return res;
}

function getAllScoresForUser(first_name, last_name)
{
    var db = getDatabase();
    var res=new Array();

    print("GETTING ALL SCORES")
    db.transaction( function(tx) {
        var rs = tx.executeSql("SELECT first_name, last_name, score FROM scores WHERE first_name=? and last_name=? order by score limit 10;",[first_name, last_name]);
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            res.push([dbItem.first_name, dbItem.last_name, dbItem.score])
        }
    });
    print (res);
    return res;
}

