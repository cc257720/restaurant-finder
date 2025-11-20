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
   https://data.cityofnewyork.us/Health/Restaurant-Inspection-Results/xx67-kt59

2. **NYC Open Restaurants Inspections**  
   https://data.cityofnewyork.us/Transportation/Open-Restaurants-Inspections/4dx7-axux

3. **NYC 311 Service Requests**  
   https://data.cityofnewyork.us/Social-Services/311-Service-Requests-2010-to-Present/erm2-nwe9

Each dataset provides valuable context on restaurant conditions, cleanliness, compliance, and neighborhood-level insight.

---

## ER Diagram (Crow's Foot)
The ER diagram currently includes **10 foundational tables**, modeled fully in crow’s-foot notation:

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

<img width="985" height="676" alt="Screenshot 2025-11-20 175134" src="https://github.com/user-attachments/assets/e4311c95-fb89-4704-a70b-ff4dd1528062" />

> This ERD will expand to 20 tables for the final project.

---

## Code Demonstration (Checkpoint 1)
A minimal working C++ program is included that compiles and runs, demonstrating basic output through a console menu.

To build and run:

```bash
make
make run


