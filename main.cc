#include <iostream>
#include <string>
#include <vector>
#include <mysql/mysql.h>



using namespace std;

int current_user_id = -1; // not logged in

struct Restaurant {
    int id;
    string name;
    string cuisine;
    string borough;
};

struct Db {
  MYSQL* conn;

  Db(const char* host,
     const char* user,
     const char* pass,
     const char* db) {

    conn = mysql_init(nullptr);
    if (!mysql_real_connect(conn, host, user, pass, db, 3306, nullptr, 0)) {
      throw std::runtime_error(mysql_error(conn));
    }
  }

  ~Db() {
    mysql_close(conn);
  }
};

//helper functions

static void execOrThrow(MYSQL* conn, const std::string& q) {
  if (mysql_query(conn, q.c_str()) != 0) {
    throw std::runtime_error(mysql_error(conn));
  }
}

static MYSQL_RES* queryResOrThrow(MYSQL* conn, const std::string& q) {
  execOrThrow(conn, q);
  MYSQL_RES* res = mysql_store_result(conn);
  if (!res) throw std::runtime_error(mysql_error(conn));
  return res;
}

static std::string sqlEscape(MYSQL* conn, const std::string& s) {
  std::string out;
  out.resize(s.size() * 2 + 1);
  unsigned long n = mysql_real_escape_string(conn, out.data(), s.c_str(), s.size());
  out.resize(n);
  return out;
}




//vector<Restaurant> restaurants;

void showMenu() {
    cout << "==============================\n";
    cout << "   NYC Restaurant Finder - Prototype   \n";
    cout << "==============================\n";
    cout << "1) Show sample restaurants\n";
    cout << "2) About this project\n";
    cout << "3) Create restaurant\n";
    cout << "4) Read restaurant\n";
    cout << "5) Update restaurant\n";
    cout << "6) Delete restaurant\n";
    cout << "7) Filter restaurants\n";
    cout << "8) Create User\n";
    cout << "9) Login\n";
    cout << "10) Favorite restaurant\n";
    cout << "11) Rate restaurants\n";
    cout << "12) Analytics: Safest estaurants\n";
    cout << "13) Analystics: 311 complaints\n";
    cout << "14) Analytics: Open Restaurants compliance\n";
    cout << "15) Show my favorites\n";
    cout << "0) Exit\n";
    cout << "Choose an option: ";
}

void showSampleRestaurants() {
    vector<Restaurant> sample = {
        {1, "Thai Villa", "Thai", "Manhattan"},
        {2, "Prince Street Pizza", "Italian", "Manhattan"},
        {3, "Tacos El Bronco", "Mexican", "Brooklyn"}
    };

    cout << "\nSample Restaurant Results:\n";
    for (auto &r : sample) {
        cout << " - " << r.name
                  << " | " << r.cuisine
                  << " | " << r.borough << "\n";
    }
    cout << "\n";
}

void showAbout() {
    cout << "\nNYC Restuarant Finder is a restaurant finder app \n"
              << "that integrates NYC health inspections, \n"
              << "Open Restaurants compliance, and 311 complaint data.\n\n";
}

void createRestaurant(Db& db) {
  std::string name, borough, address, zip;

  cout << "Enter name: ";
  getline(cin, name);

  cout << "Enter borough: ";
  getline(cin, borough);

  cout << "Enter street address (optional): ";
  getline(cin, address);

  cout << "Enter zip (optional): ";
  getline(cin, zip);

  name = sqlEscape(db.conn, name);
  borough = sqlEscape(db.conn, borough);
  address = sqlEscape(db.conn, address);
  zip = sqlEscape(db.conn, zip);

  execOrThrow(db.conn,
    "INSERT INTO restaurants(name) VALUES('" + name + "')");

  long long rid = mysql_insert_id(db.conn);

  // optional location row
  if (!borough.empty() || !address.empty() || !zip.empty()) {
    execOrThrow(db.conn,
      "INSERT INTO locations(restaurant_id, boro, street_address, zip) VALUES(" +
      std::to_string(rid) + ",'" + borough + "','" + address + "','" + zip + "')");
  }

  cout << "Restaurant added with restaurant_id=" << rid << "\n\n";
}


void readRestaurant(Db& db) {
  auto res = queryResOrThrow(db.conn,
    "SELECT r.restaurant_id, r.name, COALESCE(l.boro,'') "
    "FROM restaurants r "
    "LEFT JOIN locations l ON l.restaurant_id=r.restaurant_id "
    "ORDER BY r.restaurant_id DESC LIMIT 25");

  cout << "\n--- Restaurants (latest 25) ---\n";
  MYSQL_ROW row;
  while ((row = mysql_fetch_row(res))) {
    cout << row[0] << " | " << row[1] << " | " << row[2] << "\n";
  }
  mysql_free_result(res);
  cout << "\n";
}



void updateRestaurant(Db& db) {
  std::string id, name;
  cout << "Enter restaurant_id to update: ";
  getline(cin, id);

  cout << "New name: ";
  getline(cin, name);

  name = sqlEscape(db.conn, name);

  execOrThrow(db.conn,
    "UPDATE restaurants SET name='" + name + "' WHERE restaurant_id=" + id);

  cout << "Updated!\n\n";
}



