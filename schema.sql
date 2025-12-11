
-- Optional: create a dedicated database for your app
CREATE DATABASE IF NOT EXISTS nyc_restaurant_finder
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE nyc_restaurant_finder

-- Drop tables in reverse dependency order (safe re-run)
DROP TABLE IF EXISTS restaurant_tag_map;
DROP TABLE IF EXISTS restaurant_tags;
DROP TABLE IF EXISTS favorite_history;
DROP TABLE IF EXISTS suggested_restaurants;
DROP TABLE IF EXISTS goal_progress;
DROP TABLE IF EXISTS user_goals;
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS service_requests_311;
DROP TABLE IF EXISTS open_restaurants_inspections;
DROP TABLE IF EXISTS health_inspections;
DROP TABLE IF EXISTS ntas;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS restaurant_cuisines;
DROP TABLE IF EXISTS cuisines;
DROP TABLE IF EXISTS user_ratings;
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS user_preferences;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS users;

-- 1) users
CREATE TABLE users (
  user_id        INT AUTO_INCREMENT PRIMARY KEY,
  email          VARCHAR(255) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,
  display_name   VARCHAR(255),
  created_at     DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2) user_sessions
CREATE TABLE user_sessions (
  session_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  login_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  logout_at    DATETIME NULL,
  ip_address   VARCHAR(50),
  CONSTRAINT fk_user_sessions_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- 3) user_preferences
CREATE TABLE user_preferences (
  user_id             INT PRIMARY KEY,
  preferred_boro      VARCHAR(50),
  preferred_cuisine   VARCHAR(100),
  max_distance_miles  DECIMAL(5,2),
  CONSTRAINT fk_user_preferences_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- 4) restaurants
CREATE TABLE restaurants (
  restaurant_id  INT AUTO_INCREMENT PRIMARY KEY,
  camis_id       VARCHAR(50) UNIQUE,
  name           VARCHAR(255),
  phone          VARCHAR(20),
  website_url    VARCHAR(255)
);

-- 5) favorites (junction users ↔ restaurants)
CREATE TABLE favorites (
  user_id        INT NOT NULL,
  restaurant_id  INT NOT NULL,
  favorited_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, restaurant_id),
  CONSTRAINT fk_favorites_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_favorites_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- 6) user_ratings
CREATE TABLE user_ratings (
  rating_id      INT AUTO_INCREMENT PRIMARY KEY,
  user_id        INT NOT NULL,
  restaurant_id  INT NOT NULL,
  rating         INT,
  comment        TEXT,
  created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_ratings_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_user_ratings_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE,
  CONSTRAINT chk_user_ratings_rating
    CHECK (rating BETWEEN 1 AND 5)
);

-- 7) cuisines (lookup)
CREATE TABLE cuisines (
  cuisine_id INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL UNIQUE
);

-- 8) restaurant_cuisines (junction restaurants ↔ cuisines)
CREATE TABLE restaurant_cuisines (
  restaurant_id INT NOT NULL,
  cuisine_id    INT NOT NULL,
  PRIMARY KEY (restaurant_id, cuisine_id),
  CONSTRAINT fk_rest_cuis_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_rest_cuis_cuisine
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(cuisine_id)
    ON DELETE CASCADE
);

-- 9) ntas (Neighborhood Tabulation Areas)
CREATE TABLE ntas (
  nta_code  VARCHAR(20) PRIMARY KEY,
  nta_name  VARCHAR(255)
);

-- 10) locations
CREATE TABLE locations (
  location_id     INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id   INT NOT NULL,
  boro            VARCHAR(50),
  street_address  VARCHAR(255),
  zip             VARCHAR(20),
  latitude        DECIMAL(9,6),
  longitude       DECIMAL(9,6),
  nta_code        VARCHAR(20),
  CONSTRAINT fk_locations_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_locations_nta
    FOREIGN KEY (nta_code) REFERENCES ntas(nta_code)
);

-- 11) health_inspections (DOHMH data)
CREATE TABLE health_inspections (
  inspection_id      INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id      INT NOT NULL,
  inspection_date    DATETIME,
  score              INT,
  grade              VARCHAR(2),
  violation_summary  TEXT,
  CONSTRAINT fk_health_inspections_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- 12) open_restaurants_inspections (Open Restaurants program)
CREATE TABLE open_restaurants_inspections (
  open_inspection_id  INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id       INT NOT NULL,
  inspection_date     DATETIME,
  seating_choice      VARCHAR(20),
  roadway_compliant   BOOLEAN,
  sidewalk_compliant  BOOLEAN,
  skipped_reason      VARCHAR(255),
  CONSTRAINT fk_open_inspections_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- 13) service_requests_311 (NYC 311 complaints related to restaurants)
CREATE TABLE service_requests_311 (
  request_id             INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id          INT NOT NULL,
  complaint_type         VARCHAR(255),
  created_date           DATETIME,
  resolution_description TEXT,
  CONSTRAINT fk_311_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- 14) audit_log (auditing user actions)
CREATE TABLE audit_log (
  log_id      INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  action      VARCHAR(255),
  action_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_log_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- 15) user_goals
CREATE TABLE user_goals (
  goal_id     INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  description VARCHAR(255),
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_goals_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
);

-- 16) goal_progress
CREATE TABLE goal_progress (
  progress_id    INT AUTO_INCREMENT PRIMARY KEY,
  goal_id        INT NOT NULL,
  progress_note  TEXT,
  progress_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_goal_progress_goal
    FOREIGN KEY (goal_id) REFERENCES user_goals(goal_id)
    ON DELETE CASCADE
);

-- 17) suggested_restaurants (recommendations)
CREATE TABLE suggested_restaurants (
  suggestion_id  INT AUTO_INCREMENT PRIMARY KEY,
  user_id        INT NOT NULL,
  restaurant_id  INT NOT NULL,
  score          DECIMAL(5,2),
  CONSTRAINT fk_suggested_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_suggested_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- 18) favorite_history (history of favorites on/off)
CREATE TABLE favorite_history (
  hist_id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id        INT NOT NULL,
  restaurant_id  INT NOT NULL,
  changed_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  action         VARCHAR(20),
  CONSTRAINT fk_favorite_hist_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_favorite_hist_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE
);

-- 19) restaurant_tags (tag vocabulary)
CREATE TABLE restaurant_tags (
  tag_id    INT AUTO_INCREMENT PRIMARY KEY,
  tag_name  VARCHAR(50) NOT NULL UNIQUE
);

-- 20) restaurant_tag_map (junction restaurants ↔ tags)
CREATE TABLE restaurant_tag_map (
  restaurant_id INT NOT NULL,
  tag_id        INT NOT NULL,
  PRIMARY KEY (restaurant_id, tag_id),
  CONSTRAINT fk_rest_tag_restaurant
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_rest_tag_tag
    FOREIGN KEY (tag_id) REFERENCES restaurant_tags(tag_id)
    ON DELETE CASCADE
);
