import 'package:sqlite3/sqlite3.dart';

void main() {
  // Path to the database file
  final dbPath =
      'C:/Users/oskar/OneDrive/Desktop/Home/Programming/Databases/PractiseDatabase.db';
  final database = sqlite3.open(dbPath);

  //This is an insert statement. It creates a new record in the table.
  //database.execute("INSERT INTO TEST VALUES (1, 'Oska');");

  //This is an update statement. It updates an existing record in the table.
  //database.execute("UPDATE TEST SET y = 'Bilbo' WHERE x = 1;");

  //This is a delete statement. It deletes an existing record in the table.
  //database.execute("DELETE FROM TEST WHERE y='Bilbo';");
  //This is a select statement. It return a list of maps, each list item represents a record. Each map has field as a string allocated to the value.
  final result = database.select("SELECT * FROM TEST;");
  print(result);
  database.dispose();
}