void deleteRestaurant(Db& db) {
  std::string id;
  cout << "Enter restaurant_id to delete: ";
  getline(cin, id);

  execOrThrow(db.conn,
    "DELETE FROM restaurants WHERE restaurant_id=" + id);

  cout << "Deleted (if existed).\n\n";
}


void filterRestaurants(Db& db) {
  std::string type;
  cout << "Enter cuisine to filter: ";
  getline(cin, type);

  type = sqlEscape(db.conn, type);

  auto res = queryResOrThrow(db.conn,
    "SELECT r.restaurant_id, r.name, l.boro "
    "FROM restaurants r "
    "JOIN restaurant_cuisines rc ON rc.restaurant_id=r.restaurant_id "
    "JOIN cuisines c ON c.cuisine_id=rc.cuisine_id "
    "LEFT JOIN locations l ON l.restaurant_id=r.restaurant_id "
    "WHERE c.name='" + type + "' "
    "ORDER BY r.restaurant_id DESC LIMIT 25");

  cout << "\nMatches:\n";
  MYSQL_ROW row;
  while ((row = mysql_fetch_row(res))) {
    cout << row[0] << " | " << row[1] << " | " << (row[2] ? row[2] : "") << "\n";
  }
  mysql_free_result(res);
  cout << "\n";
}

void createUser(Db& db) {
  std::string email, pass, name;
  cout << "Email: "; getline(cin, email);
  cout << "Password (demo): "; getline(cin, pass);
  cout << "Display name: "; getline(cin, name);

  email = sqlEscape(db.conn, email);
  pass  = sqlEscape(db.conn, pass);
  name  = sqlEscape(db.conn, name);

  execOrThrow(db.conn,
    "INSERT INTO users(email, password_hash, display_name) VALUES('" +
    email + "','" + pass + "','" + name + "')");

  long long uid = mysql_insert_id(db.conn);
  execOrThrow(db.conn,
    "INSERT INTO audit_log(user_id, action) VALUES(" + std::to_string(uid) + ",'USER_CREATED')");
  cout << "User created. user_id=" << uid << "\n\n";
}

void login(Db& db) {
  std::string email, pass;
  cout << "Email: "; getline(cin, email);
  cout << "Password: "; getline(cin, pass);

  email = sqlEscape(db.conn, email);
  pass  = sqlEscape(db.conn, pass);

  auto res = queryResOrThrow(db.conn,
    "SELECT user_id FROM users WHERE email='" + email + "' AND password_hash='" + pass + "' LIMIT 1");

  MYSQL_ROW row = mysql_fetch_row(res);
  if (!row) {
    mysql_free_result(res);
    cout << "Login failed.\n\n";
    return;
  }

  current_user_id = stoi(row[0]);
  mysql_free_result(res);

  execOrThrow(db.conn,
    "INSERT INTO user_sessions(user_id, ip_address) VALUES(" +
    std::to_string(current_user_id) + ",'wsl')");

  execOrThrow(db.conn,
    "INSERT INTO audit_log(user_id, action) VALUES(" +
    std::to_string(current_user_id) + ",'LOGIN')");

  cout << "Logged in as user_id=" << current_user_id << "\n\n";
}

void favoriteRestaurant(Db& db) {
  if (current_user_id < 0) { cout << "Login first.\n\n"; return; }

  std::string rid;
  cout << "restaurant_id to favorite: ";
  getline(cin, rid);

  execOrThrow(db.conn,
    "INSERT IGNORE INTO favorites(user_id, restaurant_id) VALUES(" +
    std::to_string(current_user_id) + "," + rid + ")");

  execOrThrow(db.conn,
    "INSERT INTO favorite_history(user_id, restaurant_id, action) VALUES(" +
    std::to_string(current_user_id) + "," + rid + ",'FAVORITED')");

  execOrThrow(db.conn,
    "INSERT INTO audit_log(user_id, action) VALUES(" +
    std::to_string(current_user_id) + ",'FAVORITE_ADDED')");

  cout << "Favorited!\n\n";
}

void rateRestaurant(Db& db) {
  if (current_user_id < 0) { cout << "Login first.\n\n"; return; }

  std::string rid, rating, comment;
  cout << "restaurant_id: "; getline(cin, rid);
  cout << "rating (1-5): "; getline(cin, rating);
  cout << "comment: "; getline(cin, comment);

  int r = stoi(rating);
  if (r < 1 || r > 5) { cout << "Rating must be 1-5.\n\n"; return; }

  comment = sqlEscape(db.conn, comment);

  execOrThrow(db.conn,
    "INSERT INTO user_ratings(user_id, restaurant_id, rating, comment) VALUES(" +
    std::to_string(current_user_id) + "," + rid + "," + rating + ",'" + comment + "')");

  execOrThrow(db.conn,
    "INSERT INTO audit_log(user_id, action) VALUES(" +
    std::to_string(current_user_id) + ",'RATING_CREATED')");

  cout << "Rating saved!\n\n";
}

