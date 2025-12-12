# restaurant-finder
A restaurant discovery and safety-insight application using real NYC open data.

## Overview
NYC Restuarant Finder helps users explore restaurants across New York City using enriched public datasets, including health inspections, outdoor dining compliance, and 311 restaurant-related complaints.  
Users will be able to:
- Create an account
- Save favorite restaurants
- View cuisine categories and neighborhoods
- View inspection scores, compliance flags, and 311 complaint context

This project is implemented in **C++** with a **MySQL** backend.

---

## Public Datasets Used (Checkpoint 1)
These datasets will be used to enrich the application:

1. **NYC Restaurant Inspection Results**  
   https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data

2. **NYC Open Restaurants Inspections**  
   https://data.cityofnewyork.us/Transportation/Open-Restaurants-Inspections/4dx7-axux

3. **NYC 311 Service Requests**  
   https://data.cityofnewyork.us/Social-Services/311-Service-Requests-2010-to-Present/erm2-nwe9

Each dataset provides valuable context on restaurant conditions, cleanliness, compliance, and neighborhood-level insight.

---

## ER Diagram (Crow's Foot)
The ER diagram currently includes **20 foundational tables**, modeled fully in crow’s-foot notation:

<img width="801" height="703" alt="Screenshot 2025-12-02 183231" src="https://github.com/user-attachments/assets/712b397a-1eb6-4217-a10b-381a62168f87" />

- users  
- user_sessions  
- user_preferences  
- favorites  
- user_ratings  
- restaurants  
- cuisines  
- restaurant_cuisines  
- locations  
- ntas
- health_inspections
- open_restaurants_inspections
- service_requests_311
- audit_log
- user_goals
- goal_progress
- suggested_restaurants
- favorite_history
- restaurant_tags
- restaurant_tag_map

---

## Code Demonstration

A fully working demo is shown as an mp4 file in the 'FINAL DEMO VIDEO' folder. It shows logging in (with multiple users), adding a restaurant to the database, favoriting a restaurant, rating a restaurant, and viewing some analytics from the 3 public databases we used.



## To build and run:

```bash
make
make run


