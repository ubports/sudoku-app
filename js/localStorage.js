// Database operations file. Borrowed from
// UbuntuPhoneRedditApp
//.import QtQuick.LocalStorage 2.0 as LocalStorage

function getDatabase() {
    return LocalStorage.openDatabaseSync("SudokuTouch", "1.0", "StorageDatabase", 1000000);
}

function initialize() {
    var db = getDatabase();
    var fname = i18n.tr("Sudoku")
    var lname = i18n.tr("User")

    db.transaction(
                function(tx) {
                    // Create the settings table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('PRAGMA foreign_keys = ON;');


                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
                    //print("setting table created.")
                    tx.executeSql('CREATE TABLE IF NOT EXISTS profiles(id INTEGER PRIMARY KEY AUTOINCREMENT, first_name TEXT, last_name TEXT, UNIQUE(first_name, last_name) ON CONFLICT ROLLBACK)');
                    //print("profile table created.")

                    tx.executeSql('INSERT OR IGNORE INTO profiles VALUES (null,?,?);', [fname, lname]);
                    tx.executeSql('CREATE TABLE IF NOT EXISTS scores(id INTEGER PRIMARY KEY AUTOINCREMENT, profile_id INTEGER, score INTEGER NOT NULL, game_date DATE, FOREIGN KEY(profile_id) REFERENCES profiles(id))');
                    //print("scores table created.")



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

function isSettingsTableEmpty() {
    var db = getDatabase();
    var res="";

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings;');
        if (rs.rows.length > 0) {
            return false;
        } else {
            return true;
        }
    })

    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return res
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

function insertNewScore(profile_id, score)
{
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO scores VALUES (null,?,?,datetime());', [profile_id, score]);
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

function deleteScoreWithId(id)
{
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM scores WHERE id=?;', [id]);
        //console.log(id, rs.rowsAffected)
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

    //print("GETTING ALL SCORES")
    db.transaction( function(tx) {
        var rs = tx.executeSql("SELECT id, profile_id, score FROM scores order by score desc limit 10;");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            res.push([dbItem.id, dbItem.profile_id, dbItem.score])
        }
    });
    //print(res);
    return res;
}

function getAllScoresForUser(profile_id)
{
    var db = getDatabase();
    var res=new Array();

    //print("GETTING ALL SCORES")
    db.transaction( function(tx) {
        var rs = tx.executeSql("SELECT score FROM scores WHERE profile_id=? order by score desc limit 10;",[profile_id]);
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            //print(dbItem.profile_id, dbItem.score)
            res.push([dbItem.profile_id, dbItem.score])
        }
    });
    //print (res);
    return res;
}

function printObject(o)
{
    var out = '';
    for(var p in o){
        out+=p+': '+o[p]+'\n';
    }
    //console.log(out)
}

function getAllProfiles()
{
    var db = getDatabase();
    var res=new Array();

    //print("GETTING ALL PROFILES")
    db.transaction( function(tx) {
        var rs = tx.executeSql("SELECT * FROM profiles limit 10;");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            var o = new Object();
            o["id"] = dbItem.id;
            o["lastname"] = dbItem.last_name;
            o["firstname"] = dbItem.first_name;
            res.push(o)
        }
    });
    //print(res);
    return res;
}


function deleteProfile(id)
{

    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM profiles WHERE id=? ;', [id]);

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


function updateProfile(id, lastname, firstname)
{

    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE profiles SET first_name=?, last_name=? WHERE id=? ;', [firstname, lastname, id]);

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

function insertProfile(lastname, firstname)
{

    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR IGNORE INTO profiles VALUES (null,?,?);', [firstname, lastname]);

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

function existProfile(lastname, firstname)
{
    var db = getDatabase();
    var res="";

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT id FROM profiles WHERE last_name=? AND first_name=?;', [lastname, firstname]);
        if (rs.rows.length > 0) {
            res = true
        } else {
            res = false
        }
    })


    return res
}

function getUserFirstName(profile_id)
{
    var db = getDatabase();
    var res="";

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT first_name FROM profiles WHERE id=?;', [profile_id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).first_name;
        } else {
            res = "Unknown";
        }
    })

    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return res
}

function getUserLastName(profile_id)
{
    var db = getDatabase();
    var res="";

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT last_name FROM profiles WHERE id=?;', [profile_id]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).last_name;
        } else {
            res = "Unknown";
        }
    })

    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return res
}