void analyticsSafest(Db& db) {
  auto res = queryResOrThrow(db.conn,
    "SELECT r.restaurant_id, r.name, COALESCE(l.boro,''), MIN(hi.score) AS best_score "
    "FROM restaurants r "
    "JOIN health_inspections hi ON hi.restaurant_id=r.restaurant_id "
    "LEFT JOIN locations l ON l.restaurant_id=r.restaurant_id "
    "WHERE hi.score IS NOT NULL "
    "GROUP BY r.restaurant_id, r.name, l.boro "
    "ORDER BY best_score ASC "
    "LIMIT 10");

  cout << "\n--- Top 10 Safest (best inspection score) ---\n";
  MYSQL_ROW row;
  while ((row = mysql_fetch_row(res))) {
    cout << row[0] << " | " << row[1] << " | " << row[2] << " | score=" << row[3] << "\n";
  }
  mysql_free_result(res);
  cout << "\n";
}

void analytics311(Db& db) {
  auto res = queryResOrThrow(db.conn,
    "SELECT borough, complaint_type, COUNT(*) AS cnt "
    "FROM service_requests_311 "
    "WHERE created_date >= NOW() - INTERVAL 30 DAY "
    "GROUP BY borough, complaint_type "
    "ORDER BY cnt DESC "
    "LIMIT 15");

  cout << "\n--- Top 311 Complaint Types (last 30 days) ---\n";
  MYSQL_ROW row;
  while ((row = mysql_fetch_row(res))) {
    cout << (row[0] ? row[0] : "") << " | " << row[1] << " | " << row[2] << "\n";
  }
  mysql_free_result(res);
  cout << "\n";
}

void analyticsOpenRest(Db& db) {
  auto res = queryResOrThrow(db.conn,
    "SELECT COALESCE(l.boro,'') AS boro, "
    "AVG(CASE WHEN ori.roadway_compliant=1 THEN 1 ELSE 0 END) AS roadway_rate, "
    "AVG(CASE WHEN ori.sidewalk_compliant=1 THEN 1 ELSE 0 END) AS sidewalk_rate, "
    "COUNT(*) AS n "
    "FROM open_restaurants_inspections ori "
    "JOIN locations l ON l.restaurant_id=ori.restaurant_id "
    "GROUP BY l.boro "
    "ORDER BY n DESC");

  cout << "\n--- Open Restaurants Compliance by Borough ---\n";
  MYSQL_ROW row;
  while ((row = mysql_fetch_row(res))) {
    cout << row[0] << " | roadway=" << row[1] << " | sidewalk=" << row[2] << " | n=" << row[3] << "\n";
  }
  mysql_free_result(res);
  cout << "\n";
}

void showMyFavorites(Db& db) {
  if (current_user_id < 0) { cout << "Login first.\n\n"; return; }

  auto res = queryResOrThrow(db.conn,
    "SELECT r.restaurant_id, r.name, COALESCE(l.boro,'') "
    "FROM favorites f "
    "JOIN restaurants r ON r.restaurant_id=f.restaurant_id "
    "LEFT JOIN locations l ON l.restaurant_id=r.restaurant_id "
    "WHERE f.user_id=" + std::to_string(current_user_id) +
    " ORDER BY f.favorited_at DESC");

  cout << "\n--- My Favorites ---\n";
  MYSQL_ROW row;
  while ((row = mysql_fetch_row(res))) {
    cout << row[0] << " | " << row[1] << " | " << row[2] << "\n";
  }
  mysql_free_result(res);
  cout << "\n";
}



int main() {

    Db db(
        "172.20.0.1",          // host (Windows from WSL)
        "appuser",                    // MySQL username
        "AppPass123!",      // MySQL password
        "nyc_restaurant_finder"    // database name
    );


    while (true) {
        showMenu();
        string choice;
        getline(cin, choice);

        if (choice == "1") {
            showSampleRestaurants();
        } else if (choice == "2") {
            showAbout();
        } else if (choice == "3") {
            createRestaurant(db);
        } else if (choice == "4") {
            readRestaurant(db);
        } else if (choice == "5") {
            updateRestaurant(db);
        } else if (choice == "6") {
            deleteRestaurant(db);
        } else if (choice == "7") {
            filterRestaurants(db);
        } else if (choice == "8") {
            createUser(db);
        } else if (choice == "9") {
            login(db);
        } else if (choice == "10") {
            favoriteRestaurant(db);
        } else if (choice == "11") {
            rateRestaurant(db);
        } else if (choice == "12") {
            analyticsSafest(db);
        } else if (choice == "13") {
            analytics311(db);
        } else if (choice == "14") {
            analyticsOpenRest(db);
        } else if (choice == "15") {
            showMyFavorites(db);
        }
        else if (choice == "0") {
            cout << "Goodbye!\n";
            break;
        } else {
            cout << "Invalid option, try again.\n";
        }
    }
    return 0;
}

 
